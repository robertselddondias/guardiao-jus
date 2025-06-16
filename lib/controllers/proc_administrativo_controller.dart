import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/models/note_model.dart';
import 'package:guardiao_cliente/models/processo_model.dart';
import 'package:guardiao_cliente/repositories/note_repository.dart';
import 'package:guardiao_cliente/repositories/processo_repository.dart';
import 'package:guardiao_cliente/widgets/snackbar_custom.dart';
import 'package:guardiao_cliente/utils/Preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ProcAdministrativoController extends GetxController {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  final NoteRepository _noteRepository = NoteRepository();

  final ProcessoRepository _processoRepository = ProcessoRepository();

  DateTime? dtAudience;
  RxList<File> files = <File>[].obs;

  final FirebaseStorage _storage = FirebaseStorage.instance;

  RxString processoId = ''.obs;
  Rx<ProcessoModel?> processoModel = Rx<ProcessoModel?>(null);
  RxString companyId = ''.obs;

  RxInt notesCount = 0.obs;

  RxList<NoteModel> notesList = <NoteModel>[].obs;

  RxBool isLoading = false.obs;

  @override
  void onInit() async {
    companyId.value = Preferences.getString('companyId');
    await fetchLoadEdit();
    fetchNotes();
    super.onInit();
  }

  Future<void> fetchLoadEdit() async {
    if(Get.arguments != null) {
      try {
        final Map<String, dynamic> args = Get.arguments;
        processoId.value = args['processoId'];

        processoModel.value = await _processoRepository.getProcessoById(processoId.value);

        if (processoModel.value!.id!.isNotEmpty) {
          titleController.text = processoModel.value!.title!;
          descriptionController.text = processoModel.value!.description!;

          // Carrega os arquivos e anotações
          for (var url in processoModel.value!.urlFiles ?? []) {
            files.add(await urlToFile(url));
          }
          update();
        }
      } catch (e) {
        SnackbarCustom.showError('Erro ao carregar os dados: $e');
      }
    }
  }

  // Adicionar arquivo à lista
  Future<void> addFile(File file) async {
    files.add(file);
  }

  // Remover arquivo da lista
  Future<void> removeFile(File file) async {
    files.remove(file);
  }

  // Salvar informações no Firestore com URLs do Storage
  Future<void> saveRecord() async {
    if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
      SnackbarCustom.showWarning("Por favor, preencha os campos obrigatórios.");
      return;
    }

    isLoading.value = true;
    try {
      await removeStorageByUrl(processoModel.value!);

      // Upload dos arquivos para o Firebase Storage
      final List<String> fileUrls = await _uploadFilesToStorage();


        processoModel.value?.title = titleController.text;
        processoModel.value?.description = descriptionController.text;
        processoModel.value?.urlFiles = fileUrls;
        await _processoRepository.updateProcesso(processoId.value, processoModel.value!);


      SnackbarCustom.showSuccess("Proc. Administrativo salvo com sucesso!");
      // clearForm();
    } catch (e) {
      e.printInfo();
      SnackbarCustom.showError("Erro ao salvar o Proc. Administrativo: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Buscar notas associadas ao Proc. Administrativo
  Future<void> fetchNotes() async {
    try {
      final notes = await _noteRepository.fetchNotesByRapId(processoId.value);
      notesList.value = notes;
      notesCount.value = notes.length;
    } catch (e) {
      SnackbarCustom.showError('Erro ao carregar as notas: $e');
    }
  }

  // Função para fazer o upload dos arquivos para o Firebase Storage
  Future<List<String>> _uploadFilesToStorage() async {
    List<String> fileUrls = [];

    for (File file in files) {
      try {
        String fileName = "${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}";
        Reference storageRef = _storage
            .ref()
            .child('processos/${Preferences.getString('userId')}/$fileName');

        // Upload do arquivo
        UploadTask uploadTask = storageRef.putFile(file);
        TaskSnapshot snapshot = await uploadTask;

        // Obter a URL do arquivo
        String fileUrl = await snapshot.ref.getDownloadURL();
        fileUrls.add(fileUrl);
      } catch (e) {
        SnackbarCustom.showWarning("Erro ao fazer upload de ${file.path.split('/').last}: $e");
      }
    }

    return fileUrls;
  }

  // Limpar o formulário após salvar
  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    dtAudience = null;
    files.clear();
  }

  Future<File> urlToFile(String imageUrl) async {
    try {
      final http.Response response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        final Directory tempDir = await getTemporaryDirectory();
        final String tempPath = tempDir.path;

        String extension = '.jpg';
        if (imageUrl.contains('.pdf')) {
          extension = '.pdf';
        } else if (imageUrl.contains('.png')) {
          extension = '.png';
        }

        final File file = File('$tempPath/processo_${DateTime.now().microsecond}$extension');
        return await file.writeAsBytes(response.bodyBytes);
      } else {
        throw Exception('Erro ao fazer download do arquivo');
      }
    } catch (e) {
      throw Exception('Erro ao converter URL em File: $e');
    }
  }

  Future<void> removeStorageByUrl(ProcessoModel processo) async {
    if (processo.urlFiles != null) {
      for (var url in processo.urlFiles!) {
        await _storage.refFromURL(url).delete();
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
