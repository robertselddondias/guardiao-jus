import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/widgets/snackbar_custom.dart';

class NotificationSettingsController extends GetxController {
  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observables for notification settings
  RxBool generalNotifications = false.obs;
  RxBool promotionalNotifications = false.obs;
  RxBool securityNotifications = false.obs;

  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSettings();
  }

  // Fetch current settings from Firestore
  Future<void> fetchSettings() async {
    try {
      isLoading.value = true;
      final User? user = _auth.currentUser;
      if (user == null) {
        SnackbarCustom.showError('Usuário não autenticado.');
        return;
      }

      final DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        generalNotifications.value = data['generalNotifications'] ?? false;
        promotionalNotifications.value = data['promotionalNotifications'] ?? false;
        securityNotifications.value = data['securityNotifications'] ?? false;
      }
    } catch (e) {
      SnackbarCustom.showError('Erro ao buscar configurações: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle general notifications
  void toggleGeneralNotifications() {
    generalNotifications.value = !generalNotifications.value;
  }

  // Toggle promotional notifications
  void togglePromotionalNotifications() {
    promotionalNotifications.value = !promotionalNotifications.value;
  }

  // Toggle security notifications
  void toggleSecurityNotifications() {
    securityNotifications.value = !securityNotifications.value;
  }

  // Save updated settings to Firestore
  Future<void> saveSettings() async {
    try {
      isLoading.value = true;
      final User? user = _auth.currentUser;
      if (user == null) {
        SnackbarCustom.showError('Usuário não autenticado.');
        return;
      }

      final Map<String, dynamic> settingsData = {
        'generalNotifications': generalNotifications.value,
        'promotionalNotifications': promotionalNotifications.value,
        'securityNotifications': securityNotifications.value,
      };

      await _firestore.collection('users').doc(user.uid).update(settingsData);
      Get.back();
      SnackbarCustom.showSuccess('Configurações salvas com sucesso!');
    } catch (e) {
      SnackbarCustom.showError('Erro ao salvar configurações: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
