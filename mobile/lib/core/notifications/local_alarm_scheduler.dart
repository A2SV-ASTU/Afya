import 'package:injectable/injectable.dart';
import 'notification_service.dart';

@lazySingleton
class LocalAlarmScheduler {
  final NotificationService _notificationService;

  LocalAlarmScheduler(this._notificationService);

  Future<void> scheduleMedicationReminder({
    required int reminderId,
    required String medicationName,
    required String dosage,
    required DateTime scheduledTime,
  }) async {
    await _notificationService.scheduleAlarm(
      id: reminderId,
      title: 'Time for your medication: $medicationName',
      body: 'Dosage: $dosage. Tap to record your dose.',
      scheduledTime: scheduledTime,
    );
  }

  Future<void> scheduleSnoozeReminder({
    required int reminderId,
    required String medicationName,
    required DateTime snoozeTime,
  }) async {
    await _notificationService.scheduleAlarm(
      id: reminderId,
      title: 'Snooze reminder: $medicationName',
      body: 'Reminder to take your scheduled dose.',
      scheduledTime: snoozeTime,
    );
  }

  Future<void> cancelReminder(int reminderId) async {
    await _notificationService.cancelAlarm(reminderId);
  }
}
