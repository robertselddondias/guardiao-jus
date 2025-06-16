import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/ui/credit_card_list_screen.dart';
import 'package:guardiao_cliente/ui/edit_profile_screen.dart';
import 'package:guardiao_cliente/ui/login_screen.dart';
import 'package:guardiao_cliente/ui/notification_settings_screen.dart';
import 'package:guardiao_cliente/utils/Preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  // Observables
  var isDarkMode = false.obs;
  var userName = ''.obs;
  var userPhotoUrl = ''.obs;
  var userEmail = ''.obs;

  // Firebase Instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() async {
    super.onInit();
    await loadThemePreference();
    await fetchUserData();
  }

  // Alternar tema
  Future<void> toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);

    // Salvar preferência de tema
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDarkMode.value);
  }

  // Carregar preferências de tema
  Future<void> loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool('isDarkMode') ?? false;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  // Buscar dados do usuário logado
  Future<void> fetchUserData() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        final DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          userName.value = data['name'] ?? 'Usuário';
          userPhotoUrl.value = data['photoUrl'] ?? '';
          userEmail.value = data['email'] ?? '';
        }
      }
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao buscar dados do usuário: $e');
    }
  }

  // Editar perfil
  void editProfile() {
    Get.to(() => EditProfileScreen())?.then((_) => fetchUserData());
  }

  // Configurar notificações
  void configureNotifications() {
    Get.to(() => NotificationSettingsScreen());
  }

  // Métodos de pagamento
  void managePaymentMethods() {
    Get.to(() => CreditCardListScreen());
  }

  // Sair
  Future<void> logout() async {
    Preferences.clearKeyData('userId');
    await _auth.signOut();
    Get.to(() => LoginScreen());
  }
}
