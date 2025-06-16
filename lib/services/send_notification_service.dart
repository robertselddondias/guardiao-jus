import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:guardiao_cliente/models/notification_model.dart';
import 'package:guardiao_cliente/repositories/notification_repository.dart';
import 'package:guardiao_cliente/utils/Preferences.dart';
import 'package:http/http.dart' as http;

class SendNotification {
  static const _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  /// URL do FCM para envio de mensagens
  static const String fcmUrl = 'https://fcm.googleapis.com/v1/projects/guardiao-jus/messages:send';

  static final NotificationRepository _notificationRepository = NotificationRepository();

  /// Obtenção do token de acesso a partir das credenciais da conta de serviço
  static Future<String> _getAccessToken(Map<String, dynamic> serviceAccountJson) async {
    try {
      final serviceAccountCredentials = ServiceAccountCredentials.fromJson(serviceAccountJson);
      final client = await clientViaServiceAccount(serviceAccountCredentials, _scopes);
      return client.credentials.accessToken.data;
    } catch (e) {
      debugPrint('Erro ao obter token de acesso: $e');
      rethrow;
    }
  }

  /// Envio de notificação para um único dispositivo
  static Future<bool> sendNotification({
    required String token,
    required String title,
    required String body,
    required Map<String, dynamic> payload,
    String androidSound = 'default',
    String iosSound = 'default',
  }) async {
    try {
      // Carregar credenciais da conta de serviço
      final account = await loadServiceAccountJson();

      // Obter o token de acesso
      final String accessToken = await _getAccessToken(account);

      // Corpo da notificação com som personalizado
      final notificationBody = {
        'message': {
          'token': token,
          'notification': {
            'title': title,
            'body': body,
          },
          'android': {
            'notification': {
              'sound': androidSound,
            },
          },
          'apns': {
            'payload': {
              'aps': {
                'alert': {
                  'title': title,
                  'body': body,
                },
                'sound': iosSound,
              },
            },
          },
          'data': payload,
        },
      };

      // Enviar a notificação
      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(notificationBody),
      );

      // Log de resposta
      debugPrint('FCM Response Status Code: ${response.statusCode}');
      debugPrint('FCM Response Body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('Notificação enviada com sucesso!');

        NotificationModel notificationModel = NotificationModel(
            title: title,
            body: body,
            type: 'INFO',
            createdAt: DateTime.now().toIso8601String(),
            payload: payload,
            isRead: false
        );
        await _notificationRepository.createNotification(notificationModel);

        return true;
      } else {
        debugPrint('Falha ao enviar notificação: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Erro ao enviar notificação: $e');
      return false;
    }
  }

  // Envio de notificação para um tópico
  static Future<bool> sendNotificationToTopic({
    required String topic,
    required String title,
    required String body,
    required Map<String, dynamic> payload,
    String androidSound = 'default',
    String iosSound = 'default',
  }) async {
    try {
      // Carregar credenciais da conta de serviço
      final account = await loadServiceAccountJson();

      // Obter o token de acesso
      final String accessToken = await _getAccessToken(account);

      // Corpo da notificação com som personalizado
      final notificationBody = {
        'message': {
          'topic': topic,
          'notification': {
            'title': title,
            'body': body,
          },
          'android': {
            'notification': {
              'sound': androidSound,
            },
          },
          'apns': {
            'payload': {
              'aps': {
                'alert': {
                  'title': title,
                  'body': body,
                },
                'sound': iosSound,
              },
            },
          },
          'data': payload,
        },
      };

      // Enviar a notificação
      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(notificationBody),
      );

      // Log de resposta
      debugPrint('FCM Response Status Code: ${response.statusCode}');
      debugPrint('FCM Response Body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('Notificação enviada para o tópico com sucesso!');

        NotificationModel notificationModel = NotificationModel(
            title: title,
            body: body,
            type: 'INFO',
            createdAt: DateTime.now().toIso8601String(),
            payload: payload,
            isRead: false,
            companyId: Preferences.getString('companyId')
        );
        await _notificationRepository.createNotification(notificationModel);
        return true;
      } else {
        debugPrint('Falha ao enviar notificação para o tópico: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Erro ao enviar notificação para o tópico: $e');
      return false;
    }
  }

  /// Carregar credenciais da conta de serviço
  static Future<Map<String, dynamic>> loadServiceAccountJson() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/files/serviceAccount.json');
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Erro ao carregar serviceAccount.json: $e');
    }
  }
}