// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_native_timezone/flutter_native_timezone.dart';
// import 'package:timezone/data/latest_all.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
//
// class LocalNotificationService {
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   // Inicializa o serviço de notificações
//   static Future<void> initialize() async {
//     tz.initializeTimeZones();
//     final String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
//     tz.setLocalLocation(tz.getLocation(currentTimeZone));
//
//     const AndroidInitializationSettings androidSettings =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     const DarwinInitializationSettings iosSettings =
//     DarwinInitializationSettings(
//       requestSoundPermission: true,
//       requestBadgePermission: true,
//       requestAlertPermission: true,
//     );
//
//     const InitializationSettings settings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );
//
//     await _notificationsPlugin.initialize(settings);
//   }
//
//   // Exibir uma notificação instantaneamente
//   static Future<void> showNotification({
//     required int id,
//     required String title,
//     required String body,
//   }) async {
//     const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//       'default_channel', 'Notificações',
//       importance: Importance.max,
//       priority: Priority.high,
//       playSound: true,
//     );
//
//     const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
//
//     const NotificationDetails details = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );
//
//     await _notificationsPlugin.show(id, title, body, details);
//   }
//
//   // Agendar uma notificação para um horário específico
//   static Future<void> scheduleNotification({
//     required int id,
//     required String title,
//     required String body,
//     required DateTime scheduledTime,
//   }) async {
//     await _notificationsPlugin.zonedSchedule(
//       id,
//       title,
//       body,
//       tz.TZDateTime.from(scheduledTime, tz.local),
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'default_channel', 'Notificações',
//           importance: Importance.high,
//           priority: Priority.high,
//         ),
//         iOS: DarwinNotificationDetails(),
//       ),
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       uiLocalNotificationDateInterpretation:
//       UILocalNotificationDateInterpretation.absoluteTime,
//     );
//   }
//
//   // Cancelar uma notificação específica
//   static Future<void> cancelNotification(int id) async {
//     await _notificationsPlugin.cancel(id);
//   }
//
//   // Cancelar todas as notificações agendadas
//   static Future<void> cancelAllNotifications() async {
//     await _notificationsPlugin.cancelAll();
//   }
// }