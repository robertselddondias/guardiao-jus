import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/models/rap_model.dart';
import 'package:guardiao_cliente/repositories/rap_repository.dart';
import 'package:guardiao_cliente/widgets/snackbar_custom.dart';
import 'package:guardiao_cliente/utils/date_utils_custom.dart';

class RapListController extends GetxController {

  final RapRepository _rapRepository = RapRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseStorage _storage = FirebaseStorage.instance;

  RxList<RapModel> rapList = <RapModel>[].obs;

  RxBool isLoading = false.obs;

  // Filtros
  TextEditingController titleFilterController = TextEditingController();
  TextEditingController dateFilterController = TextEditingController();
  DateTime? selectedDateFilter;

  @override
  void onInit() {
    super.onInit();
    fetchRaps();
  }

  // Função para buscar os RAPs no Firebase filtrando por userId
  Future<void> fetchRaps() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user == null) {
        SnackbarCustom.showError('Usuário não autenticado.');
        return;
      }

      var raps = await _rapRepository.fetchRapByUserId(user.uid);
      rapList.value = raps;

    } catch (e) {
      SnackbarCustom.showError('Erro ao buscar RAPs: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Filtrar a lista com base no título e na data
  void filterList() {
    isLoading.value = true;
    final titleFilter = titleFilterController.text.toLowerCase();
    final dateFilter = dateFilterController.text;

    rapList.value = rapList.where((rap) {
      final matchesTitle =
          titleFilter.isEmpty || rap.title!.toLowerCase().contains(titleFilter);
      final rapDate = DateUtilsCustom.formatDate(rap.dtOcorrencia!);
      final matchesDate = dateFilter.isEmpty || rapDate.contains(dateFilter);
      return matchesTitle && matchesDate;
    }).toList();
    isLoading.value = false;
  }

  // Define a data de filtro e atualiza a lista filtrada
  void setDateFilter(DateTime? date) {
    selectedDateFilter = date;
    filterList();
  }

  // Remover um RAP da lista e do Firestore
  Future<void> removeRap(RapModel rap) async {
    try {
      isLoading.value = true;
      if(rap.companyId == null) {
        _rapRepository.deleteRap(rap.id!);

        for (var url in rap.urlFiles!) {
          await _storage.refFromURL(url).delete();
        }

        rapList.remove(rap);
        fetchRaps();
        SnackbarCustom.showSuccess('RAP removido com sucesso.');
      } else {
        SnackbarCustom.showInfo('Você nao pode excluir um RAP enviado para o jurídico!');
      }
    } catch (e) {
      SnackbarCustom.showError('Erro ao remover RAP: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void cleanFilters() {
    titleFilterController.text = '';
    dateFilterController.text = '';
    fetchRaps();
  }

  @override
  void onClose() {
    titleFilterController.dispose();
    dateFilterController.dispose();
    super.onClose();
  }
}
