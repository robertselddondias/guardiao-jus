import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/controllers/notification_settings_controller.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationSettingsController controller =
    Get.put(NotificationSettingsController());
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notificações',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        centerTitle: true,
        elevation: 4,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth > 600 ? screenWidth * 0.1 : 16.0,
            vertical: 20.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personalize suas notificações',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),

              // Notificação Geral
              Obx(() => SwitchListTile(
                value: controller.generalNotifications.value,
                onChanged: (value) => controller.toggleGeneralNotifications(),
                title: Text(
                  'Notificações Gerais',
                  style: theme.textTheme.bodyLarge,
                ),
                subtitle: Text(
                  'Ative para receber notificações gerais.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                activeColor: theme.colorScheme.primary,
              )),

              // Promoções
              Obx(() => SwitchListTile(
                value: controller.promotionalNotifications.value,
                onChanged: (value) =>
                    controller.togglePromotionalNotifications(),
                title: Text(
                  'Promoções',
                  style: theme.textTheme.bodyLarge,
                ),
                subtitle: Text(
                  'Receba atualizações sobre promoções e ofertas.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                activeColor: theme.colorScheme.primary,
              )),

              // Notificações de Segurança
              Obx(() => SwitchListTile(
                value: controller.securityNotifications.value,
                onChanged: (value) =>
                    controller.toggleSecurityNotifications(),
                title: Text(
                  'Notificações de Segurança',
                  style: theme.textTheme.bodyLarge,
                ),
                subtitle: Text(
                  'Receba alertas de segurança importantes.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                activeColor: theme.colorScheme.primary,
              )),

              const Spacer(),

              // Botão Salvar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Salvar Configurações',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
