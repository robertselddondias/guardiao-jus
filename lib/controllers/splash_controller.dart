import 'dart:async';

import 'package:get/get.dart';
import 'package:guardiao_cliente/utils/strategy_load_screen.dart';

class SplashController extends GetxController {

  @override
  void onInit() {
    // TODO: implement onInit
    Timer(const Duration(seconds: 3), () => redirectScreen());
    super.onInit();
  }

  redirectScreen() async {
    StrategyLoadScreen.validateAccess();
  }
}
