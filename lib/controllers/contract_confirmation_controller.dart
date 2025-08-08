import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/models/company_model.dart';
import 'package:guardiao_cliente/models/contract_transaction_model.dart';
import 'package:guardiao_cliente/models/credit_card_model.dart';
import 'package:guardiao_cliente/models/payment_gateway_transaction_model.dart';
import 'package:guardiao_cliente/models/user_model.dart';
import 'package:guardiao_cliente/repositories/contracts_repository.dart';
import 'package:guardiao_cliente/repositories/payment_gateway_transactions_repository.dart';
import 'package:guardiao_cliente/repositories/user_repository.dart';
import 'package:guardiao_cliente/services/contract_transaction_service.dart';
import 'package:guardiao_cliente/services/pagarme_service.dart';
import 'package:guardiao_cliente/widgets/snackbar_custom.dart';
import 'package:guardiao_cliente/ui/status_dialog_screen.dart';
import 'package:guardiao_cliente/utils/Preferences.dart';
import 'package:http/http.dart' as http;

class ContractConfirmationController extends GetxController {
  final PagarMeService _pagarMeService = PagarMeService();
  final ContractsRepository _contractsRepository = ContractsRepository();
  final UserRepository _userRepository = UserRepository();
  final PaymentGatewayTransactionsRepository _gatewayTransactionsRepository = PaymentGatewayTransactionsRepository();
  final ContractTransactionService _contractTransactionService = ContractTransactionService();

  Rx<CompanyModel?> company = Rx<CompanyModel?>(null);
  RxString paymentMethodName = '---'.obs;
  RxInt monthlyValue = 0.obs;
  RxString chargeDate = 'Todo dia 10'.obs;
  RxString urlQrCode = ''.obs;
  RxString transactionPagarMeId = ''.obs;

  RxList<CreditCardUserModel> creditCards = <CreditCardUserModel>[].obs;

  var showPaymentSheet = false.obs;
  var confirmRequested = false.obs;

  Rx<CreditCardUserModel> cardSelection = CreditCardUserModel().obs;

  // Para o PIX
  RxString pixCode = ''.obs;
  var copyPixRequested = false.obs;

  RxString idTransaction = ''.obs;
  RxBool isPayment = false.obs;
  RxBool isLoading = false.obs;

  // **🔹 Gerenciamento melhorado do listener**
  StreamSubscription<QuerySnapshot>? _transactionListener;
  Timer? _timeoutTimer;
  static const int _listenerTimeoutMinutes = 10; // Timeout de 10 minutos

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments ?? {};
    company.value = args['company'] as CompanyModel?;
    monthlyValue.value = company.value?.monthlyValue ?? 0;
    chargeDate.value = 'Todo dia ${DateTime.now().day}';

    // Workers
    ever(showPaymentSheet, (bool val) {
      if (val) {
        loadCreditCards();
      }
    });

    ever(confirmRequested, (bool val) {
      if (val) {
        _confirmContract();
      }
    });

