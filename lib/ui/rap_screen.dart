import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/controllers/rap_controller.dart';
import 'package:guardiao_cliente/enums/feature_status_type.dart';
import 'package:guardiao_cliente/models/rap_model.dart';
import 'package:guardiao_cliente/services/file_viewer_service.dart';
import 'package:guardiao_cliente/widgets/guardiao_widget.dart';
import 'package:guardiao_cliente/widgets/snackbar_custom.dart';
import 'package:guardiao_cliente/themes/app_colors.dart';
import 'package:guardiao_cliente/themes/custom_widgets.dart';
import 'package:guardiao_cliente/utils/file_utils.dart';
import 'package:guardiao_cliente/widgets/loading_indicator.dart';
import 'package:image_picker/image_picker.dart';

class RapScreen extends StatelessWidget {
  const RapScreen({super.key});

  void _showFileOptions(BuildContext context, RapController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0, left: 16),
          child: Wrap(
            children: [
              _buildOptionTile(
                context,
                icon: Icons.camera_alt,
                label: 'Câmera',
                onTap: () {
                  _pickFile(context, controller, ImageSource.camera);
                },
              ),
              _buildOptionTile(
                  context,
                  icon: Icons.photo_library,
                  label: 'Galeria',
                  onTap: () {
                    _pickFile(context, controller, ImageSource.gallery);
                  }
              ),
              _buildOptionTile(
                context,
                icon: Icons.folder,
                label: 'Arquivos',
                onTap: () async {
                  Navigator.of(context).pop();
                  File? file = await FileUtils.pickFile();
                  if (file != null) controller.addFile(file);
                  FocusManager.instance.primaryFocus?.unfocus();
                },
              ),
              SizedBox(height: 20)
            ],
          ),
        );
      },
    );
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<void> _pickFile(BuildContext context, RapController controller,
      ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? xfile = await picker.pickImage(source: source);
      if (xfile != null) {
        controller.addFile(File(xfile.path));
        FocusManager.instance.primaryFocus?.unfocus();
      } else {
        SnackbarCustom.showInfo('Nenhum arquivo selecionado.');
      }
    } catch (e) {
      SnackbarCustom.showError('Erro ao adicionar arquivo.');
    } finally {
      FocusManager.instance.primaryFocus?.unfocus();
      Navigator.of(context).pop();
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
    final controller = Get.put(RapController());
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('RAP'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context), // 🔹 Abre o diálogo de ajuda
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const LoadingIndicator();
          }
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(theme, controller),
                    const SizedBox(height: 16),
                    _buildFormFields(context, controller, theme),
                    const SizedBox(height: 24),
                    GuardiaoWidget.buildArquivos(
                      context,
                      title: 'Arquivos',
                      onAddPressed: () => _showFileOptions(context, controller),
                      child: Obx(() =>
                      controller.files.isEmpty
                          ? _buildEmptyState(
                          theme, 'Nenhum arquivo adicionado.',
                          Icons.insert_drive_file)
                          : _buildFileList(controller, theme)),
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      return Visibility(
                          visible: controller.notesList.isNotEmpty,
                          child: GuardiaoWidget.buildNotesSection(controller.notesList, theme)
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
      bottomNavigationBar:
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() {
                return Visibility(
                  visible: controller.verifyButtonFlag.value,
                  child: ElevatedButton(
                    onPressed: () async => await controller.sendToCompany(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      textStyle: theme.textTheme.labelLarge,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Enviar para Jurídico'),
                  ),
                );
              }),
              const SizedBox(height: 8),
              Obx(() {
                return Visibility(
                  visible: !controller.isLoading.value,
                  child: ElevatedButton(
                    onPressed: () => controller.saveRecord(context),
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
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 **Card de Status do Processo**
  Widget _buildStatusCard(RapModel rap, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rap.status!.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: rap.status!.color, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(rap.status!.icon, color: rap.status!.color, size: 28),
          const SizedBox(width: 12),
          Text(
            rap.status!.label,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: rap.status!.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCardNone(String status, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.warning, size: 28),
          const SizedBox(width: 12),
          Text(
            status,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildHeader(ThemeData theme, RapController controller) {
    return Obx(() => Column(
      children: [
        controller.rapModel.value.status != null
            ? _buildStatusCard(controller.rapModel.value, theme)
            : Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.assignment_turned_in_outlined,
                  color: theme.colorScheme.primary, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Cadastro de RAP: Registre atividades policiais, adicione arquivos e acompanhe o processo.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }

  Widget _buildFormFields(BuildContext context, RapController controller, ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GuardiaoWidget.buildSectionTitle("Informações do Rap", theme),
            const SizedBox(height: 12),
            CustomWidgets.buildTextField(
                context: context,
                label: 'Título *',
                controller: controller.titleController,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences
            ),
            const SizedBox(height: 16),
            CustomWidgets.buildDateField(
              context: context,
              label: 'Data da Ocorrência *',
              controller: controller.dtOcorrenciaController,
            ),
            const SizedBox(height: 16),
            CustomWidgets.buildTextField(
                context: context,
                label: 'Descrição *',
                controller: controller.descriptionController,
                maxLine: 3,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.text
            ),
          ],
        ),
      ),
    );
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

  Widget _buildFileList(RapController controller, ThemeData theme) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: controller.files.length,
      itemBuilder: (context, index) {
        final file = controller.files[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            onTap: () => {
              openDocument(controller.rapModel.value.urlFiles![index])
            },
            leading: Icon(
                Icons.insert_drive_file, color: theme.colorScheme.primary),
            title: Text(file.path
                .split('/')
                .last, style: theme.textTheme.bodyMedium),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: theme.colorScheme.error),
              onPressed: () => controller.removeFile(file),
            ),
          ),
        );
      },
    );
  }

  Future<void> openDocument(String url) async {
    try {
      await FileViewerService.openFile(url);
    } catch (e) {
      SnackbarCustom.showError('Erro ao abrir o documento: $e');
    }
  }

  void _showHelpDialog(BuildContext context) {
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
            curve: Curves.easeOutBack, // Suavidade na animação
          ),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ícone animado
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.5, end: 1),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.info_outline,
                        size: 50,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Título estilizado
                  Text(
                    "O que é o Cadastro de RAP?",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Descrição principal
                  Text(
                    "RAP significa **Registro de Atividade Policial**. Esse sistema permite que policiais registrem ocorrências, adicionem arquivos e compartilhem informações relevantes para análise jurídica.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 12),

                  // Segunda parte do texto
                  Text(
                    "O objetivo é facilitar o acompanhamento e a organização das atividades policiais, garantindo transparência e eficiência no trabalho.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 24),

                  // Botão estilizado
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Entendi",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
}
