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
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(
            "Erro ao compartilhar o arquivo: $e",
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          "Visualizar Arquivo",
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        centerTitle: true,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.download_rounded,
                color: theme.colorScheme.onPrimary,
                size: 22,
              ),
              onPressed: () => _shareOrSaveFile(context),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.background,
          ),
          child: extension == 'pdf'
              ? Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withOpacity(isDark ? 0.3 : 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SfPdfViewer.file(
                file,
                onDocumentLoadFailed: (details) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: theme.colorScheme.error,
                      content: Text(
                        "Erro ao carregar o PDF: ${details.error}",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onError,
                        ),
                      ),
                      duration: const Duration(seconds: 4),
                    ),
                  );
                },
              ),
            ),
          )
              : LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final maxHeight = constraints.maxHeight;

              return Center(
                child: Container(
                  width: maxWidth > 600 ? 600 : maxWidth * 0.9,
                  height: maxHeight * 0.8,
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withOpacity(isDark ? 0.3 : 0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      file,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.error.withOpacity(0.2),
                                    theme.colorScheme.error.withOpacity(0.1),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.error_outline_rounded,
                                size: 48,
                                color: theme.colorScheme.error,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Erro ao abrir a imagem",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.error,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "O arquivo pode estar corrompido ou em formato não suportado",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}