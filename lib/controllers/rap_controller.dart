import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/enums/feature_status_type.dart';
import 'package:guardiao_cliente/models/note_model.dart';
import 'package:guardiao_cliente/models/rap_model.dart';
import 'package:guardiao_cliente/models/user_model.dart';
import 'package:guardiao_cliente/repositories/note_repository.dart';
import 'package:guardiao_cliente/repositories/rap_repository.dart';
import 'package:guardiao_cliente/repositories/user_repository.dart';
import 'package:guardiao_cliente/services/send_notification_service.dart';
import 'package:guardiao_cliente/widgets/snackbar_custom.dart';
import 'package:guardiao_cliente/utils/Preferences.dart';
import 'package:guardiao_cliente/utils/date_utils_custom.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class RapController extends GetxController {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final dtOcorrenciaController = TextEditingController();

  final NoteRepository _noteRepository = NoteRepository();

  final RapRepository _featureRepository = RapRepository();

  DateTime? dtAudience;
  RxList<File> files = <File>[].obs;

  final FirebaseStorage _storage = FirebaseStorage.instance;

  final UserRepository _userRepository = UserRepository();

  RxString rapId = ''.obs;
  Rx<RapModel> rapModel = RapModel().obs;
  RxString companyId = ''.obs;

  RxInt notesCount = 0.obs;

  RxList<NoteModel> notesList = <NoteModel>[].obs;

  RxBool verifyButtonFlag = false.obs;

  RxBool isLoading = false.obs;

  @override
  void onInit() async {
    super.onInit();
    companyId.value = Preferences.getString('companyId');
    isLoading.value = true;
    await fetchLoadEdit();
    await fetchNotes();
    verifyButton();
    isLoading.value = false;
  }

  Future<void> fetchLoadEdit() async {
    if(Get.arguments != null) {
      try {
        final Map<String, dynamic> args = Get.arguments;
        rapId.value = args['rapId'];

        rapModel.value = await _featureRepository.fetchById(rapId.value);

        if (rapModel.value.id!.isNotEmpty) {
          titleController.text = rapModel.value.title!;
          descriptionController.text = rapModel.value.description!;
          dtOcorrenciaController.text = rapModel.value.dtOcorrencia != null
              ? DateUtilsCustom.formatDate(rapModel.value.dtOcorrencia!)
              : '';

          // Carrega os arquivos e anotações
          for (var url in rapModel.value.urlFiles ?? []) {
            files.add(await urlToFile(url));
          }
          update();
        }
      } catch (e) {
        SnackbarCustom.showError('Erro ao carregar os dados: $e');
      }
    }
  }

  Future<void> verifyButton() async {
    verifyButtonFlag.value = Preferences
        .getString('companyId')
        .isNotEmpty
        && rapModel.value.companyId == null &&
        rapModel.value.id != null;
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
  Future<void> saveRecord(BuildContext context) async {
    if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
      SnackbarCustom.showWarning("Por favor, preencha os campos obrigatórios.");
      return;
    }

    isLoading.value = true;
    try {
      await removeStorageByUrl(rapModel.value);

      // Upload dos arquivos para o Firebase Storage
      final List<String> fileUrls = await _uploadFilesToStorage(context);

      if (rapModel.value.id == null) {
        UserModel userModel = await _userRepository.getUserById();
        rapModel.value = RapModel(
            title: titleController.text,
            description: descriptionController.text,
            dtOcorrencia: DateUtilsCustom.formatDateISO(dtOcorrenciaController.text),
            urlFiles: fileUrls,
            userId: userModel.uid,
            userName: userModel.name,
            createAt: DateTime.now().toIso8601String()
        );
        await _featureRepository.createRap(rapModel.value);
      } else {
        rapModel.value.title = titleController.text;
        rapModel.value.description = descriptionController.text;
        rapModel.value.dtOcorrencia = DateUtilsCustom.formatDateISO(dtOcorrenciaController.text);
        rapModel.value.urlFiles = fileUrls;
        await _featureRepository.updateRap(rapModel.value.id!, rapModel.value);
      }

      verifyButton();
      SnackbarCustom.showSuccess("RAP salvo com sucesso!");
    } catch (e) {
      e.printInfo();
      SnackbarCustom.showError("Erro ao salvar o RAP: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Buscar notas associadas ao RAP
  Future<void> fetchNotes() async {
    try {
      final notes = await _noteRepository.fetchNotesByRapId(rapId.value);
      notesList.value = notes;
      notesCount.value = notes.length;
    } catch (e) {
      SnackbarCustom.showError('Erro ao carregar as notas: $e');
    }
  }

  // Função para fazer o upload dos arquivos para o Firebase Storage
  Future<List<String>> _uploadFilesToStorage(BuildContext context) async {
    List<String> fileUrls = [];

    for (File file in files) {
      try {
        String fileName = "${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}";
        Reference storageRef = _storage
            .ref()
            .child('raps/${Preferences.getString('userId')}/$fileName');

        // Upload do arquivo
        UploadTask uploadTask = storageRef.putFile(file);
        TaskSnapshot snapshot = await uploadTask;

        // Obter a URL do arquivo
        String fileUrl = await snapshot.ref.getDownloadURL();
        fileUrls.add(fileUrl);
      } catch (e) {
        SnackbarCustom.showWarning("Erro ao fazer upload de ${file.path.split('/').last}: $e");
      } finally {
        FocusScope.of(context).unfocus();
      }
    }

    return fileUrls;
  }

  // Limpar o formulário após salvar
  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    dtOcorrenciaController.clear();
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

        final File file = File('$tempPath/rap_${DateTime.now().microsecond}$extension');
        return await file.writeAsBytes(response.bodyBytes);
      } else {
        throw Exception('Erro ao fazer download do arquivo');
      }
    } catch (e) {
      throw Exception('Erro ao converter URL em File: $e');
    }
  }

  Future<void> removeStorageByUrl(RapModel rap) async {
    if (rap.urlFiles != null) {
      for (var url in rap.urlFiles!) {
        await _storage.refFromURL(url).delete();
      }
    }
  }

  Future<void> sendToCompany() async {
    isLoading.value = true;

    var companyId = Preferences.getString('companyId');

    rapModel.value.companyId = companyId;
    rapModel.value.status = FeatureStatusType.ENVIADO_AO_JURIDICO;
    await _featureRepository.updateRap(rapModel.value.id!, rapModel.value);

    UserModel? user = UserRepository().getCurrentUser();
    
    SendNotification.sendNotificationToTopic(
        topic: companyId,
        title: 'RAP Recebido',
        body: '${user!.name} enviou um RAP para a análise jurídica.',
        payload: {'userId': user.uid, 'rapId': rapId.value, 'companyId': companyId}
    );

    isLoading.value = false;
    Get.back();
    SnackbarCustom.showSuccess('RAP enviado ao jurídico com sucesso.');
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    dtOcorrenciaController.dispose();
    super.dispose();
  }
}
