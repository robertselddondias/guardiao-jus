import 'package:get/get.dart';
import 'package:guardiao_cliente/models/notification_model.dart';
import 'package:guardiao_cliente/repositories/notification_repository.dart';
import 'package:guardiao_cliente/widgets/snackbar_custom.dart';

class NotificationController extends GetxController {
  final NotificationRepository _notificationRepository = NotificationRepository();

  RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      final fetchedNotifications = await _notificationRepository.fetchNotificationsByUserId();
        notifications.value = fetchedNotifications;
    } catch (e) {
      SnackbarCustom.showError('Erro ao carregar notificações: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(NotificationModel notification) async {
    try {
      if (!notification.isRead) {
        await _notificationRepository.markAsRead(notification.id!);
        notification.isRead = true;
        notifications.refresh();
        fetchNotifications();
      }
    } catch (e) {
      SnackbarCustom.showError('Erro ao marcar notificação como lida: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _notificationRepository.markAllAsRead();
      for (var notification in notifications) {
        notification.isRead = true;
      }
      notifications.refresh();
      fetchNotifications();
      SnackbarCustom.showSuccess('Todas as notificações foram marcadas como lidas.');
    } catch (e) {
      SnackbarCustom.showError('Erro ao marcar todas como lidas: $e');
    }
  }
}