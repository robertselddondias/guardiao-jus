import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/controllers/proc_administrativo_controller.dart';
import 'package:guardiao_cliente/enums/feature_status_type.dart';
import 'package:guardiao_cliente/models/note_model.dart';
import 'package:guardiao_cliente/models/processo_model.dart';
import 'package:guardiao_cliente/services/file_viewer_service.dart';
import 'package:guardiao_cliente/widgets/guardiao_widget.dart';
import 'package:guardiao_cliente/widgets/snackbar_custom.dart';
import 'package:guardiao_cliente/themes/custom_widgets.dart';
import 'package:guardiao_cliente/utils/date_utils_custom.dart';
import 'package:guardiao_cliente/utils/file_utils.dart';
import 'package:image_picker/image_picker.dart';

class ProcAdministrativoScreen extends StatelessWidget {
  const ProcAdministrativoScreen({super.key});

  void _showFileOptions(BuildContext context,
      ProcAdministrativoController controller, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0, left: 8.0),
          child: Wrap(
            children: [
              _buildOptionTile(
                context,
                icon: Icons.camera_alt,
                label: 'Câmera',
                onTap: () => _pickFile(context, controller, ImageSource.camera),
              ),
              _buildOptionTile(
                context,
                icon: Icons.photo_library,
                label: 'Galeria',
                onTap: () => _pickFile(context, controller, ImageSource.gallery),
              ),
              _buildOptionTile(
                context,
                icon: Icons.folder,
                label: 'Arquivos',
                onTap: () async {
                  Navigator.of(context).pop();
                  File? file = await FileUtils.pickFile();
                  if (file != null) controller.addFile(file);
                },
              ),
              SizedBox(height: 30,)
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickFile(BuildContext context,
      ProcAdministrativoController controller,
      ImageSource source) async {
    Navigator.of(context).pop();
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? xfile = await picker.pickImage(source: source);
      if (xfile != null) {
        controller.addFile(File(xfile.path));
      } else {
        SnackbarCustom.showInfo('Nenhum arquivo selecionado.');
      }
    } catch (e) {
      SnackbarCustom.showError('Erro ao adicionar arquivo.');
    }
  }

  Widget _buildOptionTile(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(label, style: theme.textTheme.bodyLarge),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProcAdministrativoController());
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Proc. Administrativo'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() {
                    final processo = controller.processoModel.value;

                    if (processo == null) {
                      return const Center(child: CircularProgressIndicator()); // 🔄 Exibe carregamento até os dados estarem prontos
                    }

                    return _buildStatusCard(processo, theme);
                  }),
                  const SizedBox(height: 16),
                  _buildFormFields(context, controller),
                  const SizedBox(height: 24),
                  GuardiaoWidget.buildArquivos(
                    context,
                    title: 'Arquivos',
                    onAddPressed: () => _showFileOptions(context, controller, theme),
                    child: Obx(() =>
                    controller.files.isEmpty
                        ? _buildEmptyState(theme, 'Nenhum arquivo adicionado.',
                        Icons.insert_drive_file)
                        : _buildFileList(controller, theme)),
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    return Visibility(
                      visible: controller.notesList.isNotEmpty,
                      child: Text(
                        'Notas Jurídicas',
                        style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  Obx(() {
                    return Visibility(
                      visible: controller.notesList.isNotEmpty,
                      child: Obx(() {
                        if (controller.notesList.isEmpty) {
                          return _buildNoteEmptyState(
                              context, 'Nenhuma nota cadastrada.');
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.notesList.length,
                          itemBuilder: (context, index) {
                            final note = controller.notesList[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: Icon(
                                    Icons.note,
                                    color: theme.colorScheme.primary),
                                title: Text(
                                  note.title,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                subtitle: Text(
                                  note.description ?? '',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                  ),
                                ),
                                onTap: () =>
                                    _showNoteDetailsDialog(context, note),
                              ),
                            );
                          },
                        );
                      }),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () => controller.saveRecord(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  textStyle: theme.textTheme.labelLarge,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 **Card de Status do Processo**
  Widget _buildStatusCard(ProcessoModel processo, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: processo.status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: processo.status.color, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(processo.status.icon, color: processo.status.color, size: 28),
          const SizedBox(width: 12),
          Text(
            processo.status.label,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: processo.status.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields(BuildContext context,
      ProcAdministrativoController controller) {
    return Column(
      children: [
        CustomWidgets.buildTextField(
          context: context,
          label: 'Título *',
          controller: controller.titleController,
        ),
        const SizedBox(height: 16),
        CustomWidgets.buildTextField(
          context: context,
          label: 'Descrição *',
          controller: controller.descriptionController,
          maxLine: 3,
        ),
      ],
    );
  }

  Future<void> openDocument(String url) async {
    try {
      await FileViewerService.openFile(url);
    } catch (e) {
      SnackbarCustom.showError('Erro ao abrir o documento: $e');
    }
  }

  Widget _buildEmptyState(ThemeData theme, String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48,
              color: theme.colorScheme.onSurface.withOpacity(0.5)),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildFileList(ProcAdministrativoController controller,
      ThemeData theme) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: controller.files.length,
      itemBuilder: (context, index) {
        final fileUrl = controller.processoModel.value!.urlFiles!.isNotEmpty
            ? controller.processoModel.value!.urlFiles![index]
            : '';
        final file = controller.files[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: Icon(
                Icons.insert_drive_file, color: theme.colorScheme.primary),
            title: Text(file.path
                .split('/')
                .last, style: theme.textTheme.bodyMedium),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: theme.colorScheme.error),
              onPressed: () => controller.removeFile(file),
            ),
            onTap: () async {
              if (fileUrl.isNotEmpty) {
                await openDocument(fileUrl);
              } else {
                SnackbarCustom.showError('URL do arquivo não disponível.');
              }
            },
          ),
        );
      },
    );
  }

  void _showNoteDetailsDialog(BuildContext context, NoteModel note) {
    final theme = Theme.of(context);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack, // Animação com efeito de suavidade
          ),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Cabeçalho do diálogo com ícone
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.note_alt_rounded,
                          size: 40,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Título da Nota
                  Text(
                    note.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        note.createdAt == null
                            ? 'Data de criação não disponível'
                            : 'Criado em ${DateUtilsCustom.formatDate(
                            note.createdAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(
                              0.7),
                        ),
                        textAlign: TextAlign.center,
                      )
                  ),
                  const SizedBox(height: 16),

                  // Descrição da Nota
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      note.description.isNotEmpty == true
                          ? note.description
                          : 'Nenhuma descrição disponível.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Botão de Fechar
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        foregroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.close),
                      label: const Text('Fechar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildNoteEmptyState(BuildContext context, String message) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}
