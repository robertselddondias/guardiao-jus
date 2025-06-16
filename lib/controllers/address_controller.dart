import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/models/address_model.dart';
import 'package:guardiao_cliente/services/cep_service.dart';
import 'package:guardiao_cliente/widgets/snackbar_custom.dart';
import 'package:guardiao_cliente/ui/new_user/military_data_screen.dart';
import 'package:guardiao_cliente/utils/Preferences.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class AddressController extends GetxController {
  final CepService _cepService = CepService(); // Instância do serviço
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Instância do Firestore

  TextEditingController cepController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController districtController = TextEditingController();
  TextEditingController streetController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController complementController = TextEditingController();
  RxString selectedUf = ''.obs;

  var maskFormatter = MaskTextInputFormatter(
    mask: '#####-###',
    filter: { "#": RegExp(r'[0-9]') },
    type: MaskAutoCompletionType.lazy,
  );

  // Lista de UF
  final List<String> ufList = [
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA',
    'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN',
    'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO',
  ];

  // Função para buscar o endereço pelo CEP usando o serviço
  Future<void> searchCep() async {
    final cep = cepController.text.replaceAll('-', ''); // Remove traços do CEP

    try {
      final data = await _cepService.fetchAddressFromCep(cep);
      if (data != null) {
        // Atualiza os campos de endereço com os dados retornados
        cityController.text = data['localidade'] ?? '';
        districtController.text = data['bairro'] ?? '';
        streetController.text = data['logradouro'] ?? '';
        selectedUf.value = data['uf'] ?? '';

        update(); // 🔹 Atualiza a interface para refletir o novo valor
      } else {
        SnackbarCustom.showError('CEP inválido ou não encontrado.');
      }
    } catch (e) {
      SnackbarCustom.showError('Não foi possível buscar o endereço.');
    }
  }

  // Função para salvar os dados do endereço no Firestore
  Future<void> saveAddressToFirebase() async {
    // Validação dos campos obrigatórios
    if (cepController.text.isEmpty ||
        cityController.text.isEmpty ||
        districtController.text.isEmpty ||
        streetController.text.isEmpty ||
        numberController.text.isEmpty ||
        selectedUf.value.isEmpty) {
      SnackbarCustom.showInfo('Por favor, preencha todos os campos obrigatórios.');
      return;
    }



    // Monta o mapa de dados
    final AddressModel addressModel = AddressModel(
      cep: cepController.text,
      uf: selectedUf.value,
      city: cityController.text,
      district: districtController.text,
      street: streetController.text,
      number: numberController.text,
      complement: complementController.text,
    );

    try {
      // Salva os dados na coleção "users" com o ID do usuário
      await _firestore.collection('users').doc(Preferences.getString('userId')).set({
        'isAdressInfoComplete': true,
        'address': addressModel.toMap(),
      }, SetOptions(merge: true));
      Get.to(MilitaryDataScreen());
    } catch (e) {
      SnackbarCustom.showError('Erro ao salvar o endereço: $e');
      return;
    }
  }

  @override
  void dispose() {
    cepController.clear();
    cityController.clear();
    complementController.clear();
    numberController.clear();
    districtController.clear();
    streetController.clear();

    cepController.dispose();
    cityController.dispose();
    complementController.dispose();
    numberController.dispose();
    streetController.dispose();
    super.dispose();
  }
}
