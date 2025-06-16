import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/controllers/home_controller.dart';
import 'package:guardiao_cliente/ui/notification_screen.dart';

class HomeScreen extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    // Ajusta o número de colunas do grid baseado no tamanho da tela
    final int crossAxisCount = _getCrossAxisCount(size.width);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        title: const Text(
          'Guardião Jus',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() {
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.notifications_none_rounded,
                        color: theme.colorScheme.onPrimary,
                      ),
                      onPressed: () => Get.to(() => const NotificationScreen()),
                    ),
                  ),
                  if (controller.unreadNotifications.value > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          "${controller.unreadNotifications.value}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          // Header com gradiente
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
            ),
            child: Column(
              children: [
                // Imagem ou ícone central
                Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.balance,
                    color: theme.colorScheme.onPrimary,
                    size: 42,
                  ),
                ),
                // Informações
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _buildInfoBanner(theme), // Voltando para o alerta original
                ),
              ],
            ),
          ),

          // Conteúdo principal com scroll
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título da seção
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Serviços',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {},
                          icon: Icon(
                            Icons.apps_rounded,
                            color: theme.colorScheme.primary,
                            size: 18,
                          ),
                          label: Text(
                            'Ver todos',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Grid de serviços
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: controller.featureIcons.length,
                      itemBuilder: (context, index) {
                        // Verificar se é a Agenda para personalizar o badge
                        bool isAgenda = controller.featureLabels[index].toLowerCase().contains('agenda');

                        return _buildFeatureCard(
                          context,
                          icon: controller.featureIcons[index],
                          label: controller.featureLabels[index],
                          backgroundColor: controller.featureColors[index],
                          isEnabled: controller.featureEnabled[index],
                          onPressed: controller.listActions[index],
                          isBadge: controller.isBadge[index],
                          badgeCount: controller.totalSchehdules.value,
                          isAgenda: isAgenda,
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Acesse rapidamente as funcionalidades do aplicativo.",
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Determina o número de colunas com base na largura da tela
  int _getCrossAxisCount(double width) {
    if (width > 1200) return 6;    // Ultra large - 6 colunas
    if (width > 900) return 5;     // Large desktop - 5 colunas
    if (width > 600) return 4;     // Tablet/desktop - 4 colunas
    if (width > 450) return 3;     // Large phone - 3 colunas
    return 2;                      // Phone - 2 colunas
  }

  Widget _buildFeatureCard(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color backgroundColor,
        required VoidCallback onPressed,
        required bool isEnabled,
        required bool isBadge,
        required int badgeCount,
        bool isAgenda = false,
      }) {
    final theme = Theme.of(context);

    // Cores mais intensas
    final cardColor = isEnabled ? Colors.white : Colors.grey[200];
    final iconBackgroundColor = backgroundColor;
    final textColor = Colors.black87;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: backgroundColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: isEnabled ? [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.15),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          splashColor: backgroundColor.withOpacity(0.2),
          highlightColor: backgroundColor.withOpacity(0.1),
          child: Opacity(
            opacity: isEnabled ? 1.0 : 0.7,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon container with vibrant background
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: iconBackgroundColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: backgroundColor.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),

                      // Badge especial para a Agenda (mais nítido e chamativo)
                      if (isBadge && isAgenda)
                        Positioned(
                          right: -10,
                          top: -10,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              badgeCount > 99 ? "99+" : "$badgeCount",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Label with higher contrast
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Badge padrão para os outros itens (não agenda)
                  if (isBadge && !isAgenda)
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.error.withOpacity(0.3),
                            blurRadius: 4,
                            spreadRadius: 0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        badgeCount > 99 ? "99+" : "$badgeCount",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
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
  }
}