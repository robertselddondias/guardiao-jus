import 'package:get/get.dart';
import 'package:guardiao_cliente/models/note_model.dart';
import 'package:guardiao_cliente/models/processo_model.dart';
import 'package:guardiao_cliente/repositories/note_repository.dart';
import 'package:guardiao_cliente/repositories/processo_repository.dart';
import 'package:guardiao_cliente/widgets/snackbar_custom.dart';

class ProcessDetailController extends GetxController {
  final ProcessoRepository _processoRepository = ProcessoRepository();
  final NoteRepository _noteRepository = NoteRepository();

  Rx<ProcessoModel?> processo = Rx<ProcessoModel?>(null);
  RxBool isLoading = true.obs;
  RxBool isTimelineExpanded = false.obs;

  final RxList<NoteModel> notas = <NoteModel>[].obs;
  final RxBool isNotasExpanded = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments['processoId'] != null) {
      String processoId = Get.arguments['processoId'];
      fetchProcessDetail(processoId);
      fetchNotas(processoId);
    } else {
      SnackbarCustom.showError("Erro ao carregar detalhes do processo.");
      isLoading.value = false;
    }
  }



  /// 🔹 **Busca detalhes do processo**
  Future<void> fetchProcessDetail(String processoId) async {
    try {
      isLoading.value = true;
      final data = await _processoRepository.getProcessoById(processoId);
      if (data != null) {
        processo.value = data;
      } else {
        SnackbarCustom.showWarning("Processo não encontrado.");
      }
    } catch (e) {
      SnackbarCustom.showError("Erro ao carregar processo: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchNotas(String processId) async {
    try {
      final fetchedNotas = await _noteRepository.fetchNotesByProcessoId(processId);
      notas.assignAll(fetchedNotas);
    } catch (e) {
      SnackbarCustom.showError("Erro ao carregar notas: $e");
    }
  }
}