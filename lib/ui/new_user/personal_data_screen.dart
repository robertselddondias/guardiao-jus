import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/controllers/personal_data_controller.dart';
import 'package:guardiao_cliente/utils/date_utils_custom.dart';

class PersonalDataScreen extends StatelessWidget {
  const PersonalDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PersonalDataController controller = Get.put(PersonalDataController());
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
            'Dados Pessoais',
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
                          Icons.person_outline_rounded,
                          size: 50,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Informações Pessoais',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Preencha seus dados para continuar',
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
                      _buildSectionTitle('Informações Básicas', theme, Icons.person),
                      const SizedBox(height: 20),

                      _buildInputField(
                        context,
                        label: 'Nome Completo',
                        hint: 'Digite seu nome completo',
                        textCapitalization: TextCapitalization.words,
                        controller: controller.nameController,
                        keyboardType: TextInputType.name,
                        prefixIcon: Icons.person_outline,
                        theme: theme,
                      ),

                      _buildInputField(
                        context,
                        label: 'CPF',
                        hint: '000.000.000-00',
                        textCapitalization: TextCapitalization.none,
                        controller: controller.cpfController,
                        keyboardType: TextInputType.number,
                        mask: controller.maskFormatterCpf,
                        prefixIcon: Icons.assignment_ind_outlined,
                        theme: theme,
                      ),

                      _buildInputField(
                        context,
                        textCapitalization: TextCapitalization.none,
                        label: 'Data de Nascimento',
                        hint: 'DD/MM/AAAA',
                        controller: controller.birthDateController,
                        mask: controller.maskFormatterDtNascimento,
                        isDate: false,
                        prefixIcon: Icons.calendar_today_outlined,
                        keyboardType: TextInputType.number,
                        theme: theme,
                      ),

                      const SizedBox(height: 30),
                      _buildSectionTitle('Contato', theme, Icons.contact_phone_outlined),
                      const SizedBox(height: 20),

                      _buildInputField(
                        context,
                        label: 'Telefone',
                        hint: '(00) 00000-0000',
                        textCapitalization: TextCapitalization.none,
                        controller: controller.phoneController,
                        keyboardType: TextInputType.phone,
                        mask: controller.maskFormatterTelefone,
                        prefixIcon: Icons.phone_outlined,
                        theme: theme,
                      ),

                      _buildInputField(
                        context,
                        textCapitalization: TextCapitalization.none,
                        label: 'E-mail',
                        hint: 'seu@email.com',
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        theme: theme,
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
            onPressed: () => controller.savePersonalData(),
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

  Widget _buildInputField(BuildContext context, {
    required String label,
    required String hint,
    required TextEditingController controller,
    required ThemeData theme,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool isDate = false,
    required TextCapitalization textCapitalization,
    dynamic mask,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
            autocorrect: true,
            enableSuggestions: true,
            textCapitalization: textCapitalization,
            inputFormatters: mask != null ? [mask] : [],
            readOnly: isDate,
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
            onTap: isDate
                ? () async {
              FocusScope.of(context).unfocus();
              DateTime? pickedDate = await showDatePicker(
                context: Get.context!,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: theme.colorScheme.primary,
                        onPrimary: theme.colorScheme.onPrimary,
                        surface: theme.colorScheme.surface,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedDate != null) {
                controller.text = DateUtilsCustom.formatDateToBrazil(pickedDate);
              }
            }
                : null,
          ),
        ],
      ),
    );
  }
}