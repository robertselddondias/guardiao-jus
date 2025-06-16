import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/controllers/settings_controller.dart';
import 'package:guardiao_cliente/utils/profile_image_with_loader.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<String> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return "Versão ${packageInfo.version} (Build ${packageInfo.buildNumber})";
  }

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.put(SettingsController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Configurações"),
        backgroundColor: theme.colorScheme.primary,
        centerTitle: true,
        elevation: 4,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com foto e nome do usuário
            Obx(() => Container(
              color: theme.colorScheme.primaryContainer,
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ProfileImageWithLoader(imageUrl: controller.userPhotoUrl.value),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.userName.value.isNotEmpty
                              ? controller.userName.value
                              : "Nome do Usuário",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          controller.userEmail.value.isNotEmpty
                              ? controller.userEmail.value
                              : "email@example.com",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 16),

            // Lista de opções
            Expanded(
              child: ListView(
                children: [
                  _buildSettingsOption(
                    context,
                    icon: Icons.edit,
                    title: "Editar Perfil",
                    onTap: controller.editProfile,
                  ),
                  _buildSettingsOption(
                    context,
                    icon: Icons.notifications,
                    title: "Notificações",
                    onTap: controller.configureNotifications,
                  ),
                  _buildSettingsOption(
                    context,
                    icon: Icons.payment,
                    title: "Métodos de Pagamento",
                    onTap: controller.managePaymentMethods,
                  ),
                  Obx(() => SwitchListTile(
                    title: const Text("Aparência: Modo Escuro"),
                    value: controller.isDarkMode.value,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (value) => controller.toggleTheme(),
                    secondary: Icon(
                      Icons.dark_mode,
                      color: theme.colorScheme.primary,
                    ),
                  )),
                  _buildSettingsOption(
                    context,
                    icon: Icons.logout,
                    title: "Sair",
                    onTap: () async {
                      final confirm = await _showLogoutConfirmation(context);
                      if (confirm) {
                        await controller.logout();
                      }
                    },
                    color: theme.colorScheme.error,
                  ),
                ],
              ),
            ),

            // 🔹 Exibir versão do aplicativo no canto inferior direito
            Padding(
              padding: const EdgeInsets.only(bottom: 16, right: 16),
              child: Align(
                alignment: Alignment.bottomRight,
                child: FutureBuilder<String>(
                  future: _getAppVersion(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox();
                    }
                    return Text(
                      snapshot.data!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsOption(BuildContext context,
      {required IconData icon, required String title, required VoidCallback onTap, Color? color}) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: color ?? theme.colorScheme.primary),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: color ?? theme.colorScheme.onSurface,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Future<bool> _showLogoutConfirmation(BuildContext context) async {
    final theme = Theme.of(context);
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Confirmação",
            style: theme.textTheme.titleMedium,
          ),
          content: Text(
            "Deseja realmente sair?",
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
              ),
              child: const Text("Sair"),
            ),
          ],
        );
      },
    ) ??
        false;
  }
}