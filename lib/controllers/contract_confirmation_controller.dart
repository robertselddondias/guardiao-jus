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
  RxString pixCode = ''.obs; // Código PIX fictício
  var copyPixRequested = false.obs;

  RxString idTransaction = ''.obs;

  RxBool isPayment = false.obs;

  RxBool isLoading = false.obs;

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
    UserModel userModel = await _userRepository.getUserById();

    String valor = '${company.value!.monthlyValue!.toString()}00';

    idTransaction.value = await createTransactional();

    if(userModel.customerId == null) {
      String idCustomer = await _pagarMeService.createCustomer(
          name: userModel.name!,
          email: userModel.email!,
          documentNumber: userModel.cpf!,
          documentType: 'CPF',
          phone: userModel.phone!
      );
      userModel.customerId = idCustomer;
      await FirebaseFirestore.instance.collection('users').doc(userModel.uid).set(
          userModel.toMap(), SetOptions(merge: true));
    }

    http.Response response = await _pagarMeService.createPixTransaction(
        amount: int.parse(valor),
        orderId: idTransaction.value,
        customerId: userModel.customerId!);
    if(response.statusCode == 200) {
      Map<String, dynamic> bodyResponse = jsonDecode(response.body);
      urlQrCode.value = bodyResponse['charges'][0]['last_transaction']['qr_code_url'];
      pixCode.value = bodyResponse['charges'][0]['last_transaction']['qr_code'];
      transactionPagarMeId.value = bodyResponse['charges'][0]['last_transaction']['id'];
      listenToNewTransactions(context);
    }
  }

  Future<void> createCreditTransaction(BuildContext context) async {
    try {
      isLoading.value = true;
      String valor = '${company.value!.monthlyValue!.toString()}00';

      idTransaction.value = await createTransactional();

      http.Response response = await _pagarMeService.createOrder(
          amount: int.parse(valor),
          orderId: idTransaction.value,
          creditCard: cardSelection.value);
      if (response.statusCode == 200) {
        Map<String, dynamic> bodyResponse = jsonDecode(response.body);
        transactionPagarMeId.value =
        bodyResponse['charges'][0]['last_transaction']['id'];
        listenToNewTransactions(context);
      } else {
        SnackbarCustom.showError(
            'Ocorreu um erro ao realizar o pagamento. Altere o método do pagamento!');
      }
    }catch(e) {
      SnackbarCustom.showError(
          'Ocorreu um erro ao realizar o pagamento. Altere o método do pagamento!');
    } finally {
      isLoading.value = false;
    }
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


  // Método para escutar a coleção
  Future<void> listenToNewTransactions(BuildContext context) async {
    FirebaseFirestore.instance
        .collection('transaction_pagarme')
        .snapshots()
        .listen((snapshot) async {
      isLoading.value = true;
      for (var change in snapshot.docChanges) {
        // Verifica se o registro foi adicionado
        if (change.type == DocumentChangeType.added) {
          final newData = change.doc.data();
          if (newData?['orderId'] == idTransaction.value) {
            PaymentGatewayTransactionModel? gatewayTransactionModel = await _gatewayTransactionsRepository
                .getTransactionById(idTransaction.value);
            if(newData?['status'] == 'paid') {
              gatewayTransactionModel?.paid = true;
              gatewayTransactionModel?.paymentMethod = newData?['paymentType'];
              isPayment.value = true;
            }
            gatewayTransactionModel?.transactionId = newData?['transactionId'];
            gatewayTransactionModel?.status = newData?['status'];
            _contractTransactionService.saveTransaction(idTransaction.value, gatewayTransactionModel!);
            isLoading.value = false;
            Preferences.setString('companyId', company.value!.id!);
            Get.offAll(() => FullScreenStatusScreen(
              isSuccess: isPayment.value, // Define se é sucesso ou erro
              message: isPayment.value ? "Seu convênio foi contratado com sucesso!" : 'Ocorreu um erro no pagamento. Verifique o metódo de pagamento e tente novamente.',
            ));
          }
        }
      }

    }, onError: (error) {
      print('Erro ao monitorar a coleção: $error');
      SnackbarCustom.showError(
        'Não foi possível monitorar as transações.'
      );
    });
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
