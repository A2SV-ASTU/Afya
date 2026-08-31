import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:afyamind_mobile/core/notifications/local_alarm_scheduler.dart';
import 'package:afyamind_mobile/core/notifications/notification_payload.dart';
import 'package:afyamind_mobile/core/notifications/notification_service.dart';

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late MockNotificationService mockNotificationService;
  late LocalAlarmScheduler scheduler;

  setUpAll(() {
    registerFallbackValue(DateTime.now());
  });

  setUp(() {
    mockNotificationService = MockNotificationService();
    scheduler = LocalAlarmScheduler(mockNotificationService);
  });

  const testReminderId = 1001;
  const testMedicationName = 'Amoxicillin';
  const testDosage = '500mg';
  const testDoseId = 'dose_item_123';
  const testPrescriptionItemId = 'rx_item_456';
  final testScheduledTime = DateTime.parse('2026-08-29T08:00:00Z');

  group('LocalAlarmScheduler - scheduleMedicationReminder', () {
    test('schedules medication reminder with correct metadata and payload',
        () async {
      when(() => mockNotificationService.scheduleAlarm(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledTime: any(named: 'scheduledTime'),
            payload: any(named: 'payload'),
            includeSnooze: any(named: 'includeSnooze'),
          )).thenAnswer((_) async {});

      await scheduler.scheduleMedicationReminder(
        reminderId: testReminderId,
        medicationName: testMedicationName,
        dosage: testDosage,
        scheduledTime: testScheduledTime,
        doseId: testDoseId,
        prescriptionItemId: testPrescriptionItemId,
        includeSnooze: true,
      );

      final captured = verify(() => mockNotificationService.scheduleAlarm(
            id: testReminderId,
            title: 'Time for your medication: $testMedicationName',
            body: 'Dosage: $testDosage. Tap to record your dose.',
            scheduledTime: testScheduledTime,
            payload: captureAny(named: 'payload'),
            includeSnooze: true,
          )).captured;

      expect(captured.length, 1);
      final payloadJson =
          jsonDecode(captured.first as String) as Map<String, dynamic>;
      final payload = NotificationPayload.fromJson(payloadJson);

      expect(payload.id, testDoseId);
      expect(payload.type, 'medication');
      expect(payload.doseId, testDoseId);
      expect(payload.prescriptionItemId, testPrescriptionItemId);
    });

    test(
        'supports scheduling without snooze action when includeSnooze is false',
        () async {
      when(() => mockNotificationService.scheduleAlarm(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledTime: any(named: 'scheduledTime'),
            payload: any(named: 'payload'),
            includeSnooze: any(named: 'includeSnooze'),
          )).thenAnswer((_) async {});

      await scheduler.scheduleMedicationReminder(
        reminderId: testReminderId,
        medicationName: testMedicationName,
        dosage: testDosage,
        scheduledTime: testScheduledTime,
        doseId: testDoseId,
        prescriptionItemId: testPrescriptionItemId,
        includeSnooze: false,
      );

      verify(() => mockNotificationService.scheduleAlarm(
            id: testReminderId,
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledTime: testScheduledTime,
            payload: any(named: 'payload'),
            includeSnooze: false,
          )).called(1);
    });
  });

  group('LocalAlarmScheduler - scheduleSnoozeReminder', () {
    test('schedules snooze reminder with correct snooze metadata', () async {
      final snoozeTime = testScheduledTime.add(const Duration(minutes: 10));

      when(() => mockNotificationService.scheduleAlarm(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledTime: any(named: 'scheduledTime'),
            payload: any(named: 'payload'),
            includeSnooze: any(named: 'includeSnooze'),
          )).thenAnswer((_) async {});

      await scheduler.scheduleSnoozeReminder(
        reminderId: testReminderId,
        medicationName: testMedicationName,
        snoozeTime: snoozeTime,
        doseId: testDoseId,
        prescriptionItemId: testPrescriptionItemId,
        includeSnooze: true,
      );

      final captured = verify(() => mockNotificationService.scheduleAlarm(
            id: testReminderId,
            title: 'Snooze reminder: $testMedicationName',
            body: 'Reminder to take your scheduled dose.',
            scheduledTime: snoozeTime,
            payload: captureAny(named: 'payload'),
            includeSnooze: true,
          )).captured;

      expect(captured.length, 1);
      final payloadJson =
          jsonDecode(captured.first as String) as Map<String, dynamic>;
      final payload = NotificationPayload.fromJson(payloadJson);

      expect(payload.id, testDoseId);
      expect(payload.type, 'medication');
      expect(payload.doseId, testDoseId);
      expect(payload.prescriptionItemId, testPrescriptionItemId);
    });
  });

  group('LocalAlarmScheduler - Cancellation', () {
    test('cancelReminder forwards ID to NotificationService.cancelAlarm',
        () async {
      when(() => mockNotificationService.cancelAlarm(any()))
          .thenAnswer((_) async {});

      await scheduler.cancelReminder(testReminderId);

      verify(() => mockNotificationService.cancelAlarm(testReminderId))
          .called(1);
    });

    test(
        'cancelAllReminders forwards call to NotificationService.cancelAllAlarms',
        () async {
      when(() => mockNotificationService.cancelAllAlarms())
          .thenAnswer((_) async {});

      await scheduler.cancelAllReminders();

      verify(() => mockNotificationService.cancelAllAlarms()).called(1);
    });
  });

  group('NotificationPayload', () {
    test('serializes and deserializes correctly with dose getters', () {
      const payload = NotificationPayload(
        id: testDoseId,
        type: 'medication',
        title: 'Medication Alert',
        body: 'Take 500mg Amoxicillin',
        data: {
          'dose_id': testDoseId,
          'prescription_item_id': testPrescriptionItemId,
        },
      );

      final json = payload.toJson();
      final roundTrip = NotificationPayload.fromJson(json);

      expect(roundTrip.id, testDoseId);
      expect(roundTrip.type, 'medication');
      expect(roundTrip.title, 'Medication Alert');
      expect(roundTrip.body, 'Take 500mg Amoxicillin');
      expect(roundTrip.doseId, testDoseId);
      expect(roundTrip.prescriptionItemId, testPrescriptionItemId);
    });
  });
}
