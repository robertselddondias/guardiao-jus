import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/controllers/splash_controller.dart';
import 'package:guardiao_cliente/themes/app_colors.dart';
import 'package:guardiao_cliente/themes/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GetBuilder<SplashController>(
        init: SplashController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: theme.primaryColor,
            body: Center(child: Image.asset("assets/images/logo.png",width: 200,)),
          );
        });
  }
}
