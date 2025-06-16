import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guardiao_cliente/utils/Preferences.dart';

import '../models/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = "notifications";

  // Criar uma nova notificação
  Future<void> createNotification(NotificationModel notification) async {
    try {
      var doc = _firestore.collection(collectionName).doc();
      notification.id = doc.id;
      await doc.set(notification.toMap());
    } catch (e) {
      throw Exception('Erro ao criar notificação: $e');
    }
  }

  Stream<int> listenUnreadCount() {
    try {
      return _firestore
          .collection(collectionName)
          .where('toUserId', isEqualTo: Preferences.getString('userId'))
          .where('isRead', isEqualTo: false)
          .snapshots()
          .map((querySnapshot) => querySnapshot.docs.length);
    } catch (e) {
      throw Exception('Erro ao ouvir notificações não lidas: $e');
    }
  }

  // Buscar todas as notificações de um usuário
  Future<List<NotificationModel>> fetchNotificationsByUserId() async {
    try {
      final querySnapshot = await _firestore
          .collection(collectionName)
          .where('toUserId', isEqualTo: Preferences.getString('userId'))
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar notificações: $e');
    }
  }

  // Buscar todas as notificações de um usuário
  Future<List<NotificationModel>> fetchNotificationsByCompanyId() async {
    try {
      final querySnapshot = await _firestore
          .collection(collectionName)
          .where('toUserId', isEqualTo: Preferences.getString('userId'))
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar notificações: $e');
    }
  }

  // Buscar notificações não lidas de um usuário
  Future<List<NotificationModel>> fetchUnreadNotifications() async {
    try {
      final querySnapshot = await _firestore
          .collection(collectionName)
          .where('toUserId', isEqualTo: Preferences.getString('userId'))
          .where('isRead', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar notificações não lidas: $e');
    }
  }

  // Marcar uma notificação como lida
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection(collectionName).doc(notificationId).update({'isRead': true});
    } catch (e) {
      throw Exception('Erro ao marcar notificação como lida: $e');
    }
  }

  // Marcar todas as notificações de um usuário como lidas
  Future<void> markAllAsRead() async {
    try {
      final batch = _firestore.batch();
      final querySnapshot = await _firestore
          .collection(collectionName)
          .where('toUserId', isEqualTo: Preferences.getString('userId'))
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao marcar todas as notificações como lidas: $e');
    }
  }

  // Excluir uma notificação
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection(collectionName).doc(notificationId).delete();
    } catch (e) {
      throw Exception('Erro ao excluir notificação: $e');
    }
  }

  // Excluir todas as notificações de um usuário
  Future<void> deleteAllNotifications(String userId) async {
    try {
      final batch = _firestore.batch();
      final querySnapshot = await _firestore
          .collection(collectionName)
          .where('toUserId', isEqualTo: Preferences.getString('userId'))
          .get();

      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao excluir todas as notificações: $e');
    }
  }
}