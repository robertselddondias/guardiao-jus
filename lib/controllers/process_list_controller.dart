import 'package:get/get.dart';
import 'package:guardiao_cliente/enums/feature_status_type.dart';
import 'package:guardiao_cliente/models/processo_model.dart';
import 'package:guardiao_cliente/repositories/processo_repository.dart';
import 'package:guardiao_cliente/widgets/snackbar_custom.dart';

class ProcessListController extends GetxController {
  final ProcessoRepository _processoRepository = ProcessoRepository();

  RxList<ProcessoModel> processos = <ProcessoModel>[].obs;
  RxList<ProcessoModel> filteredProcessos = <ProcessoModel>[].obs;
  RxBool isLoading = false.obs;
  RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProcessos();

    // Inicializa a lista filtrada com todos os processos
    ever(processos, (List<ProcessoModel> processosUpdated) {
      if (searchQuery.value.isEmpty) {
        filteredProcessos.assignAll(processosUpdated);
      } else {
        filterProcesses(searchQuery.value);
      }
    });
  }

  /// **🔹 Buscar todos os processos**
  Future<void> fetchProcessos() async {
    try {
      isLoading.value = true;
      _processoRepository.getProcessosByUser().listen((data) {
        processos.value = data;
        // Se não há pesquisa ativa, mostra todos os processos
        if (searchQuery.value.isEmpty) {
          filteredProcessos.assignAll(data);
        }
      });
    } catch (e) {
      SnackbarCustom.showError("Erro ao carregar processos: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// **🔹 Filtrar processos por query de pesquisa**
  void filterProcesses(String query) {
    searchQuery.value = query;

    if (query.isEmpty) {
      // Se a pesquisa estiver vazia, mostra todos os processos
      filteredProcessos.assignAll(processos);
    } else {
      // Filtra os processos baseado na query
      final queryLower = query.toLowerCase();

      filteredProcessos.assignAll(
        processos.where((process) {
          // Pesquisa no título
          final titleMatch = process.title
              ?.toLowerCase()
              .contains(queryLower) ?? false;

          // Pesquisa no número do processo (verifica se não é null e não é vazio)
          final numberMatch = (process.numeroProcesso != null &&
              process.numeroProcesso!.isNotEmpty)
              ? process.numeroProcesso!
              .toLowerCase()
              .contains(queryLower)
              : false;

          // Pesquisa na descrição
          final descriptionMatch = process.description
              ?.toLowerCase()
              .contains(queryLower) ?? false;

          // Pesquisa no nome do usuário
          final userNameMatch = process.userName
              .toLowerCase()
              .contains(queryLower);

          // Pesquisa no tipo de processo
          final typeMatch = _getProcessTypeLabel(process)
              .toLowerCase()
              .contains(queryLower);

          // Pesquisa no status
          final statusMatch = process.status.label
              .toLowerCase()
              .contains(queryLower);

          // Debug - pode remover depois
          if (process.numeroProcesso != null && process.numeroProcesso!.isNotEmpty) {
            print('Processo ${process.title}: numeroProcesso = "${process.numeroProcesso}"');
          }

          return titleMatch ||
              numberMatch ||
              descriptionMatch ||
              userNameMatch ||
              typeMatch ||
              statusMatch;
        }).toList(),
      );
    }
  }

  /// **🔹 Limpar pesquisa**
  void clearSearch() {
    searchQuery.value = '';
    filteredProcessos.assignAll(processos);
  }

  /// **🔹 Excluir processo**
  Future<void> deleteProcess(String processId) async {
    try {
      isLoading.value = true;
      await _processoRepository.deleteProcesso(processId);

      // Remove da lista principal
      processos.removeWhere((process) => process.id == processId);

      // Remove da lista filtrada também
      filteredProcessos.removeWhere((process) => process.id == processId);

      SnackbarCustom.showSuccess("Processo excluído com sucesso.");
    } catch (e) {
      SnackbarCustom.showError("Erro ao excluir processo: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// **🔹 Obter rótulo do tipo de processo**
  String _getProcessTypeLabel(ProcessoModel process) {
    if (process.isNew && process.type.name == 'PROCEDIMENTO_ADMINISTRATIVO') {
      return 'Procedimento Administrativo';
    } else if (process.isNew && process.type.name == 'PROCESSO') {
      return 'Novo Processo';
    } else {
      return 'Processo Existente';
    }
  }

  /// **🔹 Obter estatísticas dos processos**
  Map<String, int> getProcessStats() {
    final total = processos.length;
    final novos = processos.where((p) => p.isNew).length;
    final existentes = processos.where((p) => !p.isNew).length;
    final administrativos = processos.where((p) =>
    p.type.name == 'PROCEDIMENTO_ADMINISTRATIVO').length;
    final judiciais = processos.where((p) =>
    p.type.name == 'PROCESSO').length;

    return {
      'total': total,
      'novos': novos,
      'existentes': existentes,
      'administrativos': administrativos,
      'judiciais': judiciais,
    };
  }

  /// **🔹 Refresh da lista**
  Future<void> refreshProcesses() async {
    await fetchProcessos();
  }
}
