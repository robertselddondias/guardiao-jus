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
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text("Nova Solicitação"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          foregroundColor: theme.colorScheme.primary,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(Icons.help_outline_rounded, color: theme.colorScheme.primary),
                onPressed: () => _showHelpDialog(context),
              ),
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const LoadingIndicator();
          }

          return SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildHeader(theme),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.width > 600 ? screenSize.width * 0.08 : 20,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _buildProcessTypeSelector(controller, theme),
                        const SizedBox(height: 20),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.1),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: controller.isExistingProcess.value
                              ? _buildExistingProcessSection(controller, theme)
                              : _buildNewProcessSection(context, controller, theme),
                        ),
                        const SizedBox(height: 100), // Espaço para o botão
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        bottomNavigationBar: _buildBottomButton(controller, theme),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.assignment_turned_in_rounded,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Solicitação Jurídica",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Crie uma nova solicitação ou vincule a um processo existente.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessTypeSelector(ProcessCreateController controller, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: Colors.blue[700],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Tipo de Solicitação',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Obx(() => Column(
              children: [
                _buildModernRadioTile(
                  title: 'Nova Solicitação',
                  subtitle: 'Criar uma nova demanda jurídica',
                  icon: Icons.add_circle_outline_rounded,
                  value: false,
                  groupValue: controller.isExistingProcess.value,
                  onChanged: (value) {
                    controller.clearFields();
                    controller.isExistingProcess.value = value!;
                  },
                  theme: theme,
                ),
                const SizedBox(height: 12),
                _buildModernRadioTile(
                  title: 'Processo Existente',
                  subtitle: 'Vincular a um processo em andamento',
                  icon: Icons.link_rounded,
                  value: true,
                  groupValue: controller.isExistingProcess.value,
                  onChanged: (value) => controller.isExistingProcess.value = value!,
                  theme: theme,
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildModernRadioTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required bool groupValue,
    required Function(bool?) onChanged,
    required ThemeData theme,
  }) {
    final isSelected = groupValue == value;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.05)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.grey[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.grey[800],
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.primary.withOpacity(0.8)
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                Icons.check_rounded,
                size: 12,
                color: Colors.white,
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewProcessSection(BuildContext context, ProcessCreateController controller, ThemeData theme) {
    return Container(
      key: const ValueKey('new_process'),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.description_rounded,
                    color: Colors.green[700],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Informações da Solicitação",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildProcessTypeSubSelector(controller, theme),
            const SizedBox(height: 20),

            CustomWidgets.buildTextField(
              context: context,
              label: 'Título da Solicitação',
              controller: controller.titleController,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => FocusScope.of(context).nextFocus(),
            ),
            const SizedBox(height: 16),

            CustomWidgets.buildTextField(
              context: context,
              label: 'Descrição Detalhada',
              controller: controller.descriptionController,
              maxLine: 4,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => FocusScope.of(context).unfocus(),
            ),
            const SizedBox(height: 20),

            _buildFilesSection(context, controller, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessTypeSubSelector(ProcessCreateController controller, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Categoria do Pedido",
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => Row(
          children: [
            Expanded(
              child: _buildCategoryOption(
                title: 'Procedimento\nAdministrativo',
                icon: Icons.account_balance_rounded,
                value: false,
                groupValue: controller.isProcesso.value,
                onChanged: (value) => controller.isProcesso.value = value!,
                theme: theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCategoryOption(
                title: 'Processo\nJudicial',
                icon: Icons.gavel_rounded,
                value: true,
                groupValue: controller.isProcesso.value,
                onChanged: (value) => controller.isProcesso.value = value!,
                theme: theme,
              ),
            ),
          ],
        )),
      ],
    );
  }

  Widget _buildCategoryOption({
    required String title,
    required IconData icon,
    required bool value,
    required bool groupValue,
    required Function(bool?) onChanged,
    required ThemeData theme,
  }) {
    final isSelected = groupValue == value;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withOpacity(0.15)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.grey[700],
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingProcessSection(ProcessCreateController controller, ThemeData theme) {
    return Container(
      key: const ValueKey('existing_process'),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    color: Colors.orange[700],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Buscar Processo Existente',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Digite o número do processo para vinculá-lo',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
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
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) {
                      FocusScope.of(Get.context!).unfocus();
                      controller.fetchProcessByNumber();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: controller.fetchProcessByNumber,
                    icon: const Icon(Icons.search_rounded, color: Colors.white, size: 24),
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
      ),
    );
  }

  Widget _buildProcessDetails(ProcessCreateController controller, ThemeData theme) {
    final process = controller.processoJuridico.value!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.05),
            theme.colorScheme.primary.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.article_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Processo Encontrado",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _buildDetailRow(theme, Icons.account_balance_rounded, 'Tribunal', process.tribunal),
          _buildDetailRow(theme, Icons.book_rounded, 'Classe', process.classeNome),
          _buildDetailRow(theme, Icons.format_list_bulleted_rounded, 'Formato', process.formatoNome),
          _buildDetailRow(theme, Icons.gavel_rounded, 'Órgão Julgador', process.orgaoJulgador.nome),

          const SizedBox(height: 16),
          _buildAssuntosList(process.assuntos, theme),
        ],
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
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
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.topic_rounded,
                color: theme.colorScheme.secondary,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "Assuntos",
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: assuntos.map((assunto) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.secondary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                assunto.nome,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.secondary,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFilesSection(BuildContext context, ProcessCreateController controller, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.attach_file_rounded,
                    color: Colors.purple[700],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Documentos",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[700],
                  ),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () => _showFileOptions(context, controller),
                icon: Icon(
                  Icons.add_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Obx(() => controller.files.isEmpty
            ? _buildEmptyFilesState(theme)
            : _buildFileList(controller, theme)
        ),
      ],
    );
  }

  Widget _buildEmptyFilesState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_upload_rounded,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'Nenhum documento anexado',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Toque em + para adicionar documentos',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileList(ProcessCreateController controller, ThemeData theme) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.files.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final file = controller.files[index];
        final fileName = file.path.split('/').last;

        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!, width: 1),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.insert_drive_file_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            title: Text(
              fileName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              _getFileSize(file),
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            trailing: Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: Colors.red[700], size: 20),
                onPressed: () => controller.removeFile(file),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getFileSize(File file) {
    try {
      final bytes = file.lengthSync();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (e) {
      return 'Tamanho desconhecido';
    }
  }

  void _showFileOptions(BuildContext context, ProcessCreateController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle indicator
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Adicionar Documento',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFileOptionButton(
                      context,
                      icon: Icons.camera_alt_rounded,
                      label: 'Câmera',
                      color: Colors.blue,
                      onTap: () => _pickFile(context, controller, ImageSource.camera),
                    ),
                    _buildFileOptionButton(
                      context,
                      icon: Icons.photo_library_rounded,
                      label: 'Galeria',
                      color: Colors.green,
                      onTap: () => _pickFile(context, controller, ImageSource.gallery),
                    ),
                    _buildFileOptionButton(
                      context,
                      icon: Icons.folder_rounded,
                      label: 'Arquivos',
                      color: Colors.orange,
                      onTap: () async {
                        Navigator.of(context).pop();
                        // Remove o foco antes de abrir o seletor de arquivos
                        FocusScope.of(context).unfocus();
                        File? file = await FileUtils.pickFile();
                        if (file != null) {
                          controller.addFile(file);
                          // Garante que o teclado não apareça após adicionar arquivo
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            FocusScope.of(context).unfocus();
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFileOptionButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.3), width: 1),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile(BuildContext context, ProcessCreateController controller, ImageSource source) async {
    try {
      // Remove o foco de qualquer campo antes de selecionar arquivo
      FocusScope.of(context).unfocus();

      final ImagePicker picker = ImagePicker();
      final XFile? xfile = await picker.pickImage(source: source);
      if (xfile != null) {
        controller.addFile(File(xfile.path));
        // Garante que o teclado não apareça após adicionar arquivo
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).unfocus();
        });
      } else {
        SnackbarCustom.showInfo('Nenhum arquivo selecionado.');
      }
    } catch (e) {
      SnackbarCustom.showError('Erro ao adicionar arquivo.');
    } finally {
      Navigator.of(context).pop();
      // Remove o foco novamente para garantir que o teclado não apareça
      Future.delayed(const Duration(milliseconds: 100), () {
        FocusScope.of(context).unfocus();
      });
    }
  }

  Widget _buildBottomButton(ProcessCreateController controller, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Container(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: controller.saveProcess,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Salvar Solicitação',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.elasticOut,
          ),
          child: FadeTransition(
            opacity: animation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: isLargeScreen ? screenSize.width * 0.5 : screenSize.width * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isLargeScreen ? 24 : 20,
                    vertical: isLargeScreen ? 24 : 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Ícone animado com gradiente
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 800),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.primary.withOpacity(0.7),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.article_rounded,
                                size: isLargeScreen ? 50 : 40,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      Text(
                        "Como funciona a criação de solicitações?",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildHelpSection(
                              theme,
                              icon: Icons.account_balance_rounded,
                              title: "Procedimento Administrativo",
                              description: "Para questões internas como sindicâncias, recursos administrativos e regularizações dentro da corporação.",
                              isLargeScreen: isLargeScreen,
                            ),
                            const SizedBox(height: 16),
                            _buildHelpSection(
                              theme,
                              icon: Icons.gavel_rounded,
                              title: "Processo Judicial",
                              description: "Ação movida no Judiciário para resolver disputas legais, garantir direitos ou contestar decisões.",
                              isLargeScreen: isLargeScreen,
                            ),
                            const SizedBox(height: 16),
                            _buildHelpSection(
                              theme,
                              icon: Icons.search_rounded,
                              title: "Processo Existente",
                              description: "Vincule um número de processo já em andamento para acompanhamento e atualizações.",
                              isLargeScreen: isLargeScreen,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      Container(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            "Entendi",
                            style: TextStyle(
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildHelpSection(
      ThemeData theme, {
        required IconData icon,
        required String title,
        required String description,
        required bool isLargeScreen,
      }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: isLargeScreen ? 24 : 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontSize: isLargeScreen ? 16 : 14,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: isLargeScreen ? 14 : 12,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}