import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class FileViewerService {
  /// Abre um arquivo de uma URL (PDF, imagem ou vídeo).
  static Future<void> openFile(String url) async {
    try {
      // Determinar a extensão do arquivo
      final String extension = _extractFileExtension(url);

      // Fazer o download do arquivo
      final File file = await _downloadFile(url);

      // Abrir o arquivo baseado na extensão
      if (extension == 'pdf' || extension == 'jpg' || extension == 'png') {
        await OpenFilex.open(file.path);
      } else if (extension == 'mp4' || extension == 'avi' || extension == 'mov') {
        await OpenFilex.open(file.path);
      } else {
        throw Exception("Tipo de arquivo não suportado.");
      }
    } catch (e) {
      debugPrint("Erro ao abrir o arquivo: $e");
      throw Exception("Erro ao abrir o arquivo: $e");
    }
  }

  /// Faz o download do arquivo para o diretório temporário.
  static Future<File> _downloadFile(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final String fileName = url.split('/').last.split('?').first;
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath = '${tempDir.path}/$fileName';
      final File file = File(filePath);

      await file.writeAsBytes(response.bodyBytes);
      return file;
    } else {
      throw Exception("Erro ao fazer o download do arquivo.");
    }
  }

  /// Extrai a extensão do arquivo de uma URL.
  static String _extractFileExtension(String url) {
    final RegExp regex = RegExp(r'\.([a-zA-Z0-9]+)(\?|$)');
    final Match? match = regex.firstMatch(url);

    if (match != null) {
      return match.group(1)!.toLowerCase();
    } else {
      throw Exception("Extensão do arquivo não encontrada.");
    }
  }
}
