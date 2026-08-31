import 'dart:convert';
import 'package:injectable/injectable.dart';

import 'notification_payload.dart';
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
    String? doseId,
    String? prescriptionItemId,
    bool includeSnooze = true,
  }) async {
    final payload = NotificationPayload(
      id: doseId ?? reminderId.toString(),
      type: 'medication',
      title: 'Time for your medication: $medicationName',
      body: 'Dosage: $dosage. Tap to record your dose.',
      data: {
        if (doseId != null) 'dose_id': doseId,
        if (prescriptionItemId != null)
          'prescription_item_id': prescriptionItemId,
      },
    );

    await _notificationService.scheduleAlarm(
      id: reminderId,
      title: 'Time for your medication: $medicationName',
      body: 'Dosage: $dosage. Tap to record your dose.',
      scheduledTime: scheduledTime,
      payload: jsonEncode(payload.toJson()),
      includeSnooze: includeSnooze,
    );
  }

  Future<void> scheduleSnoozeReminder({
    required int reminderId,
    required String medicationName,
    required DateTime snoozeTime,
    String? doseId,
    String? prescriptionItemId,
    bool includeSnooze = true,
  }) async {
    final payload = NotificationPayload(
      id: doseId ?? reminderId.toString(),
      type: 'medication',
      title: 'Snooze reminder: $medicationName',
      body: 'Reminder to take your scheduled dose.',
      data: {
        if (doseId != null) 'dose_id': doseId,
        if (prescriptionItemId != null)
          'prescription_item_id': prescriptionItemId,
      },
    );

    await _notificationService.scheduleAlarm(
      id: reminderId,
      title: 'Snooze reminder: $medicationName',
      body: 'Reminder to take your scheduled dose.',
      scheduledTime: snoozeTime,
      payload: jsonEncode(payload.toJson()),
      includeSnooze: includeSnooze,
    );
  }

  Future<void> cancelReminder(int reminderId) async {
    await _notificationService.cancelAlarm(reminderId);
  }

  Future<void> cancelAllReminders() async {
    await _notificationService.cancelAllAlarms();
  }
}
