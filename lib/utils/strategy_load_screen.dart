

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/models/user_model.dart';
import 'package:guardiao_cliente/repositories/user_repository.dart';
import 'package:guardiao_cliente/widgets/snackbar_custom.dart';
import 'package:guardiao_cliente/ui/home_screen.dart';
import 'package:guardiao_cliente/ui/login_screen.dart';
import 'package:guardiao_cliente/ui/new_user/address_screen.dart';
import 'package:guardiao_cliente/ui/new_user/military_data_screen.dart';
import 'package:guardiao_cliente/ui/new_user/personal_data_screen.dart';
import 'package:guardiao_cliente/utils/Preferences.dart';

class StrategyLoadScreen {

  static Future<void> validateAccess() async {
    try {
      final UserRepository userRepository = UserRepository();
      bool isLogin = FirebaseAuth.instance.currentUser != null ? true : false;
      if (isLogin == true) {
        UserModel? user = await userRepository.getUserById();
        if (user.isPersonalInfoComplete!
            && !user.isAdressInfoComplete!
            && !user.isMilitaryInfoComplete!) {
          Get.offAll(() => const AddressScreen());
        } else
        if (user.isPersonalInfoComplete! && user.isAdressInfoComplete! &&
            !user.isMilitaryInfoComplete!) {
          Get.offAll(() => const MilitaryDataScreen());
        } else
        if (!user.isPersonalInfoComplete! && !user.isAdressInfoComplete! &&
            !user.isMilitaryInfoComplete!) {
          Get.offAll(() => const PersonalDataScreen());
        } else {
          Preferences.setString('userId', user.uid!);
          Get.offAll(() => HomeScreen(), transition: Transition.downToUp, duration: const Duration(milliseconds: 500));
        }
      } else {
        FirebaseAuth.instance.signOut();
        Preferences.clearKeyData('userId');
        Preferences.clearKeyData('companyId');
        Get.offAll(() => LoginScreen());
      }
    } catch(e) {
      SnackbarCustom.showError('Erro ao efetuar o login: $e');
      FirebaseAuth.instance.signOut();
      Preferences.clearKeyData('userId');
      Get.offAll(() => const LoginScreen());
    }
  }
}