import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/lang/app_pt.dart';

class LocalizationService extends Translations {
  // Default locale
  static const locale = Locale('pt');

  static final locales = [
    const Locale('pt'),
  ];

  // Keys and their translations
  // Translations are separated maps in `lang` file
  @override
  Map<String, Map<String, String>> get keys => {
        'pt': ptPO,
      };

  // Gets locale from language, and updates the locale
  void changeLocale(String lang) {
    Get.updateLocale(Locale(lang));
  }
}
