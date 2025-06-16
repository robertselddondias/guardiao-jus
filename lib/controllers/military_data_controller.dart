import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/models/entidade_militar_model.dart';
import 'package:guardiao_cliente/models/military_model.dart';
import 'package:guardiao_cliente/repositories/entidade_militar_repository.dart';
import 'package:guardiao_cliente/widgets/snackbar_custom.dart';
import 'package:guardiao_cliente/ui/home_screen.dart';
import 'package:guardiao_cliente/utils/Preferences.dart';

class MilitaryDataController extends GetxController {
  TextEditingController registrationNumberController = TextEditingController();
  TextEditingController rankController = TextEditingController();
  TextEditingController entityController = TextEditingController();

  RxString selectedUf = ''.obs;
  RxList<EntidadeMilitarModel> militaryEntities = <EntidadeMilitarModel>[].obs; // Lista de entidades militares filtradas
  final EntidadeMilitarRepository _entidadeMilitarRepository = EntidadeMilitarRepository();


  Rx<EntidadeMilitarModel> selectedEntity = EntidadeMilitarModel().obs;

  // final RxList<String> ufList = <String>[
  //   'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA',
  //   'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN',
  //   'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO',
  // ].obs;

  final RxList<String> ufList = <String>[
    'DF'
  ].obs;

  RxBool isLoading = false.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Validação dos campos obrigatórios
  bool validateFields() {
    if (registrationNumberController.text.isEmpty ||
        rankController.text.isEmpty ||
        selectedEntity.value.sigla == null ||
        selectedUf.value.isEmpty) {
      SnackbarCustom.showWarning(
          'Por favor, preencha todos os campos obrigatórios.');
      return false;
    }
    return true;
  }

  // Método para salvar os dados no Firebase
  Future<void> saveMilitaryData() async {
    if (!validateFields()) return;

    try {
      isLoading.value = true;

      // Dados a serem salvos
      final MilitaryModel militaryData = MilitaryModel(
          registrationNumber: registrationNumberController.text,
          rank: rankController.text,
          entity: '${selectedEntity.value.sigla} - ${selectedEntity.value.name} ',
          militaryUf: selectedUf.value
      );

      // Atualizar os dados na coleção "users"
      await _firestore.collection('users').doc(Preferences.getString('userId')).set(
          {'militarData' : militaryData.toMap(), 'isMilitaryInfoComplete': true},
          SetOptions(merge: true));

      Get.to(() => HomeScreen());
      SnackbarCustom.showSuccess('Dados militares salvos com sucesso!');
    } catch (e) {
      SnackbarCustom.showError(
          'Erro ao salvar os dados militares: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Método para buscar entidades militares com base no estado selecionado
  Future<void> fetchMilitaryEntities() async {
    if (selectedUf.value.isEmpty) {
      SnackbarCustom.showError("Por favor, selecione um estado.");
      return;
    }

    try {
      isLoading.value = true;
      print("Buscando entidades militares para o estado: ${selectedUf.value}");

      final entities = await _entidadeMilitarRepository.fetchByEstado(selectedUf.value);

      if (entities.isNotEmpty) {
        militaryEntities.value = entities;
        print("Entidades carregadas com sucesso: ${entities.length} itens.");
      } else {
        militaryEntities.clear();
        SnackbarCustom.showWarning("Nenhuma entidade encontrada para este estado.");
      }
    } catch (e) {
      SnackbarCustom.showError("Erro ao buscar entidades militares: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void dispose() {
    registrationNumberController.clear();
    rankController.clear();
    entityController.clear();
    registrationNumberController.dispose();
    rankController.dispose();
    entityController.dispose();
    super.dispose();
  }
}
