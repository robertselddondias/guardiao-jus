import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/controllers/process_create_controller.dart';
import 'package:guardiao_cliente/models/assunto_model.dart';
import 'package:guardiao_cliente/widgets/guardiao_widget.dart';
import 'package:guardiao_cliente/widgets/snackbar_custom.dart';
import 'package:guardiao_cliente/themes/custom_widgets.dart';
import 'package:guardiao_cliente/utils/file_utils.dart';
import 'package:guardiao_cliente/widgets/loading_indicator.dart';
import 'package:image_picker/image_picker.dart';

class ProcessCreateScreen extends StatelessWidget {
  const ProcessCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProcessCreateController controller = Get.put(ProcessCreateController());
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text("Solicitação"),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () => _showHelpDialog(context),
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const LoadingIndicator();
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width > 600 ? screenSize.width * 0.08 : 16,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProcessTypeSelector(controller, theme),
                  const SizedBox(height: 16),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: controller.isExistingProcess.value
                        ? _buildExistingProcessSection(controller, theme)
                        : _buildNewProcessSection(context, controller, theme),
                  ),
                ],
              ),
            ),
          );
        }),
        bottomNavigationBar: Container(
          color: Colors.white,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: ElevatedButton(
                onPressed: controller.saveProcess,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  'Salvar Processo',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProcessTypeSelector(ProcessCreateController controller, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_turned_in, color: theme.colorScheme.primary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Opções de Solicitação',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.grey[300],
            margin: const EdgeInsets.symmetric(vertical: 16),
          ),

          Obx(() => Row(
            children: [
              _buildRadioOption(
                label: 'Nova Solicitação',
                value: false,
                groupValue: controller.isExistingProcess.value,
                onChanged: (value) {
                  controller.clearFields();
                  controller.isExistingProcess.value = value!;
                },
              ),
              const SizedBox(width: 12),
              _buildRadioOption(
                label: 'Processo Existente',
                value: true,
                groupValue: controller.isExistingProcess.value,
                onChanged: (value) => controller.isExistingProcess.value = value!,
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildRadioOption({
    required String label,
    required bool value,
    required bool groupValue,
    required Function(bool?) onChanged,
  }) {
    final theme = Theme.of(Get.context!);
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: groupValue == value ? theme.colorScheme.primary : Colors.grey[300]!,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
            color: groupValue == value ? theme.colorScheme.primary.withOpacity(0.1) : Colors.transparent,
          ),
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: groupValue == value ? FontWeight.bold : FontWeight.normal,
                      color: groupValue == value ? theme.colorScheme.primary : Colors.grey[700],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewProcessSection(BuildContext context, ProcessCreateController controller, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment, color: theme.colorScheme.primary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Cadastro de Pedido",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.grey[300],
            margin: const EdgeInsets.symmetric(vertical: 16),
          ),

          Text(
            "Tipo de Pedido",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => Row(
            children: [
              _buildRadioOption(
                label: 'Proced. Administrativo',
                value: false,
                groupValue: controller.isProcesso.value,
                onChanged: (value) => controller.isProcesso.value = value!,
              ),
              const SizedBox(width: 12),
              _buildRadioOption(
                label: 'Processo Judicial',
                value: true,
                groupValue: controller.isProcesso.value,
                onChanged: (value) => controller.isProcesso.value = value!,
              ),
            ],
          )),
          const SizedBox(height: 16),

          CustomWidgets.buildTextField(
            context: context,
            label: 'Título',
            controller: controller.titleController,
          ),
          const SizedBox(height: 16),

          CustomWidgets.buildTextField(
            context: context,
            label: 'Descrição',
            controller: controller.descriptionController,
            maxLine: 3,
          ),
          const SizedBox(height: 16),

          GuardiaoWidget.buildArquivos(
            context,
            title: 'Arquivos',
            onAddPressed: () => _showFileOptions(context, controller),
            child: Obx(() =>
            controller.files.isEmpty
                ? _buildEmptyState(theme, 'Nenhum arquivo adicionado.', Icons.insert_drive_file)
                : _buildFileList(controller, theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExistingProcessSection(ProcessCreateController controller, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Buscar Processo Existente',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: CustomWidgets.buildTextFieldMask(
                  context: Get.context!,
                  label: 'Número do Processo',
                  controller: controller.processNumberController,
                  keyboardType: TextInputType.number,
                  mask: controller.processoMask,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: controller.fetchProcessByNumber,
                  icon: const Icon(Icons.search, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Obx(() {
            if (controller.processoJuridico.value != null) {
              return _buildProcessDetails(controller, theme);
            } else {
              return const SizedBox.shrink();
            }
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessDetails(ProcessCreateController controller, ThemeData theme) {
    final process = controller.processoJuridico.value!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Icon(Icons.article_outlined, color: theme.colorScheme.primary, size: 26),
                const SizedBox(width: 8),
                Text(
                  "Dados do Processo",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          _buildDetailRow(theme, Icons.account_balance, process.tribunal),
          _buildDetailRow(theme, Icons.book, process.classeNome),
          _buildDetailRow(theme, Icons.format_list_bulleted, process.formatoNome),
          _buildDetailRow(theme, Icons.gavel, process.orgaoJulgador.nome),

          const SizedBox(height: 12),

          _buildAssuntosList(process.assuntos, theme),
        ],
      ),
    );
  }

  void _showFileOptions(BuildContext context, ProcessCreateController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Adicionar Arquivo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 20),

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
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickFile(BuildContext context, ProcessCreateController controller, ImageSource source) async {
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
    } finally {
      FocusManager.instance.primaryFocus?.unfocus();
      Navigator.of(context).pop();
    }
  }

  Widget _buildOptionTile(BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(label, style: theme.textTheme.bodyLarge),
      onTap: onTap,
    );
  }

  Widget _buildDetailRow(ThemeData theme, IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssuntosList(List<AssuntoModel> assuntos, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(Icons.topic_rounded, color: theme.colorScheme.primary, size: 26),
              const SizedBox(width: 8),
              Text(
                "Assuntos Relacionados",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),

        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: assuntos.map((assunto) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.label_important_rounded, color: theme.colorScheme.primary, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    assunto.nome,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFileList(ProcessCreateController controller, ThemeData theme) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.files.length,
      itemBuilder: (context, index) {
        final file = controller.files[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: ListTile(
            leading: Icon(Icons.insert_drive_file, color: theme.colorScheme.primary),
            title: Text(
              file.path.split('/').last,
              style: TextStyle(fontSize: 14),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => controller.removeFile(file),
            ),
          ),
        );
      },
    );
  }

  void _showHelpDialog(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final bool isLargeScreen = screenSize.width > 600;

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
            curve: Curves.easeOutBack,
          ),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: isLargeScreen ? screenSize.width * 0.5 : screenSize.width * 0.9,
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 24 : 16,
                vertical: isLargeScreen ? 24 : 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                      padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.article_outlined,
                        size: isLargeScreen ? 60 : 50,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    "Como funciona a criação de um novo processo?",
                    style: TextStyle(
                      fontSize: isLargeScreen ? 20 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  _buildHelpSection(
                    theme,
                    icon: Icons.account_balance,
                    title: "Procedimento Administrativo",
                    description: "Utilizado para questões internas, como sindicâncias, recursos administrativos e regularizações dentro da corporação. Não há envolvimento direto do Poder Judiciário.",
                  ),

                  _buildHelpSection(
                    theme,
                    icon: Icons.gavel,
                    title: "Processo Judicial",
                    description: "Ação movida no Judiciário para resolver disputas legais, garantir direitos ou contestar decisões. Pode envolver advogados, juízes e prazos legais.",
                  ),

                  _buildHelpSection(
                    theme,
                    icon: Icons.search,
                    title: "Número de Processo Existente",
                    description: "Caso já possua um número de processo em andamento, você pode vinculá-lo ao sistema para acompanhamento e atualizações.",
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: EdgeInsets.symmetric(
                          vertical: isLargeScreen ? 16 : 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Entendi",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isLargeScreen ? 18 : 16,
                          color: Colors.white,
                        ),
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

  Widget _buildHelpSection(ThemeData theme, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final screenSize = MediaQuery.of(Get.context!).size;
    final bool isLargeScreen = screenSize.width > 600;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isLargeScreen ? 10 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: isLargeScreen ? 32 : 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isLargeScreen ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: isLargeScreen ? 16 : 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
