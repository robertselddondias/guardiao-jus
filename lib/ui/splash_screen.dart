import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/controllers/splash_controller.dart';
import 'package:guardiao_cliente/themes/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
        init: SplashController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: AppColors.primary,
            body: Center(child: Image.asset("assets/images/logo.png",width: 200,)),
          );
        });
  }
}
