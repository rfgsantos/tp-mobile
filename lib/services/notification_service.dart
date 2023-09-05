import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file_plus/open_file_plus.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService() {
    initNotifications();
  }

  Future<void> initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('notification_icon');
    IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future<void> onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    print('Id: $id');
  }

  Future<void> onSelectNotification(String? payload) async {
    print('Payload: $payload');
    OpenFile.open(payload);
  }

  Future<void> showNotification(
      {String? title = 'Default title',
      String? body = 'Default body',
      String? payload}) async {
    const iOS = IOSNotificationDetails();
    const platform = NotificationDetails(iOS: iOS);

    return _flutterLocalNotificationsPlugin.show(0, title, body, platform,
        payload: payload);
  }
}
