import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/models/user_model.dart';
import 'package:guardiao_cliente/repositories/user_repository.dart';
import 'package:guardiao_cliente/utils/Preferences.dart';
import 'package:guardiao_cliente/utils/cpf_utils.dart';
import 'package:guardiao_cliente/widgets/snackbar_custom.dart';
import 'package:guardiao_cliente/ui/new_user/address_screen.dart';
import 'package:guardiao_cliente/utils/date_utils_custom.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class PersonalDataController extends GetxController {
  final UserRepository _userRepository = UserRepository();

  final nameController = TextEditingController();
  final cpfController = TextEditingController();
  final birthDateController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  RxBool isLoading = false.obs;

  var maskFormatterCpf = MaskTextInputFormatter(
      mask: '###.###.###-##',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  var maskFormatterTelefone = MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  var maskFormatterDtNascimento = MaskTextInputFormatter(
      mask: '##/##/####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  // Instância do Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() async {
    super.onInit();

    nameController.text = Preferences.getString('displayName') ?? '';
    emailController.text = Preferences.getString('email') ?? '';
  }

  // Método para salvar os dados no Firestore
  Future<void> savePersonalData() async {
    try {
      if (nameController.text.trim().isEmpty) {
        SnackbarCustom.showWarning("Por favor, preencha o nome.");
        return;
      }

      if(!CpfUtil.isValid(maskFormatterCpf.getMaskedText())) {
        SnackbarCustom.showWarning("Insira um CPF válido.");
        return;
      }

      if (maskFormatterCpf.getUnmaskedText().length != 11) {
        SnackbarCustom.showWarning("Insira um CPF válido.");
        return;
      }

      DateTime? birthDate = DateUtilsCustom.convertStringToDate(maskFormatterDtNascimento.getMaskedText().trim());
      if (birthDate == null) {
        SnackbarCustom.showWarning("Data de nascimento inválida.");
        return;
      }

      // 🔹 Verifica se tem pelo menos 18 anos
      final DateTime today = DateTime.now();
      final int age = today.year - birthDate.year;
      if (age < 18 || (age == 18 && today.isBefore(birthDate.add(const Duration(days: 365 * 18))))) {
        SnackbarCustom.showWarning("Você precisa ter pelo menos 18 anos.");
        return;
      }

      if (maskFormatterTelefone.getUnmaskedText().length < 10) {
        SnackbarCustom.showWarning(
            "Telefone inválido. Insira um número válido.");
        return;
      }

      if (!GetUtils.isEmail(emailController.text.trim())) {
        SnackbarCustom.showWarning("E-mail inválido. Insira um e-mail válido.");
        return;
      }

      isLoading.value = true;

      UserModel userModel = await _userRepository.getUserById();
      userModel.name = nameController.text.trim();
      userModel.cpf = maskFormatterCpf.getMaskedText();
      userModel.birthDate = birthDate;
      userModel.phone = maskFormatterTelefone.getUnmaskedText();
      userModel.email = emailController.text.trim();
      userModel.isPersonalInfoComplete = true;

      await FirebaseFirestore.instance.collection('users')
          .doc(userModel.uid).set(userModel.toMap(), SetOptions(merge: true));

      Get.to(() => const AddressScreen());
    } catch (e) {
      SnackbarCustom.showError('Erro ao salvar dados: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void dispose() {
    nameController.clear();
    cpfController.clear();
    cpfController.clear();
    birthDateController.clear();
    phoneController.clear();
    emailController.clear();

    nameController.dispose();
    cpfController.dispose();
    birthDateController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
