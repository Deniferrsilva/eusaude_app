import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';
import 'package:permission_handler/permission_handler.dart'; // ✅ adicionado

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        // Handle iOS notification in foreground
      },
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          print('Notification payload: ${response.payload}');
        }
      },
    );

    // ✅ Criação dos canais
    final androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          'default_channel',
          'Default Notifications',
          description: 'Channel for default notifications',
          importance: Importance.high,
        ),
      );

      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          'scheduled_channel',
          'Scheduled Notifications',
          description: 'Channel for scheduled notifications',
          importance: Importance.high,
        ),
      );
    }

    // ✅ Permissão no Android 13+ via permission_handler
    if (Platform.isAndroid && await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Notifications',
      channelDescription: 'Channel for default notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

static Future<void> scheduleNotification({
  required int id,
  required String title,
  required String body,
  required DateTime scheduledDate,
  String? payload,
}) async {
  final scheduledTZDate = tz.TZDateTime.from(
    scheduledDate,
    tz.getLocation('America/Sao_Paulo'),
  );

  print('Agendando notificação para $scheduledDate → $scheduledTZDate');

  await _notifications.zonedSchedule(
    id,
    title,
    body,
    scheduledTZDate,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'scheduled_channel',
        'Scheduled Notifications',
        channelDescription: 'Channel for scheduled notifications',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    ),
    androidAllowWhileIdle: true,
    payload: payload,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );

  print('Notificação agendada com sucesso!');
}

}
