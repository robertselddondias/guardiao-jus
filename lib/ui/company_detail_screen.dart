import 'package:flutter/material.dart';
import 'package:flutter_progressive_image/flutter_progressive_image.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/controllers/company_details_controller.dart';
import 'package:guardiao_cliente/models/company_model.dart';
import 'package:open_filex/open_filex.dart';

class CompanyDetailsScreen extends StatelessWidget {
  final CompanyDetailsController controller = Get.put(CompanyDetailsController());

  CompanyDetailsScreen({super.key, required CompanyModel company}) {
    controller.setCompany(company);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.company.value.name ?? 'Detalhes da Empresa')),
        centerTitle: true,
      ),
      body: Obx(() => Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: controller.company.value.logoUrl == null
                        ? Icon(Icons.business, size: 50, color: theme.colorScheme.primary)
                        : ClipOval(
                        child: Image(image: ProgressiveImage(controller.company.value.logoUrl!))
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    controller.company.value.name ?? 'Nome não informado',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (controller.company.value.monthlyValue != null)
                  Center(
                    child: Center(
                      child: Text(
                        'Mensalidade: R\$ ${controller.company.value.monthlyValue!.toStringAsFixed(2)}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.brightness == Brightness.dark
                              ? Colors.white // 🔹 No Dark Mode → Texto 100% Branco para alto contraste
                              : theme.colorScheme.primary, // 🔹 No Light Mode → Mantém a cor primária
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                _buildInfoRow(Icons.account_balance, 'CNPJ', controller.company.value.cnpj ?? 'Não informado', theme),
                _buildInfoRow(Icons.email, 'E-mail', controller.company.value.email ?? 'Não informado', theme),
                _buildInfoRow(Icons.how_to_reg_rounded, 'OAB', controller.company.value.oab ?? 'Não informado', theme),
                if (controller.company.value.address != null)
                  _buildInfoRow(Icons.location_on, 'Endereço', controller.company.value.address!.street!, theme),
                const SizedBox(height: 24),
                if (controller.company.value.description != null)
                  _buildSection('Descrição', controller.company.value.description!, theme),
                if (controller.company.value.beneficios != null && controller.company.value.beneficios!.isNotEmpty)
                  _buildBenefitsSection(theme),
                if (controller.company.value.urlContract != null)
                  _buildContractButton(context),
              ],
            ),
          ),
          if (controller.isLoading.value)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),

        ],
      )),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () => _showConfirmationDialog(context),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Contratar Serviço',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                const SizedBox(height: 4),
                Text(value, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
        const SizedBox(height: 8),
        Text(content, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.8))),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildBenefitsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Benefícios', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
        const SizedBox(height: 2),
        Container(
          decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(12)),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.company.value.beneficios!.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text(controller.company.value.beneficios![index], style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface)),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildContractButton(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () async {
          final filePath = await controller.downloadContract();
          if (filePath != null) {
            OpenFilex.open(filePath);
          }
        },
        icon: const Icon(Icons.file_download),
        label: const Text('Baixar Contrato'),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    final theme = Theme.of(context);
    bool isChecked = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Confirmação',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ao confirmar, você estará assinando o contrato com este escritório e concordando com os termos do aplicativo.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Valor mensal: R\$ ${controller.company.value.monthlyValue?.toStringAsFixed(2) ?? "0,00"}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: isChecked,
                        activeColor: theme.colorScheme.primary,
                        onChanged: (value) {
                          setState(() {
                            isChecked = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: Text(
                          'Li e concordo com o contrato e os termos do aplicativo.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext); // Fecha o diálogo
                  },
                  child: Text(
                    'Cancelar',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isChecked
                      ? () {
                    Navigator.pop(dialogContext); // Fecha o diálogo
                    controller.confirmContract();
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: isChecked ? 2 : 0,
                  ),
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

}