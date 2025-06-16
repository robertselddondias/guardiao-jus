import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/controllers/otp_controller.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Esquema de cores refinado
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;
    final backgroundColor = theme.colorScheme.surface;
    final textColor = theme.colorScheme.onSurface;

    final controller = Get.put(OtpController());

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryColor),
            onPressed: () => Get.back(),
          ),
          title: Text(
            "Verificação".tr,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.02),

                // Título com ícone em vez de logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.security_rounded,
                        color: primaryColor,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      "Código de Segurança".tr,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),

                // Número de telefone com ícone
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.01,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Obx(() => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.phone_android_rounded,
                        size: 18,
                        color: primaryColor,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "${controller.countryCode.value}${controller.phoneNumber.value}",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  )),
                ),
                SizedBox(height: screenHeight * 0.04),

                // Campos de código
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02,
                    horizontal: screenWidth * 0.04,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.background,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Digite o código recebido via SMS".tr,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      // Campo OTP otimizado
                      PinCodeTextField(
                        appContext: context,
                        length: 6,
                        keyboardType: TextInputType.number,
                        animationType: AnimationType.fade,
                        controller: controller.otpController,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(12),
                          fieldHeight: screenWidth * 0.11,
                          fieldWidth: screenWidth * 0.11,
                          activeFillColor: theme.colorScheme.primaryContainer.withOpacity(0.2),
                          selectedFillColor: theme.colorScheme.primaryContainer.withOpacity(0.4),
                          inactiveFillColor: theme.colorScheme.surfaceVariant,
                          activeColor: primaryColor,
                          selectedColor: secondaryColor,
                          inactiveColor: theme.colorScheme.outline.withOpacity(0.3),
                        ),
                        enableActiveFill: true,
                        cursorColor: primaryColor,
                        animationDuration: const Duration(milliseconds: 300),
                        onChanged: (value) {},
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),

                // Timer com estilo minimalista
                Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: controller.isTimerRunning.value
                          ? primaryColor
                          : theme.colorScheme.error,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "Expira em: ".tr,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      controller.formatTime(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: controller.isTimerRunning.value
                            ? primaryColor
                            : theme.colorScheme.error,
                      ),
                    ),
                  ],
                )),

                // Espaçador que cresce para empurrar os botões para baixo
                Spacer(),

                // Botão de verificação com gradiente
                Container(
                  width: double.infinity,
                  height: screenHeight * 0.055,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [
                        primaryColor,
                        Color.lerp(primaryColor, secondaryColor, 0.6)!,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      await controller.verifyCode();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      "Verificar".tr,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

                // Botão "Reenviar código" estilizado e compacto
                Obx(() => TextButton.icon(
                  onPressed: controller.isTimerRunning.value
                      ? null
                      : () async {
                    await controller.resendCode();
                  },
                  icon: Icon(
                    Icons.refresh_rounded,
                    size: 18,
                    color: controller.isTimerRunning.value
                        ? textColor.withOpacity(0.4)
                        : primaryColor,
                  ),
                  label: Text(
                    "Reenviar Código".tr,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: controller.isTimerRunning.value
                          ? textColor.withOpacity(0.4)
                          : primaryColor,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                )),
                SizedBox(height: screenHeight * 0.03),
              ],
            ),
          ),
        ),
      ),
    );
  }
}