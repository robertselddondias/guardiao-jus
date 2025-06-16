import 'package:get/get.dart';
import 'package:guardiao_cliente/models/processo_model.dart';
import 'package:guardiao_cliente/repositories/processo_repository.dart';
import 'package:guardiao_cliente/widgets/snackbar_custom.dart';

class ProcessListController extends GetxController {
  final ProcessoRepository _processoRepository = ProcessoRepository();

  RxList<ProcessoModel> processos = <ProcessoModel>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProcessos();
  }

  /// **🔹 Buscar todos os processos**
  Future<void> fetchProcessos() async {
    try {
      isLoading.value = true;
      _processoRepository.getProcessosByUser().listen((data) {
        processos.value = data;
      });
    } catch (e) {
      SnackbarCustom.showError("Erro ao carregar processos: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// **🔹 Excluir processo**
  Future<void> deleteProcess(String processId) async {
    try {
      isLoading.value = true;
      await _processoRepository.deleteProcesso(processId);
      processos.removeWhere((process) => process.id == processId);
      SnackbarCustom.showSuccess("Processo excluído com sucesso.");
    } catch (e) {
      SnackbarCustom.showError("Erro ao excluir processo: $e");
    } finally {
      isLoading.value = false;
    }
  }
}