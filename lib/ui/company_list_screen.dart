import 'package:flutter/material.dart';
import 'package:flutter_progressive_image/flutter_progressive_image.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/controllers/company_controller.dart';
import 'package:guardiao_cliente/models/company_model.dart';
import 'package:guardiao_cliente/ui/company_detail_screen.dart';

class CompanyListScreen extends StatelessWidget {
  const CompanyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CompanyController()); // 🔹 Controller instanciada corretamente

    return Scaffold(
      appBar: AppBar(
        title: const Text('Convênios'),
        centerTitle: true,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context), // 🔹 Exibe o diálogo de ajuda
          ),
        ],
      ),
      body: Obx(() {
        if (controller.companies.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.business,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhum convênio encontrado.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }

        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () async => await controller.fetchCompanies(),
            child: ListView.builder(
              itemCount: controller.companies.length,
              itemBuilder: (context, index) {
                final company = controller.companies[index];
                return _buildCompanyCard(context, company);
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCompanyCard(BuildContext context, CompanyModel company) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Get.to(() => CompanyDetailsScreen(company: company));
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Imagem redonda
              CircleAvatar(
                radius: 32,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                child: company.logoUrl == null
                    ? Icon(Icons.business, size: 40, color: theme.colorScheme.primary)
                    : ClipOval(
                  child: Image(
                    image: ProgressiveImage(company.logoUrl!),
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome da empresa
                    Text(
                      company.name ?? 'Nome não disponível',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // E-mail
                    Text(
                      company.email ?? 'Sem e-mail cadastrado',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // CNPJ
                    Text(
                      company.cnpj ?? 'Sem CNPJ cadastrado',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Mensalidade
                    Text(
                      'Mensalidade: R\$ ${company.monthlyValue?.toStringAsFixed(2) ?? 'Não disponível'}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Ícone
              Icon(Icons.arrow_forward_ios, size: 20, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
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
                        Icons.business,
                        size: 50,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Título estilizado
                  Text(
                    "Como funciona a escolha de convênios?",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Descrição principal
                  Text(
                    "Aqui você pode visualizar e escolher entre os convênios disponíveis. Cada convênio oferece benefícios exclusivos e condições especiais para policiais e militares.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Segunda parte do texto
                  Text(
                    "Clique em um convênio para ver mais detalhes e aproveitar as vantagens.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
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