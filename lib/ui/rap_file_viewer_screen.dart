import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class RapFileViewerScreen extends StatelessWidget {
  final File file;

  const RapFileViewerScreen({super.key, required this.file});

  // Determinar a extensão do arquivo
  String extractFileExtension(String url) {
    if (url.contains('.pdf')) {
      return 'pdf';
    }
    return '';
  }

  // Compartilhar ou salvar o arquivo
  Future<void> _shareOrSaveFile(BuildContext context) async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        Share.shareXFiles([XFile(file.path)]);
      } else {
        throw Exception("Plataforma não suportada para compartilhamento.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao compartilhar o arquivo: $e"),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final extension = extractFileExtension(file.path);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Visualizar Arquivo",
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.download, color: theme.colorScheme.onPrimary),
            onPressed: () => _shareOrSaveFile(context),
          ),
        ],
      ),
      body: SafeArea(
        child: extension == 'pdf'
            ? SfPdfViewer.file(
          file,
          onDocumentLoadFailed: (details) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Erro ao carregar o PDF: ${details.error}",
                  style: theme.textTheme.bodyMedium,
                ),
                duration: const Duration(seconds: 4),
              ),
            );
          },
        )
            : LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final maxHeight = constraints.maxHeight;

            return Center(
              child: SizedBox(
                width: maxWidth > 600 ? 600 : maxWidth * 0.9,
                height: maxHeight * 0.8,
                child: Image.file(
                  file,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Text(
                      "Erro ao abrir a imagem.",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
