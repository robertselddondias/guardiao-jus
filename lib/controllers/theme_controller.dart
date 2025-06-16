import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  Rx<ThemeMode> themeMode = ThemeMode.light.obs; // Padrão: light

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  void setTheme(ThemeMode mode) async {
    themeMode.value = mode;
    Get.changeThemeMode(mode);

    // Salva a escolha do tema
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.toString());
  }

  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedTheme = prefs.getString('themeMode');

    if (savedTheme == ThemeMode.dark.toString()) {
      themeMode.value = ThemeMode.dark;
    } else {
      themeMode.value = ThemeMode.light; // Padrão
    }
    Get.changeThemeMode(themeMode.value);
  }
}
