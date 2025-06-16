import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/controllers/military_data_controller.dart';
import 'package:guardiao_cliente/models/entidade_militar_model.dart';

class MilitaryDataScreen extends StatelessWidget {
  const MilitaryDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MilitaryDataController controller = Get.put(MilitaryDataController());
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: theme.colorScheme.onPrimary),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'Dados Militares',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          backgroundColor: theme.colorScheme.primary,
          centerTitle: true,
          elevation: 0
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: size.width > 600 ? size.width * 0.08 : size.width * 0.05,
              vertical: size.height * 0.025,
            ),
            child: Column(
              children: [
                // Avatar e título
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: [
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.military_tech_outlined,
                          size: 50,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Dados Militares',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Informe seus dados militares',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),

                // Formulário
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Informações Militares', theme, Icons.shield_outlined),
                      const SizedBox(height: 20),

                      _buildInputField(
                        context,
                        label: 'Número da Matrícula',
                        hint: 'Digite seu número de matrícula',
                        controller: controller.registrationNumberController,
                        prefixIcon: Icons.numbers_outlined,
                        keyboardType: TextInputType.number,
                        theme: theme,
                      ),
                      const SizedBox(height: 16),

                      _buildInputField(
                        context,
                        label: 'Posto ou Graduação',
                        hint: 'Digite seu posto ou graduação',
                        controller: controller.rankController,
                        prefixIcon: Icons.military_tech_outlined,
                        theme: theme,
                      ),
                      const SizedBox(height: 16),

                      _buildUfDropdown(controller, context, theme),
                      const SizedBox(height: 16),

                      _buildEntityDropdown(controller, context, theme),
                    ],
                  ),
                ),

                // Nota de privacidade
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Seus dados estão protegidos pela nossa política de privacidade',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(
            horizontal: size.width > 600 ? size.width * 0.08 : size.width * 0.05,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: controller.saveMilitaryData,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Salvar Dados',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.check_circle_outline)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
      BuildContext context, {
        required String label,
        required String hint,
        required TextEditingController controller,
        required IconData prefixIcon,
        required ThemeData theme,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              '$label *',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
                fontSize: 14,
              ),
              prefixIcon: Icon(prefixIcon, color: theme.colorScheme.primary.withOpacity(0.7)),
              filled: true,
              fillColor: theme.colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUfDropdown(MilitaryDataController controller, BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Estado *',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        Obx(() => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.surface,
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: controller.selectedUf.value.isNotEmpty
                ? controller.selectedUf.value
                : null,
            onChanged: (String? newValue) async {
              controller.selectedUf.value = newValue ?? '';
              await controller.fetchMilitaryEntities();
            },
            items: controller.ufList.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              );
            }).toList(),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.public_outlined,
                color: theme.colorScheme.primary.withOpacity(0.7),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              border: InputBorder.none,
              hintText: 'Selecione seu estado',
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
                fontSize: 14,
              ),
            ),
            icon: Icon(
              Icons.arrow_drop_down,
              color: theme.colorScheme.primary,
            ),
            dropdownColor: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            isExpanded: true,
          ),
        )),
      ],
    );
  }

  Widget _buildEntityDropdown(MilitaryDataController controller, BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Instituição *',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        Obx(() {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.surface,
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: DropdownButtonFormField<EntidadeMilitarModel>(
              value: controller.militaryEntities.isEmpty
                  ? null
                  : (controller.militaryEntities.contains(controller.selectedEntity.value)
                  ? controller.selectedEntity.value
                  : controller.militaryEntities.first),
              onChanged: controller.militaryEntities.isEmpty
                  ? null
                  : (EntidadeMilitarModel? newValue) {
                if (newValue != null) {
                  controller.selectedEntity.value = newValue;
                }
              },
              items: controller.militaryEntities.isEmpty
                  ? [
                DropdownMenuItem<EntidadeMilitarModel>(
                  value: null,
                  enabled: false,
                  child: Text(
                    'Nenhuma entidade disponível',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                )
              ]
                  : controller.militaryEntities.map<DropdownMenuItem<EntidadeMilitarModel>>(
                    (EntidadeMilitarModel entity) {
                  return DropdownMenuItem<EntidadeMilitarModel>(
                    value: entity,
                    child: Text(
                      '${entity.sigla} (${entity.name})' ?? 'Sem nome',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  );
                },
              ).toList(),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.apartment_outlined,
                  color: theme.colorScheme.primary.withOpacity(0.7),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: InputBorder.none,
                hintText: 'Selecione sua entidade',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                  fontSize: 14,
                ),
              ),
              icon: Icon(
                Icons.arrow_drop_down,
                color: theme.colorScheme.primary,
              ),
              dropdownColor: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              isExpanded: true,
            ),
          );
        }),
      ],
    );
  }
}