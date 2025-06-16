import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/controllers/login_controller.dart';
import 'package:guardiao_cliente/themes/button_them.dart';
import 'package:guardiao_cliente/widgets/loading_indicator.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final LoginController controller = Get.put(LoginController()); // Instancia a controller com GetX

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Fecha o teclado ao tocar fora
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: Obx(() {
          if (controller.isLoading.value) {
            return const LoadingIndicator();
          }
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.08,
              vertical: screenHeight * 0.03,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🔹 Espaço flexível para centralizar a logo verticalmente
                Expanded(
                  child: Center(
                    child: Image.asset(
                      theme.brightness == Brightness.dark
                          ? "assets/images/logo.png"
                          : "assets/images/logo_light.png",
                      width: screenWidth * 0.65, // Aumentado
                      height: screenHeight * 0.32, // Logo maior e centralizada
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // 🔹 Título "Entrar"
                Text(
                  "Entrar",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.06,
                    color: theme.colorScheme.primary,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),

                // 🔹 Subtítulo
                Text(
                  "Bem-vindo! Estamos felizes em ter você de aqui",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: screenWidth * 0.04,
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: screenHeight * 0.025),

                // 🔹 Campo de telefone
                Obx(() => TextFormField(
                  validator: (value) =>
                  value != null && value.isNotEmpty ? null : 'Campo obrigatório',
                  keyboardType: TextInputType.number,
                  controller: controller.phoneController.value,
                  textAlign: TextAlign.start,
                  inputFormatters: [controller.maskFormatterCelular],
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: theme.inputDecorationTheme.fillColor,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.015,
                    ),
                    prefixIcon: CountryCodePicker(
                      onChanged: (value) {
                        controller.updateCountryCode(value.dialCode!);
                      },
                      initialSelection: controller.countryCode.value,
                      comparator: (a, b) =>
                          b.name!.compareTo(a.name.toString()),
                      flagDecoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                      ),
                    ),
                    border: theme.inputDecorationTheme.border,
                    hintText: "(00) 00000-0000",
                  ),
                )),
                SizedBox(height: screenHeight * 0.03),

                // 🔹 Botão "Próximo"
                ButtonThem.buildButton(
                  context,
                  title: "Próximo".tr,
                  onPress: () async {
                    await controller.loginWithPhone();
                  },
                ),
                SizedBox(height: screenHeight * 0.025),

                // 🔹 Divisor "OU"
                Row(
                  children: [
                    const Expanded(child: Divider(height: 1)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                      child: Text(
                        "OU",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.04,
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(height: 1)),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),

                // 🔹 Botão Google
                ButtonThem.buildBorderButton(
                  context,
                  title: "Entrar com o Google".tr,
                  iconVisibility: true,
                  iconAssetImage: 'assets/icons/ic_google.png',
                  onPress: () async {
                    controller.loginWithGoogle();
                  },
                ),
                SizedBox(height: screenHeight * 0.015),

                // 🔹 Botão Apple (somente no iOS)
                if (Platform.isIOS)
                  ButtonThem.buildBorderButton(
                    context,
                    title: "Entrar com a Apple".tr,
                    iconVisibility: true,
                    iconAssetImage: 'assets/icons/ic_apple_black.png',
                    onPress: () async {
                      controller.loginWithApple();
                    },
                  ),
                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          );
        }),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.02,
          ),
          child: Text.rich(
            textAlign: TextAlign.center,
            TextSpan(
              text: 'Ao clicar em "Avançar", você concorda com'.tr,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: screenWidth * 0.035,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: ' Termos e Condições'.tr,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: screenWidth * 0.035,
                    decoration: TextDecoration.underline,
                    color: theme.colorScheme.primary,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      controller.goToTermsAndConditions();
                    },
                ),
                TextSpan(
                  text: ' e '.tr,
                  style: theme.textTheme.bodyMedium,
                ),
                TextSpan(
                  text: 'Política de Privacidade'.tr,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: screenWidth * 0.035,
                    decoration: TextDecoration.underline,
                    color: theme.colorScheme.primary,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      controller.goToPrivacidade();
                    },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}