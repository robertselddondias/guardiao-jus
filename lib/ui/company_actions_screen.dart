import 'package:flutter/material.dart';
import 'package:flutter_progressive_image/flutter_progressive_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/controllers/company_details_controller.dart';
import 'package:guardiao_cliente/models/company_model.dart';
import 'package:guardiao_cliente/widgets/snackbar_custom.dart';
import 'package:guardiao_cliente/widgets/loading_indicator.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyActionsScreen extends StatelessWidget {
  final CompanyDetailsController controller = Get.put(
      CompanyDetailsController());

  CompanyActionsScreen({super.key, required CompanyModel company}) {
    controller.setCompany(company); // Inicializa o modelo na controller
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery
        .of(context)
        .size;

    return Scaffold(
      appBar: AppBar(
        title: Obx(() =>
            Text(controller.company.value.name ?? 'Detalhes da Empresa')),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingIndicator();
        }
        return Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.05,
                  vertical: screenSize.height * 0.02,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo da empresa
                    Center(
                      child: CircleAvatar(
                        radius: screenSize.width * 0.15,
                        backgroundColor: theme.colorScheme.primary.withOpacity(
                            0.1),
                        child: controller.company.value.logoUrl == null
                            ? Icon(
                          Icons.business,
                          size: screenSize.width * 0.1,
                          color: theme.colorScheme.primary,
                        )
                            : ClipOval(
                          child: Image(
                            image: ProgressiveImage(
                                controller.company.value.logoUrl!),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.03),

                    // Nome da empresa
                    Center(
                      child: Text(
                        controller.company.value.name ?? 'Nome não informado',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.015),

                    // Mensalidade
                    if (controller.company.value.monthlyValue != null)
                      Center(
                        child: Center(
                          child: Text(
                            'Mensalidade: R\$ ${controller.company.value
                                .monthlyValue!.toStringAsFixed(2)}',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.brightness == Brightness.dark
                                  ? Colors
                                  .white // 🔹 No Dark Mode → Texto 100% Branco para alto contraste
                                  : theme.colorScheme
                                  .primary, // 🔹 No Light Mode → Mantém a cor primária
                            ),
                          ),
                        ),
                      ),
                    SizedBox(height: screenSize.height * 0.03),

                    // Informações principais
                    _buildInfoRow(
                      icon: Icons.account_balance,
                      label: 'CNPJ',
                      value: controller.company.value.cnpj ?? 'Não informado',
                      theme: theme,
                    ),
                    _buildInfoRow(
                      icon: Icons.email,
                      label: 'E-mail',
                      value: controller.company.value.email ?? 'Não informado',
                      theme: theme,
                    ),
                    _buildInfoRow(
                      icon: Icons.how_to_reg_rounded,
                      label: 'OAB',
                      value: controller.company.value.oab ?? 'Não informado',
                      theme: theme,
                    ),
                    if (controller.company.value.address != null)
                      _buildInfoRow(
                        icon: Icons.location_on,
                        label: 'Endereço',
                        value: controller.company.value.address!.street!,
                        theme: theme,
                      ),
                    SizedBox(height: screenSize.height * 0.03),

                    if (controller.company.value.beneficios != null &&
                        controller.company.value.beneficios!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Benefícios',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: controller.company.value.beneficios!
                                  .length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 1.0,
                                    horizontal: 16.0,
                                  ),
                                  leading: Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                  title: Text(
                                    controller.company.value.beneficios![index],
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),

                    // Ações
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionIcon(
                          icon: FaIcon(FontAwesomeIcons.whatsapp).icon!,
                          label: 'WhatsApp',
                          theme: theme,
                          color: Colors.green,
                          onTap: () {
                            controller.openWhatsApp(
                                controller.company.value.whatsapp);
                          },
                        ),
                        _buildActionIcon(
                          icon: Icons.warning_amber_rounded,
                          label: 'Emergência',
                          theme: theme,
                          color: Colors.amber,
                          onTap: () {
                            _showEmergencyCallDialog(context,
                                controller.company.value.phoneEmergency!);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),


            // Indicador de carregamento
            if (controller.isLoading.value)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        );
      }),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.05,
          vertical: screenSize.height * 0.02,
        ),
        child: ElevatedButton.icon(
          onPressed: () async {
            final filePath = await controller.downloadContract();
            if (filePath != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('PDF baixado com sucesso!'),
                  action: SnackBarAction(
                    label: 'Abrir',
                    onPressed: () {
                      OpenFilex.open(filePath);
                    },
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Erro ao baixar o PDF!')),
              );
            }
          },
          icon: const Icon(Icons.file_download),
          label: const Text('Baixar Contrato'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              vertical: screenSize.height * 0.02,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  void _showEmergencyCallDialog(BuildContext context, String? emergencyNumber) {
    if (emergencyNumber == null || emergencyNumber.isEmpty) {
      SnackbarCustom.showError("Número de emergência não disponível.");
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmação"),
          content: const Text(
              "Deseja realmente ligar para o número de emergência?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _callEmergencyNumber(emergencyNumber);
              },
              child: const Text("Ligar"),
            ),
          ],
        );
      },
    );
  }

  /// **🔹 Método para abrir o discador e fazer a ligação**
  void _callEmergencyNumber(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      SnackbarCustom.showError("Não foi possível iniciar a chamada.");
    }
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
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
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required String label,
    required ThemeData theme,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(icon, size: 30, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
