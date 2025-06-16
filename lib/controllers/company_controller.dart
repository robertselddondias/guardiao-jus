import 'package:get/get.dart';

import '../models/company_model.dart';
import '../repositories/company_repository.dart';

class CompanyController extends GetxController {
  final CompanyRepository _repository = CompanyRepository();

  // Lista de empresas (observe para que a tela atualize automaticamente)
  var companies = <CompanyModel>[].obs;

  // Estado de carregamento
  var isLoading = false.obs;

  // Empresa selecionada
  var selectedCompany = Rx<CompanyModel?>(null);

  @override
  void onInit() async {
    super.onInit();
    await fetchCompanies();
  }

  /// Carrega todas as empresas
  Future<void> fetchCompanies() async {
    try {
      isLoading.value = true;
      final data = await _repository.getAllCompanies();

      // Atribui as empresas carregadas
      companies.value = data;
    } catch (e) {
      Get.snackbar("Erro", "Erro ao carregar empresas: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Seleciona uma empresa para edição ou exibição
  void selectCompany(CompanyModel company) {
    selectedCompany.value = company;
  }

  /// Pesquisa empresas pelo nome
  Future<void> searchCompaniesByName(String name) async {
    try {
      isLoading.value = true;
      final results = await _repository.searchCompaniesByName(name);
      companies.assignAll(results); // Atualiza a lista com os resultados da pesquisa
    } catch (e) {
      Get.snackbar("Erro", "Erro ao pesquisar empresas: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
