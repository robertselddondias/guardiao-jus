import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';

class FileUtils {
  // Método para selecionar um arquivo
  static Future<File?> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any, // Permite selecionar qualquer tipo de arquivo
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        FocusManager.instance.primaryFocus?.unfocus();
        return File(result.files.single.path!);
      } else {
        Get.snackbar(
          'Nenhum arquivo selecionado',
          'Por favor, escolha um arquivo válido.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return null;
      }
    } catch (e) {
      Get.snackbar(
        'Erro ao selecionar arquivo',
        'Ocorreu um erro: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return null;
    }
  }

  // Método para abrir um arquivo
  static Future<void> openFile(File file) async {
    try {
      final result = await OpenFilex.open(file.path);

      if (result.type != ResultType.done) {
        Get.snackbar(
          'Erro ao abrir arquivo',
          'Não foi possível abrir o arquivo.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erro ao abrir arquivo',
        'Ocorreu um erro: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
