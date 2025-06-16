import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/controllers/address_controller.dart';
import 'package:guardiao_cliente/widgets/guardiao_widget.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AddressController controller = Get.put(AddressController());
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
              'Endereço',
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
                          Icons.location_on_outlined,
                          size: 50,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Seu Endereço',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Informe onde você reside',
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
                      _buildSectionTitle('Informações de Endereço', theme, Icons.home_outlined),
                      const SizedBox(height: 20),

                      // Campo de CEP com botão de busca
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 8),
                            child: Text(
                              'CEP *',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextField(
                                  controller: controller.cepController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [controller.maskFormatter],
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '00000-000',
                                    hintStyle: TextStyle(
                                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                                      fontSize: 14,
                                    ),
                                    prefixIcon: Icon(Icons.map_outlined,
                                        color: theme.colorScheme.primary.withOpacity(0.7)
                                    ),
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
                              ),
                              const SizedBox(width: 12),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      theme.colorScheme.primary,
                                      theme.colorScheme.primary.withBlue(theme.colorScheme.primary.blue + 20),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: controller.searchCep,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      child: Icon(
                                        Icons.search,
                                        color: theme.colorScheme.onPrimary,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Dropdown de UF
                      _buildUfDropdown(controller, context, theme),
                      const SizedBox(height: 16),

                      // Campos de Cidade e Bairro
                      size.width > 600
                          ? Row(
                        children: [
                          Expanded(
                            child: GuardiaoWidget.buildInputField(
                              context,
                              label: 'Cidade',
                              hint: 'Digite sua cidade',
                              controller: controller.cityController,
                              prefixIcon: Icons.location_city_outlined,
                              textCapitalization: TextCapitalization.sentences,
                              keyboardType: TextInputType.streetAddress,
                              theme: theme,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GuardiaoWidget.buildInputField(
                                context,
                                label: 'Bairro',
                                hint: 'Digite seu bairro',
                                controller: controller.districtController,
                                prefixIcon: Icons.domain_outlined,
                                theme: theme,
                                textCapitalization: TextCapitalization.sentences,
                                keyboardType: TextInputType.streetAddress
                            ),
                          ),
                        ],
                      )
                          : Column(
                        children: [
                          GuardiaoWidget.buildInputField(
                              context,
                              label: 'Cidade',
                              hint: 'Digite sua cidade',
                              controller: controller.cityController,
                              prefixIcon: Icons.location_city_outlined,
                              theme: theme,
                              textCapitalization: TextCapitalization.sentences,
                              keyboardType: TextInputType.streetAddress
                          ),
                          const SizedBox(height: 16),
                          GuardiaoWidget.buildInputField(
                              context,
                              label: 'Bairro',
                              hint: 'Digite seu bairro',
                              controller: controller.districtController,
                              prefixIcon: Icons.domain_outlined,
                              theme: theme,
                              textCapitalization: TextCapitalization.sentences,
                              keyboardType: TextInputType.streetAddress
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Rua, Número e Complemento
                      GuardiaoWidget.buildInputField(
                          context,
                          label: 'Rua',
                          hint: 'Digite o nome da rua',
                          controller: controller.streetController,
                          prefixIcon: Icons.signpost_outlined,
                          theme: theme,
                          textCapitalization: TextCapitalization.sentences,
                          keyboardType: TextInputType.streetAddress
                      ),
                      const SizedBox(height: 16),
                      GuardiaoWidget.buildInputField(
                          context,
                          label: 'Número',
                          hint: 'Ex: 123, S/N',
                          controller: controller.numberController,
                          prefixIcon: Icons.pin_outlined,
                          theme: theme,
                          textCapitalization: TextCapitalization.sentences,
                          keyboardType: TextInputType.streetAddress
                      ),
                      const SizedBox(height: 16),
                      GuardiaoWidget.buildInputField(
                          context,
                          label: 'Complemento',
                          hint: 'Apto, Bloco, Casa, etc.',
                          controller: controller.complementController,
                          prefixIcon: Icons.home_outlined,
                          theme: theme,
                          textCapitalization: TextCapitalization.sentences,
                          keyboardType: TextInputType.streetAddress,
                      ),
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
            onPressed: () => controller.saveAddressToFirebase(),
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
                  'Continuar',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward)
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

  Widget _buildUfDropdown(AddressController controller, BuildContext context, ThemeData theme) {
    return Obx(() {
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
          Container(
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
              onChanged: (String? newValue) {
                controller.selectedUf.value = newValue ?? '';
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
                  Icons.map_outlined,
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
          ),
        ],
      );
    });
  }
}