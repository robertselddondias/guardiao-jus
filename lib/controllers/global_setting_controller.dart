import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/models/user_model.dart';
import 'package:guardiao_cliente/repositories/user_repository.dart';
import 'package:guardiao_cliente/utils/Preferences.dart';
import 'package:guardiao_cliente/widgets/snackbar_custom.dart';

class GlobalSettingController extends GetxController {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepository = UserRepository();

  @override
  void onInit() {
    super.onInit();
    _initializeFCMToken();
    loadVariables();
    _setupForegroundNotificationHandler();
  }

  Future<void> _initializeFCMToken() async {
    try {
      // Solicita permissões para notificações (caso necessário)
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Obtém o token FCM
        String? fcmToken = await _firebaseMessaging.getToken();
        if (fcmToken != null) {
          // Obtém o usuário atual
          User? currentUser = _auth.currentUser;
          if (currentUser != null) {
            // Atualiza o token FCM no Firestore
            await _firestore.collection('users').doc(currentUser.uid).update({
              'fcmToken': fcmToken,
            });
            print('FCM Token salvo com sucesso.');
          } else {
            print('Usuário não autenticado. Não foi possível salvar o FCM Token.');
          }
        } else {
          print('Não foi possível obter o FCM Token.');
        }
      } else {
        print('Permissão para notificações negada pelo usuário.');
      }
    } catch (e) {
      print('Erro ao inicializar o FCM Token: $e');
    }
  }

  void loadVariables() async {
    if (_auth.currentUser != null) {
      final UserModel userModel = await _userRepository.getUserById();
      if (userModel.uid!.isNotEmpty) {
        Preferences.setString('userId', userModel.uid!);
        if (userModel.name != null) {
          Preferences.setString('userName', userModel.name!);
        }
      }

      if (userModel.companyId != null && userModel.companyId!.isNotEmpty) {
        Preferences.setString('companyId', userModel.companyId!);
      }
    }
  }

  // Método para configurar o manuseio de notificações enquanto o app está em primeiro plano
  void _setupForegroundNotificationHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        // Aqui você pode exibir a notificação, exibir um alerta ou fazer qualquer ação
        // enquanto o app estiver aberto.

        // Exemplo de exibição simples com GetX ou qualquer outro widget que você esteja usando
        print('Recebida notificação: ${message.notification!.title}');
        print('Mensagem: ${message.notification!.body}');

        // Você pode usar um diálogo ou outro mecanismo para mostrar a notificação
        // Exemplo com GetX (diálogo simples):
        SnackbarCustom.showInfo(
          message.notification!.body ?? "Você tem uma nova notificação",
        );
      }
    });
  }
}