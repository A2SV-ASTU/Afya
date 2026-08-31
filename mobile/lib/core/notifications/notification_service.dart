import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

@lazySingleton
class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  void Function(NotificationResponse)? _onNotificationResponse;

  NotificationService()
      : _notificationsPlugin = FlutterLocalNotificationsPlugin();

  NotificationService.withPlugin(FlutterLocalNotificationsPlugin plugin)
      : _notificationsPlugin = plugin;

  static const String medicationChannelId = 'medication_reminders';
  static const String medicationChannelName = 'Medication Reminders';
  static const String medicationChannelDescription =
      'Scheduled reminders for patient medication doses';

  Future<void> initialize({
    void Function(NotificationResponse)? onResponse,
  }) async {
    _onNotificationResponse = onResponse;
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosSettings = DarwinInitializationSettings(
      notificationCategories: [
        DarwinNotificationCategory(
          'medication_category',
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.plain('take', 'Take'),
            DarwinNotificationAction.plain('snooze', 'Snooze'),
            DarwinNotificationAction.plain('skip', 'Skip'),
          ],
        ),
      ],
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );
  }

  void _handleNotificationResponse(NotificationResponse response) {
    try {
      _onNotificationResponse?.call(response);
    } catch (_) {
      // Safely ignore callback errors to avoid app crashes
    }
  }

  Future<void> scheduleAlarm({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    bool includeSnooze = true,
  }) async {
    final androidActions = <AndroidNotificationAction>[
      const AndroidNotificationAction(
        'take',
        'Take',
        showsUserInterface: true,
      ),
      if (includeSnooze)
        const AndroidNotificationAction(
          'snooze',
          'Snooze',
        ),
      const AndroidNotificationAction(
        'skip',
        'Skip',
      ),
    ];

    final androidDetails = AndroidNotificationDetails(
      medicationChannelId,
      medicationChannelName,
      channelDescription: medicationChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      actions: androidActions,
    );

    const iosDetails = DarwinNotificationDetails(
      categoryIdentifier: 'medication_category',
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (_) {
      try {
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          tzScheduledTime,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: payload,
        );
      } catch (_) {
        // Safe fail without crashing the app
      }
    }
  }

  Future<void> cancelAlarm(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllAlarms() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<bool?> requestPermissions() async {
    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final androidGranted =
        await androidImplementation?.requestNotificationsPermission();

    final iosImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    final iosGranted = await iosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    return androidGranted ?? iosGranted;
  }
}
