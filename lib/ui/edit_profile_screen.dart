import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/controllers/profile_edit_controller.dart';
import 'package:guardiao_cliente/themes/custom_widgets.dart';
import 'package:guardiao_cliente/utils/profile_image_with_loader.dart';
import 'package:guardiao_cliente/widgets/loading_indicator.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final ProfileEditController controller = Get.put(ProfileEditController());
    final theme = Theme.of(context);
    final screenSize = MediaQuery
        .of(context)
        .size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar Perfil',
          style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onPrimary),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        elevation: 2,
      ),
      body: Obx(() {

        if (controller.isLoading.value) {
          return const LoadingIndicator();
        }
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Foto do Perfil
                Center(
                  child: Stack(
                    children: [
                      Obx(() {
                        return ProfileImageWithLoader(
                          imageUrl: controller.userPhoto.value,
                        );
                      }),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          onPressed: controller.pickProfileImage,
                          icon: Icon(Icons.camera_alt,
                              color: theme.colorScheme.primary),
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Seção de Dados Pessoais
                _buildSectionTitle('Dados Pessoais', theme),
                const SizedBox(height: 10),
                CustomWidgets.buildTextField(
                  context: context,
                  label: 'Nome Completo',
                  controller: controller.nameController,
                ),
                const SizedBox(height: 10),
                CustomWidgets.buildTextField(
                  context: context,
                  label: 'Email',
                  controller: controller.emailController,
                ),
                const SizedBox(height: 10),
                CustomWidgets.buildTextField(
                  context: context,
                  label: 'Telefone',
                  controller: controller.phoneController,
                ),
                const SizedBox(height: 10),
                CustomWidgets.buildTextField(
                  context: context,
                  label: 'CPF',
                  controller: controller.cpfController,
                ),
                const SizedBox(height: 10),
                CustomWidgets.buildDateField(
                  context: context,
                  label: 'Data de Nascimento',
                  controller: controller.birthDateController,
                ),
                const SizedBox(height: 20),

                // Seção de Endereço
                _buildSectionTitle('Endereço', theme),
                const SizedBox(height: 10),
                CustomWidgets.buildTextField(
                  context: context,
                  label: 'CEP',
                  controller: controller.cepController,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomWidgets.buildTextField(
                        context: context,
                        label: 'Estado (UF)',
                        controller: controller.ufController,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 5,
                      child: CustomWidgets.buildTextField(
                        context: context,
                        label: 'Cidade',
                        controller: controller.cityController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CustomWidgets.buildTextField(
                  context: context,
                  label: 'Bairro',
                  controller: controller.districtController,
                ),
                const SizedBox(height: 10),
                CustomWidgets.buildTextField(
                  context: context,
                  label: 'Rua',
                  controller: controller.streetController,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: CustomWidgets.buildTextField(
                        context: context,
                        label: 'Número',
                        controller: controller.numberController,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 5,
                      child: CustomWidgets.buildTextField(
                        context: context,
                        label: 'Complemento',
                        controller: controller.complementController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Seção de Dados Militares
                _buildSectionTitle('Dados Militares', theme),
                const SizedBox(height: 10),
                CustomWidgets.buildTextField(
                  context: context,
                  label: 'Número de Matrícula',
                  controller: controller.registrationNumberController,
                ),
                const SizedBox(height: 10),
                CustomWidgets.buildTextField(
                  context: context,
                  label: 'Posto/Graduação',
                  controller: controller.rankController,
                ),
                const SizedBox(height: 10),
                CustomWidgets.buildTextField(
                  context: context,
                  label: 'UF Militar',
                  controller: controller.militaryUfController,
                ),
                const SizedBox(height: 10),
                CustomWidgets.buildTextField(
                  context: context,
                  label: 'Entidade',
                  controller: controller.entityController,
                ),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: controller.saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Salvar',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

// Widget Auxiliar para Títulos de Seção
  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }
}
