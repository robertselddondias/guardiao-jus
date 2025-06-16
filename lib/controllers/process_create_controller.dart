import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/enums/feature_status_type.dart';
import 'package:guardiao_cliente/enums/pedido_type.dart';
import 'package:guardiao_cliente/models/processo_juridico_model.dart';
import 'package:guardiao_cliente/models/processo_model.dart';
import 'package:guardiao_cliente/repositories/processo_repository.dart';
import 'package:guardiao_cliente/services/processo_api_service.dart';
import 'package:guardiao_cliente/services/send_notification_service.dart';
import 'package:guardiao_cliente/widgets/snackbar_custom.dart';
import 'package:guardiao_cliente/utils/Preferences.dart';
import 'package:http/http.dart' as http;
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:path_provider/path_provider.dart';

class ProcessCreateController extends GetxController {
  final ProcessoApiService _processoApiService = ProcessoApiService();

  // Controladores de Texto
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController processNumberController = TextEditingController();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Variáveis de controle
  var isExistingProcess = false.obs;

  var tribunal = ''.obs;
  var tipoProcesso = ''.obs;
  var vara = ''.obs;

  RxBool isLoading = false.obs;

  RxBool isProcesso = false.obs;

  RxList<File> files = <File>[].obs;

  Rx<ProcessoModel?> processModel = Rx<ProcessoModel?>(null);

  Rx<ProcessoJuridicoModel?> processoJuridico = Rx<ProcessoJuridicoModel?>(null);

  final ProcessoRepository _processoRepository = ProcessoRepository();

  final processoMask = MaskTextInputFormatter(
      mask: '#######-##.####.#.##.####',
      filter: {"#": RegExp(r'[0-9]')});


  Future<void> fetchProcessByNumber() async {
    if (processNumberController.text.isEmpty) {
      SnackbarCustom.showInfo("Digite o número do processo.");
      return;
    } else if(processNumberController.text.length != 25) {
      SnackbarCustom.showInfo("Número do processo inválido.");
      return;
    }
    try {
      isLoading.value = true;

      ProcessoModel? processoExists = await _processoRepository.getProcessoByNumero(processNumberController.text);

      if(processoExists != null) {
        SnackbarCustom.showInfo("Este processo já foi enviado ao jurídico.");
        return;
      }

      String numberProcess = apenasNumeros(processNumberController.text);
      final apiResponse = await _processoApiService.consultarProcesso(numberProcess);

      if (apiResponse != null) {
        processoJuridico.value = ProcessoJuridicoModel.fromJson(apiResponse);
      } else {
        SnackbarCustom.showWarning("Nenhum processo encontrado.");
        processoJuridico.value = null;
      }
    } catch (e) {
      SnackbarCustom.showError("Erro ao consultar processo: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveProcess() async {
    if (isExistingProcess.value) {
      if (processNumberController.text.isEmpty) {
        SnackbarCustom.showInfo("Digite o número do processo para salvar.");
        return;
      }
    } else {
      if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
        SnackbarCustom.showInfo("Preencha todos os campos obrigatórios.");
        return;
      }
    }

    try {
      isLoading.value = true;
      PedidoType pedido = PedidoType.PROCEDIMENTO_ADMINISTRATIVO;
      if(isExistingProcess.value) {
        pedido = PedidoType.PROCESSO;
      } else if(!isExistingProcess.value && isProcesso.value) {
        pedido = PedidoType.PROCESSO;
      }

      ProcessoModel processoModel = ProcessoModel(
          userId: Preferences.getString('userId'),
          companyId: Preferences.getString('companyId'),
          isNew: !isExistingProcess.value,
          status: FeatureStatusType.ENVIADO_AO_JURIDICO,
          description: isExistingProcess.value ? "Processo existente cadastrado" : descriptionController.text.trim(),
          title: isExistingProcess.value ? processModel.value?.numeroProcesso : titleController.text.trim(),
          numeroProcesso: processNumberController.text,
          processoJuridico: isExistingProcess.value ? processoJuridico.value! : null,
          createAt: DateTime.now().toIso8601String(),
          type: pedido,
          userName: Preferences.getString('userName')
      );

      if(!isProcesso.value && !isExistingProcess.value) {
        await removeStorageByUrl(processoModel);
        final List<String> fileUrls = await _uploadFilesToStorage();
        processoModel.urlFiles = fileUrls;
      }

      await _processoRepository.createProcesso(processoModel);

      SendNotification.sendNotificationToTopic(
          topic: Preferences.getString('companyId'),
          title: 'Solicitação Jurídica',
          body: '${Preferences.getString('userName')} enviou uma solicitação para a análise jurídica.',
          payload: {'userId': Preferences.getString('userId'), 'processoId': processoModel.id, 'companyId': Preferences.getString('companyId')}
      );
      Get.back();
      SnackbarCustom.showSuccess("Processo salvo com sucesso!");
    } catch (e) {
      SnackbarCustom.showError("Erro ao salvar o processo: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Adicionar arquivo à lista
  // Adicionar arquivo à lista garantindo que o teclado será fechado
  Future<void> addFile(File file) async {
    // 🔹 Remove qualquer foco ativo (impede que o teclado permaneça aberto)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(Get.context!).unfocus();
    });

    // 🔹 Aguarda um curto período antes de adicionar o arquivo (evita travamentos)
    await Future.delayed(const Duration(milliseconds: 100));

    // 🔹 Adiciona o arquivo à lista
    files.add(file);
  }

  // Remover arquivo da lista
  Future<void> removeFile(File file) async {
    files.remove(file);
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

  Future<void> removeStorageByUrl(ProcessoModel processo) async {
    if (processo.urlFiles != null) {
      for (var url in processo.urlFiles!) {
        await _storage.refFromURL(url).delete();
      }
    }
  }

  String apenasNumeros(String input) {
    return input.replaceAll(RegExp(r'[^0-9]'), '');
  }

  void clearFields() {
    titleController.clear();
    descriptionController.clear();
    processNumberController.clear();
    processNumberController.text = '';
    isExistingProcess.value = false;
    processoJuridico.value = null;
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    processNumberController.dispose();
    super.onClose();
  }
}