    ever(copyPixRequested, (bool val) {
      if (val) {
        _copyPixCode();
      }
    });
  }

  @override
  void onClose() {
    // **🔹 Cancela o listener e timer ao fechar o controller**
    _cancelTransactionListener();
    super.onClose();
  }

  Future<void> _confirmContract() async {
    if (paymentMethodName.value == '---') {
      SnackbarCustom.showWarning('Escolha um método de pagamento antes de confirmar.', title: 'Atenção');
      confirmRequested.value = false;
      return;
    }
    isLoading.value = true;
    await createTransactional();

    isLoading.value = false;

    SnackbarCustom.showSuccess('Convênio confirmado com sucesso!');
    Get.back(result: true);
  }

  Future<void> loadCreditCards() async {
    creditCards.clear();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null || userId.isEmpty) {
      SnackbarCustom.showWarning('Nenhum usuário autenticado.', title: 'Atenção');
      showPaymentSheet.value = false;
      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore
          .collection('credit_cards')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      creditCards.value = snapshot.docs.map((doc) {
        return CreditCardUserModel.fromJson(doc.data());
      }).toList();

      update();
    } catch (e) {
      SnackbarCustom.showError('Erro ao carregar cartões: $e');
      showPaymentSheet.value = false;
    }
  }

  Future<void> createPixTransaction(BuildContext context) async {
    try {
      isLoading.value = true;
      UserModel userModel = await _userRepository.getUserById();

      idTransaction.value = await createTransactional();

      if(userModel.customerId == null) {
        String idCustomer = await _pagarMeService.createCustomer(
            name: userModel.name!,
            email: userModel.email!,
            documentNumber: userModel.cpf!,
            documentType: 'CPF',
            phone: userModel.phone!,
            uf: userModel.address!.uf!,
            city: userModel.address!.city!,
            zipCode: userModel.address!.cep!,
            line1: userModel.address!.street!
        );
        userModel.customerId = idCustomer;
        await FirebaseFirestore.instance.collection('users').doc(userModel.uid).set(
            userModel.toMap(), SetOptions(merge: true));
      }

      http.Response response = await _pagarMeService.createPixTransaction(
          amount: company.value!.monthlyValue!,
          orderId: idTransaction.value,
          customerId: userModel.customerId!);

      if(response.statusCode == 200) {
        Map<String, dynamic> bodyResponse = jsonDecode(response.body);
        urlQrCode.value = bodyResponse['charges'][0]['last_transaction']['qr_code_url'];
        pixCode.value = bodyResponse['charges'][0]['last_transaction']['qr_code'];
        transactionPagarMeId.value = bodyResponse['charges'][0]['last_transaction']['id'];

        // **🔹 Inicia o listener otimizado após criar a transação PIX**
        _startOptimizedTransactionListener(context);
      } else {
        SnackbarCustom.showError('Erro ao criar transação PIX. Tente novamente.');
      }
    } catch (e) {
      SnackbarCustom.showError('Erro ao criar transação PIX: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createCreditTransaction(BuildContext context) async {
    try {
      isLoading.value = true;
      String valor = '${company.value!.monthlyValue!.toString()}';

      idTransaction.value = await createTransactional();

      http.Response response = await _pagarMeService.createOrder(
          amount: int.parse(valor),
          orderId: idTransaction.value,
          creditCard: cardSelection.value);

      if (response.statusCode == 200) {
        Map<String, dynamic> bodyResponse = jsonDecode(response.body);
        transactionPagarMeId.value = bodyResponse['charges'][0]['last_transaction']['id'];

        // **🔹 Inicia o listener otimizado após criar a transação de cartão**
        // **Mantém o loading ativo durante todo o processo de monitoramento**
        _startOptimizedTransactionListener(context);
      } else {
        isLoading.value = false;
        SnackbarCustom.showError('Ocorreu um erro ao realizar o pagamento. Altere o método do pagamento!');
      }
    } catch(e) {
      isLoading.value = false;
      SnackbarCustom.showError('Ocorreu um erro ao realizar o pagamento. Altere o método do pagamento!');
    }
    // **🔹 Removido o finally - loading só para quando a transação for processada**
  }

  void setPaymentMethod(String methodName) {
    paymentMethodName.value = methodName;
    showPaymentSheet.value = false;
  }

  Future<void> _copyPixCode() async {
    copyPixRequested.value = false;
    try {
      await Clipboard.setData(ClipboardData(text: pixCode.value));
      SnackbarCustom.showSuccess('Código PIX copiado para a área de transferência!');
    } catch (e) {
      SnackbarCustom.showError('Erro ao copiar código PIX: $e');
    }
  }

  /// **🔹 LISTENER OTIMIZADO PARA TRANSAÇÕES**
  void _startOptimizedTransactionListener(BuildContext context) {
    // **Cancela listener anterior se existir**
    _cancelTransactionListener();

    // **Configurar timeout para evitar listeners infinitos**
    _timeoutTimer = Timer(Duration(minutes: _listenerTimeoutMinutes), () {
      _cancelTransactionListener();

      // **Navega para tela de erro por timeout (loading para na _navigateToResultScreen)**
      if (Get.isDialogOpen == false) {
        SnackbarCustom.showWarning(
            'Tempo limite atingido. Verifique o status do pagamento posteriormente.',
            title: 'Timeout'
        );

        isPayment.value = false;
        _navigateToResultScreen();
      }
    });

    try {
      // **Query otimizada com filtros específicos**
      _transactionListener = FirebaseFirestore.instance
          .collection('transaction_pagarme')
          .where('orderId', isEqualTo: idTransaction.value) // **Filtro específico**
          .limit(1) // **Limita a 1 documento**
          .snapshots()
          .listen(
        _handleTransactionUpdate,
        onError: _handleTransactionError,
        cancelOnError: false, // **Continua ouvindo mesmo com erros**
      );

      print('🎯 Listener iniciado para transação: ${idTransaction.value}');
    } catch (e) {
      _handleTransactionError(e);
    }
  }

  /// **🔹 Manipula atualizações de transação**
  Future<void> _handleTransactionUpdate(QuerySnapshot snapshot) async {
    try {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added || change.type == DocumentChangeType.modified) {
          final data = change.doc.data() as Map<String, dynamic>?;

          if (data == null || data['orderId'] != idTransaction.value) {
            continue; // **Ignora se não for nossa transação**
          }

          print('🔄 Transação atualizada: ${data['status']}');

          final status = data['status']?.toString().toLowerCase();

          // **Verifica se é um status final**
          if (status == 'paid' || status == 'failed' || status == 'canceled') {
            await _processTransactionUpdate(data);

            // **Para o listener após processar a transação**
            _cancelTransactionListener();
            break;
          } else {
            // **Status intermediário - apenas atualiza sem navegar**
            print('⏳ Status intermediário: $status - continuando monitoramento...');
            await _processTransactionUpdate(data);
          }
        }
      }
    } catch (e) {
      print('❌ Erro ao processar atualização: $e');
      _handleTransactionError(e);
    }
  }

  /// **🔹 Processa a atualização da transação**
  Future<void> _processTransactionUpdate(Map<String, dynamic> data) async {
    try {
      // **🔹 Mantém loading ativo durante processamento**

      PaymentGatewayTransactionModel? gatewayTransaction =
      await _gatewayTransactionsRepository.getTransactionById(idTransaction.value);

      if (gatewayTransaction == null) {
        throw Exception('Transação não encontrada no banco local');
      }

      // **Atualiza dados da transação**
      gatewayTransaction.transactionId = data['transactionId'];
      gatewayTransaction.status = data['status'];

      final status = data['status']?.toString().toLowerCase();

      if (status == 'paid') {
        gatewayTransaction.paid = true;
        gatewayTransaction.paymentMethod = data['paymentType'];
        isPayment.value = true;

        // **Salva dados da empresa no preferences**
        Preferences.setString('companyId', company.value!.id!);

        await _contractTransactionService.saveTransactionWithUser(
            idTransaction.value,
            gatewayTransaction
        );

        SnackbarCustom.showSuccess('Pagamento aprovado com sucesso!');

        // **Navega para tela de sucesso**
        await _navigateToResultScreen();

      } else if (status == 'failed' || status == 'canceled') {
        isPayment.value = false;

        await _contractTransactionService.saveTransaction(
            idTransaction.value,
            gatewayTransaction
        );

        SnackbarCustom.showError('Pagamento não aprovado. Status: $status');

        // **Navega para tela de erro**
        await _navigateToResultScreen();

      } else {
        // **Status intermediário (processing, pending, etc.)**
        await _contractTransactionService.saveTransaction(
            idTransaction.value,
            gatewayTransaction
        );

        print('⏳ Status intermediário: $status - continuando aguardando...');
        // **Não navega, apenas salva e continua monitorando**
      }

    } catch (e) {
      print('❌ Erro ao processar transação: $e');
      SnackbarCustom.showError('Erro ao processar resultado do pagamento: $e');

      // **Em caso de erro, navega para tela de erro**
      isPayment.value = false;
      await _navigateToResultScreen();
    }
  }

  /// **🔹 Navega para tela de resultado**
  Future<void> _navigateToResultScreen() async {
    if (Get.currentRoute.contains('FullScreenStatusScreen')) {
      return; // **Evita navegação duplicada**
    }

    // **🔹 Para o loading antes de navegar**
    isLoading.value = false;

    final message = isPayment.value
        ? "Seu convênio foi contratado com sucesso!"
        : 'Ocorreu um erro no pagamento. Verifique o método de pagamento e tente novamente.';

    await Get.offAll(() => FullScreenStatusScreen(
      isSuccess: isPayment.value,
      message: message,
    ));
  }

  /// **🔹 Manipula erros do listener**
  void _handleTransactionError(dynamic error) {
    print('❌ Erro no listener de transação: $error');

    if (!Get.isSnackbarOpen) {
      SnackbarCustom.showError(
          'Erro ao monitorar pagamento. Verifique o status posteriormente.',
          title: 'Erro de Monitoramento'
      );
    }

    // **Para o listener**
    _cancelTransactionListener();

    // **Define como erro e navega (loading para na _navigateToResultScreen)**
    isPayment.value = false;
    _navigateToResultScreen();
  }

  /// **🔹 Cancela o listener e timer**
  void _cancelTransactionListener() {
    try {
      _transactionListener?.cancel();
      _transactionListener = null;

      _timeoutTimer?.cancel();
      _timeoutTimer = null;

      print('🛑 Listener de transação cancelado');
    } catch (e) {
      print('⚠️ Erro ao cancelar listener: $e');
    }
  }

  /// **🔹 Método público para cancelar listener manualmente**
  void cancelPaymentMonitoring() {
    _cancelTransactionListener();
    isLoading.value = false; // **Para loading ao cancelar manualmente**
    SnackbarCustom.showInfo('Monitoramento de pagamento cancelado');
  }

  /// **🔹 Verifica status da transação manualmente**
  Future<void> checkTransactionStatusManually() async {
    if (idTransaction.value.isEmpty) {
      SnackbarCustom.showWarning('Nenhuma transação ativa para verificar');
      return;
    }

    try {
      isLoading.value = true;

      final doc = await FirebaseFirestore.instance
          .collection('transaction_pagarme')
          .where('orderId', isEqualTo: idTransaction.value)
          .limit(1)
          .get();

      if (doc.docs.isNotEmpty) {
        await _processTransactionUpdate(doc.docs.first.data());
      } else {
        SnackbarCustom.showInfo('Transação ainda está sendo processada...');
        isLoading.value = false; // **Para loading se não encontrou**
      }
    } catch (e) {
      SnackbarCustom.showError('Erro ao verificar status: $e');
      isLoading.value = false; // **Para loading em caso de erro**
    }
  }

  Future<String> createTransactional() async {
    ContractTransactionModel contractTransactionModel = ContractTransactionModel(
        userId: Preferences.getString('userId'),
        companyId: company.value?.id,
        paymentMethodName: paymentMethodName.value,
        monthlyValue: company.value?.monthlyValue,
        chargeDate: chargeDate.value,
        createdAt: DateTime.now()
    );
    String contractId = await _contractsRepository.addContract(contractTransactionModel);

    PaymentGatewayTransactionModel gatewayTransactionModel = PaymentGatewayTransactionModel(
        userId: Preferences.getString('userId'),
        companyId: company.value?.id,
        amount: company.value?.monthlyValue!,
        paid: false,
        status: 'pending',
        paymentMethod: paymentMethodName.value,
        contractId: contractId,
        createdAt: DateTime.now());
    return await _gatewayTransactionsRepository.addTransaction(gatewayTransactionModel);
  }
}