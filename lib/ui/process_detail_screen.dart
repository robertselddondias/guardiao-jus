import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/controllers/process_detail_controller.dart';
import 'package:guardiao_cliente/enums/feature_status_type.dart';
import 'package:guardiao_cliente/models/assunto_model.dart';
import 'package:guardiao_cliente/models/processo_model.dart';
import 'package:guardiao_cliente/widgets/guardiao_widget.dart';

class ProcessDetailScreen extends StatelessWidget {
  const ProcessDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProcessDetailController controller = Get.put(ProcessDetailController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalhes do Processo"),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.processo.value == null) {
          return const Center(child: Text("Processo não encontrado."));
        }

        final processo = controller.processo.value!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusCard(processo, theme),
              const SizedBox(height: 16),
              _buildProcessInfo(processo, theme),
              const SizedBox(height: 16),
              GuardiaoWidget.buildNotesSection(controller.notas, theme),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatusCard(ProcessoModel processo, ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      color: processo.status.color.withOpacity(0.1),
      child: ListTile(
        leading: Icon(processo.status.icon, color: processo.status.color, size: 32),
        title: Text(
          processo.status.label,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
        ),
      ),
    );
  }

  Widget _buildProcessInfo(ProcessoModel processo, ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GuardiaoWidget.buildSectionTitle("Dados do Processo", theme),
            const SizedBox(height: 8),
            _buildDetailRow(theme, Icons.account_balance, processo.processoJuridico!.tribunal),
            _buildDetailRow(theme, Icons.book, processo.processoJuridico!.classeNome),
            _buildDetailRow(theme, Icons.gavel, processo.processoJuridico!.orgaoJulgador.nome),
            const SizedBox(height: 16),
            _buildSubjectsList(processo.processoJuridico!.assuntos, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsList(List<AssuntoModel> assuntos, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GuardiaoWidget.buildSectionTitle("Assuntos Relacionados", theme),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: assuntos.map((assunto) {
            return Chip(
              backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
              label: Text(
                assunto.nome,
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
