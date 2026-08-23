import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final class SystemExportNotifier {
  SystemExportNotifier([FlutterLocalNotificationsPlugin? notifications])
    : _notifications = notifications ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _notifications;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    await _notifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    _initialized = true;
  }

  Future<bool> ensurePermission() async {
    await initialize();

    final AndroidFlutterLocalNotificationsPlugin? android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    return (await android?.requestNotificationsPermission()) ?? true;
  }

  Future<void> notifyExportReady(String fileName) async {
    await initialize();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'fuelwise_export',
          'Exportações',
          channelDescription: 'Notificações de exportação concluída',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    final DateTime now = DateTime.now();
    await _notifications.show(
      id: now.millisecondsSinceEpoch ~/ 1000,
      title: 'Exportação concluída',
      body: 'O arquivo $fileName foi gerado.',
      notificationDetails: details,
    );
  }
}
