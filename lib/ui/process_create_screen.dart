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
        FocusScope.of(context).unfocus(); // Fecha o teclado ao tocar fora
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Solicitação"),
          backgroundColor: theme.colorScheme.primary,
          centerTitle: true,
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
                        : _buildNewProcessSection(context,controller, theme),
                  ),
                ],
              ),
            ),
          );
        }),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: ElevatedButton(
              onPressed: controller.saveProcess,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Salvar Processo',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// **Seleção entre Processo Novo ou Existente**
  Widget _buildProcessTypeSelector(ProcessCreateController controller, ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 **Título da Seção**
            Row(
              children: [
                Icon(Icons.assignment_turned_in, color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Opções de Solicitação',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(thickness: 1, height: 16),

            // 🔹 **Seleção de Tipo de Processo**
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
      ),
    );
  }

  /// **Opção de Seleção Sem Ícones**
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
            border: Border.all(color: groupValue == value ? theme.colorScheme.primary : Colors.grey),
            borderRadius: BorderRadius.circular(12),
            color: groupValue == value ? theme.colorScheme.primary.withOpacity(0.1) : Colors.transparent,
          ),
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return FittedBox(
                  fit: BoxFit.scaleDown, // 🔹 Ajusta automaticamente para caber no espaço disponível
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: groupValue == value ? FontWeight.bold : FontWeight.normal,
                      color: groupValue == value ? theme.colorScheme.primary : Colors.black87,
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

  /// **Seção para um Processo Novo**
  Widget _buildNewProcessSection(BuildContext context, ProcessCreateController controller, ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 **Título da Seção**
            Row(
              children: [
                Icon(Icons.assignment, color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Cadastro de Pedido",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(thickness: 1, height: 16),

            // 🔹 **Seletor de Tipo de Pedido**
            Text(
              "Tipo de Pedido",
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
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

            // 🔹 **Campos de Entrada**
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

            // 🔹 **Seção de Arquivos**
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
      ),
    );
  }

  Widget _buildExistingProcessSection(ProcessCreateController controller, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            ElevatedButton(
              onPressed: controller.fetchProcessByNumber,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.all(14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Icon(Icons.search, color: Colors.white, size: 24),
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

  /// 🔹 **Exibir detalhes do processo com um layout moderno e bem estruturado**
  Widget _buildProcessDetails(ProcessCreateController controller, ThemeData theme) {
    final process = controller.processoJuridico.value!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📌 **Título "DADOS DO PROCESSO" com Ícone**
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Icon(Icons.article_outlined, color: theme.colorScheme.primary, size: 26),
                const SizedBox(width: 8),
                Text(
                  "Dados do Processo",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          // 📊 **Informações do Processo com Ícones**
          _buildDetailRow(theme, Icons.account_balance, process.tribunal),
          _buildDetailRow(theme, Icons.book, process.classeNome),
          _buildDetailRow(theme, Icons.format_list_bulleted, process.formatoNome),
          _buildDetailRow(theme, Icons.gavel, process.orgaoJulgador.nome),

          const SizedBox(height: 12), // 📏 Melhor espaçamento

          // 📌 **Lista de Assuntos com Estilo Moderno**
          _buildAssuntosList(process.assuntos, theme),
        ],
      ),
    );
  }

  void _showFileOptions(BuildContext context, ProcessCreateController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0, left: 16.0),
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
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickFile(BuildContext context, ProcessCreateController controller,
      ImageSource source) async {

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

  Widget _buildOptionTile(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(label, style: theme.textTheme.bodyLarge),
      onTap: onTap,
    );
  }

  /// 🔹 **Linha de Detalhes do Processo com Ícone**
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
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 **Lista de Assuntos com Visual Melhorado**
  Widget _buildAssuntosList(List<AssuntoModel> assuntos, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 📌 **Título da seção com Ícone**
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(Icons.topic_rounded, color: theme.colorScheme.primary, size: 26),
              const SizedBox(width: 8),
              Text(
                "Assuntos Relacionados",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),

        // 📌 **Lista de Assuntos como "tags" modernas**
        Wrap(
          spacing: 12, // Espaçamento horizontal entre os itens
          runSpacing: 8, // Espaçamento vertical entre os itens
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
                    style: theme.textTheme.bodyMedium?.copyWith(
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

  Widget _buildSection(BuildContext context,
      {required String title, VoidCallback? onAddPressed, required Widget child}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            if (onAddPressed != null)
              IconButton(
                icon: Icon(Icons.add, color: theme.colorScheme.primary),
                onPressed: onAddPressed,
              ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildFileList(ProcessCreateController controller, ThemeData theme) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: controller.files.length,
      itemBuilder: (context, index) {
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
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔹 Ícone com efeito de destaque
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

                  // 🔹 Título estilizado
                  Text(
                    "Como funciona a criação de um novo processo?",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isLargeScreen ? 20 : 18,
                      color: theme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // 🔹 Explicações detalhadas
                  _buildHelpSection(
                    theme,
                    icon: Icons.account_balance,
                    title: "Procedimento Administrativo",
                    description:
                    "Utilizado para questões **internas**, como sindicâncias, recursos administrativos e regularizações dentro da corporação. Não há envolvimento direto do Poder Judiciário.",
                  ),

                  _buildHelpSection(
                    theme,
                    icon: Icons.gavel,
                    title: "Processo Judicial",
                    description:
                    "Ação movida no **Judiciário** para resolver disputas legais, garantir direitos ou contestar decisões. Pode envolver advogados, juízes e prazos legais.",
                  ),

                  _buildHelpSection(
                    theme,
                    icon: Icons.search,
                    title: "Número de Processo Existente",
                    description:
                    "Caso já possua um número de processo em andamento, você pode vinculá-lo ao sistema para acompanhamento e atualizações.",
                  ),

                  const SizedBox(height: 24),

                  // 🔹 Botão estilizado
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(
                          vertical: isLargeScreen ? 16 : 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Entendi",
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isLargeScreen ? 18 : 16,
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

  /// 🔹 **Seção explicativa do diálogo**
  Widget _buildHelpSection(ThemeData theme,
      {required IconData icon, required String title, required String description}) {
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
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isLargeScreen ? 18 : 16,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: isLargeScreen ? 16 : 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
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