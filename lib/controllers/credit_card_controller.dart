import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/models/user_model.dart';
import 'package:guardiao_cliente/services/pagarme_service.dart';
import 'package:guardiao_cliente/widgets/snackbar_custom.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CreditCardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PagarMeService _pagarMeService = PagarMeService();

  // Controladores para os campos do formulário
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController holderNameController = TextEditingController();
  final TextEditingController expirationDateController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final TextEditingController aliasController = TextEditingController();

  // Máscaras para formatação
  final dataMask = MaskTextInputFormatter(
    mask: '##/##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final numCardMask = MaskTextInputFormatter(
    mask: '#### #### #### ####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  // Estados observáveis
  var isLoading = false.obs;

  // Método para validar os dados do cartão
  bool _validateFields() {
    if (cardNumberController.text.isEmpty ||
        holderNameController.text.isEmpty ||
        expirationDateController.text.isEmpty ||
        cvvController.text.isEmpty) {
      SnackbarCustom.showError('Todos os campos são obrigatórios.');
      return false;
    }

    // Validação do número do cartão
    if (cardNumberController.text.replaceAll(' ', '').length != 16) {
      SnackbarCustom.showError('Número do cartão inválido.');
      return false;
    }

    // Validação do CVV
    if (cvvController.text.length < 3) {
      SnackbarCustom.showError('CVV inválido.');
      return false;
    }

    // Validação da data de validade (MM/AA)
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(expirationDateController.text)) {
      SnackbarCustom.showError('Data de validade inválida. Use o formato MM/AA.');
      return false;
    }

    return true;
  }

  // Método para salvar um novo cartão no Firestore
  Future<void> saveCreditCard() async {
    if (!_validateFields()) return;

    try {
      isLoading.value = true;

      final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isEmpty) {
        SnackbarCustom.showError('Usuário não autenticado.');
        return;
      }

      final DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore.collection('users').doc(userId).get();
      final UserModel user = UserModel.fromMap(userDoc.data()!);

      if(user.customerId == null) {
        String idCustomer = await _pagarMeService.createCustomer(
            name: user.name!,
            email: user.email!,
            documentNumber: user.cpf!,
            documentType: 'CPF',
            phone: user.phone!
        );
        user.customerId = idCustomer;
        await _firestore.collection('users').doc(userId).set(
            user.toMap(), SetOptions(merge: true));
      }

      await _pagarMeService.createCard(
          cardNumber: cardNumberController.text,
          cardHolderName: holderNameController.text,
          cardExpirationDate: expirationDateController.text,
          cardCvv: cvvController.text,
          alias: aliasController.text,
          documentNumber: user.cpf!,
          customerId: user.customerId
      );


      SnackbarCustom.showSuccess('Cartão cadastrado com sucesso!');
      clearFields();
    } catch (e) {
      SnackbarCustom.showError('Erro ao salvar o cartão: $e');
    } finally {
      isLoading.value = false;
      Get.back();
    }
  }

  // Método para limpar os campos do formulário
  void clearFields() {
    cardNumberController.clear();
    holderNameController.clear();
    expirationDateController.clear();
    cvvController.clear();
    aliasController.clear();
  }

  @override
  void dispose() {
    cardNumberController.dispose();
    holderNameController.dispose();
    expirationDateController.dispose();
    cvvController.dispose();
    aliasController.dispose();
    super.dispose();
  }
}
