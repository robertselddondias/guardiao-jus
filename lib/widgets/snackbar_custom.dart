import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/themes/app_colors.dart'; // 🔥 Usa as cores do seu tema

class SnackbarCustom {
  static final bool _isLoaderOpen = false;

  // **🔹 Função para exibir um Snackbar de sucesso**
  static void showSuccess(String message, {String title = 'Sucesso'}) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle,
      textColor: Colors.white,
    );
  }

  // **🔹 Função para exibir um Snackbar de erro**
  static void showError(String message, {String title = 'Erro'}) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: AppColors.error,
      icon: Icons.error_outline,
      textColor: Colors.white,
    );
  }

  // **🔹 Função para exibir um Snackbar de informação**
  static void showInfo(String message, {String title = 'Informação'}) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: AppColors.info,
      icon: Icons.info_outline,
      textColor: Colors.white,
    );
  }

  // **🔹 Função para exibir um Snackbar de alerta**
  static void showWarning(String message, {String title = 'Alerta'}) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: AppColors.warning,
      icon: Icons.warning_amber_rounded,
      textColor: Colors.white,
    );
  }

  // **🔹 Função genérica para exibir um Snackbar estilizado**
  static void _showSnackbar({
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
    required Color textColor,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: backgroundColor,
        colorText: textColor,
        icon: Icon(icon, color: Colors.white, size: 28),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        snackStyle: SnackStyle.FLOATING, // 🔥 Visual mais moderno
        duration: const Duration(seconds: 3),
      );
    });
  }

  static bool isLoaderOpen() => _isLoaderOpen;
}