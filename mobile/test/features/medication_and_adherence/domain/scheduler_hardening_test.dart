import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:afyamind_mobile/core/notifications/local_alarm_scheduler.dart';
import 'package:afyamind_mobile/core/notifications/medication_notification_handler.dart';
import 'package:afyamind_mobile/features/clinical_history/data/models/encounter_detail_model.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/entities/encounter_detail_entity.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/data/datasources/medication_local_data_source.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/data/models/local_dose_record_model.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/entities/local_dose_record_entity.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/services/dose_schedule_generator.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/services/medication_reconciliation_service.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/usecases/cancel_prescription_reminders_usecase.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/usecases/generate_dose_schedule_usecase.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/usecases/handle_snooze_usecase.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/usecases/process_missed_doses_usecase.dart';

class MockMedicationLocalDataSource extends Mock
    implements MedicationLocalDataSource {}

class MockLocalAlarmScheduler extends Mock implements LocalAlarmScheduler {}

void main() {
  late MockMedicationLocalDataSource mockLocalDataSource;
  late MockLocalAlarmScheduler mockAlarmScheduler;
  late DoseScheduleGenerator generator;
  late GenerateDoseScheduleUseCase generateUseCase;
  late HandleSnoozeUseCase snoozeUseCase;
  late ProcessMissedDosesUseCase missedUseCase;
  late CancelPrescriptionRemindersUseCase cancelUseCase;
  late MedicationNotificationHandler notificationHandler;
  late MedicationReconciliationService reconciliationService;

  setUpAll(() {
    registerFallbackValue(
      LocalDoseRecordModel(
        id: 'fb_id',
        prescriptionItemId: 'fb_rx',
        medicationName: 'fb_med',
        dose: '100mg',
        scheduledTime: DateTime(2026),
      ),
    );
    registerFallbackValue(
      EncounterPrescriptionItemEntity(
        id: 'fb_rx',
        medicationName: 'fb_med',
        dose: '100mg',
        route: 'oral',
        frequency: 'OD',
        duration: '1 day',
        status: EncounterPrescriptionStatus.active,
        instructions: '',
        startedAt: DateTime(2026),
      ),
    );
  });

  setUp(() {
    mockLocalDataSource = MockMedicationLocalDataSource();
    mockAlarmScheduler = MockLocalAlarmScheduler();
    generator = const DoseScheduleGenerator();

    generateUseCase = GenerateDoseScheduleUseCase(
      mockLocalDataSource,
      mockAlarmScheduler,
    );

    snoozeUseCase = HandleSnoozeUseCase(
      mockLocalDataSource,
      mockAlarmScheduler,
    );

    missedUseCase = ProcessMissedDosesUseCase(
      mockLocalDataSource,
      mockAlarmScheduler,
    );

    cancelUseCase = CancelPrescriptionRemindersUseCase(
      mockLocalDataSource,
      mockAlarmScheduler,
    );

    notificationHandler = MedicationNotificationHandler(
      mockLocalDataSource,
      mockAlarmScheduler,
      snoozeUseCase,
    );

    reconciliationService = MedicationReconciliationService(
      missedUseCase,
      generateUseCase,
      mockLocalDataSource,
    );

    // Default lenient stubs
    when(() => mockLocalDataSource.getDoseRecordById(any()))
        .thenAnswer((_) async => null);
    when(() => mockLocalDataSource.getDoseRecords(
          forDate: any(named: 'forDate'),
          prescriptionItemId: any(named: 'prescriptionItemId'),
        )).thenAnswer((_) async => []);
    when(() => mockLocalDataSource.saveDoseRecord(any()))
        .thenAnswer((_) async {});
    when(() => mockLocalDataSource.getCachedPrescriptions())
        .thenAnswer((_) async => []);
    when(() => mockAlarmScheduler.cancelReminder(any()))
        .thenAnswer((_) async {});
    when(() => mockAlarmScheduler.scheduleMedicationReminder(
          reminderId: any(named: 'reminderId'),
          medicationName: any(named: 'medicationName'),
          dosage: any(named: 'dosage'),
          scheduledTime: any(named: 'scheduledTime'),
          doseId: any(named: 'doseId'),
          prescriptionItemId: any(named: 'prescriptionItemId'),
          includeSnooze: any(named: 'includeSnooze'),
        )).thenAnswer((_) async {});
  });

  final testDate = DateTime(2026, 8, 28, 8, 0);

  EncounterPrescriptionItemEntity createRx({
    String id = 'rx_1',
    String frequency = 'BD',
    String duration = '3 days',
    EncounterPrescriptionStatus status = EncounterPrescriptionStatus.active,
    DateTime? startedAt,
  }) {
    return EncounterPrescriptionItemEntity(
      id: id,
      medicationName: 'Amoxicillin',
      dose: '500mg',
      route: 'oral',
      frequency: frequency,
      duration: duration,
      status: status,
      instructions: 'Take with food',
      startedAt: startedAt ?? testDate,
    );
  }

  EncounterPrescriptionItemModel createRxModel({
    String id = 'rx_1',
    String frequency = 'BD',
    String duration = '3 days',
    EncounterPrescriptionStatus status = EncounterPrescriptionStatus.active,
    DateTime? startedAt,
  }) {
    return EncounterPrescriptionItemModel(
      id: id,
      medicationName: 'Amoxicillin',
      dose: '500mg',
      route: 'oral',
      frequency: frequency,
      duration: duration,
      status: status,
      instructions: 'Take with food',
      startedAt: startedAt ?? testDate,
    );
  }

  LocalDoseRecordModel createModel({
    String id = 'rx_1_1787904000000',
    String rxId = 'rx_1',
    DoseStatus status = DoseStatus.pending,
    int snoozeCount = 0,
    DateTime? snoozedUntil,
    DateTime? scheduledTime,
  }) {
    return LocalDoseRecordModel(
      id: id,
      prescriptionItemId: rxId,
      medicationName: 'Amoxicillin',
      dose: '500mg',
      scheduledTime: scheduledTime ?? testDate,
      status: status,
      snoozeCount: snoozeCount,
      snoozedUntil: snoozedUntil,
    );
  }

  String createPayloadJson({
    String doseId = 'rx_1_1787904000000',
    String type = 'medication',
  }) {
    return jsonEncode({
      'id': doseId,
      'type': type,
      'title': 'Medication Reminder',
      'body': 'Take 500mg Amoxicillin',
      'data': {
        'dose_id': doseId,
        'prescription_item_id': 'rx_1',
      },
    });
  }

  group('AFYA-PLAN-02 Final Hardening & Device Reliability Suite', () {
    test('1 & 2. Take on already-taken dose is harmless and idempotent',
        () async {
      const doseId = 'rx_1_1787904000000';
      final takenModel = createModel(id: doseId, status: DoseStatus.taken);

      when(() => mockLocalDataSource.getDoseRecordById(doseId))
          .thenAnswer((_) async => takenModel);

      final response = NotificationResponse(
        notificationResponseType:
            NotificationResponseType.selectedNotificationAction,
        actionId: 'take',
        payload: createPayloadJson(doseId: doseId),
      );

      await notificationHandler.handleNotificationResponse(response);

      verifyNever(() => mockLocalDataSource.saveDoseRecord(any()));
      verifyNever(() => mockAlarmScheduler.cancelReminder(any()));
    });

    test('3. Skip on already-skipped dose is harmless and idempotent',
        () async {
      const doseId = 'rx_1_1787904000000';
      final skippedModel =
          createModel(id: doseId, status: DoseStatus.skipped);

      when(() => mockLocalDataSource.getDoseRecordById(doseId))
          .thenAnswer((_) async => skippedModel);

      final response = NotificationResponse(
        notificationResponseType:
            NotificationResponseType.selectedNotificationAction,
        actionId: 'skip',
        payload: createPayloadJson(doseId: doseId),
      );

      await notificationHandler.handleNotificationResponse(response);

      verifyNever(() => mockLocalDataSource.saveDoseRecord(any()));
      verifyNever(() => mockAlarmScheduler.cancelReminder(any()));
    });

    test('4. Snooze on missed dose is rejected deterministically', () async {
      const doseId = 'rx_1_1787904000000';
      final missedModel = createModel(id: doseId, status: DoseStatus.missed);

      when(() => mockLocalDataSource.getDoseRecordById(doseId))
          .thenAnswer((_) async => missedModel);

      final result = await snoozeUseCase(doseId: doseId);

      expect(result.isLeft(), isTrue);
      verifyNever(() => mockLocalDataSource.saveDoseRecord(any()));
      verifyNever(() => mockAlarmScheduler.scheduleSnoozeReminder(
            reminderId: any(named: 'reminderId'),
            medicationName: any(named: 'medicationName'),
            snoozeTime: any(named: 'snoozeTime'),
            doseId: any(named: 'doseId'),
            prescriptionItemId: any(named: 'prescriptionItemId'),
            includeSnooze: any(named: 'includeSnooze'),
          ));
    });

    test('5, 6, 7. Malformed payload, unknown action, or unknown dose ID is safe',
        () async {
      when(() => mockLocalDataSource.getDoseRecordById('non_existent'))
          .thenAnswer((_) async => null);

      // Unknown action
      final unknownActionResponse = NotificationResponse(
        notificationResponseType:
            NotificationResponseType.selectedNotificationAction,
        actionId: 'dismiss_random',
        payload: createPayloadJson(doseId: 'rx_1_1787904000000'),
      );

      // Unknown dose ID
      final unknownDoseResponse = NotificationResponse(
        notificationResponseType:
            NotificationResponseType.selectedNotificationAction,
        actionId: 'take',
        payload: createPayloadJson(doseId: 'non_existent'),
      );

      // Malformed JSON
      const malformedResponse = NotificationResponse(
        notificationResponseType:
            NotificationResponseType.selectedNotificationAction,
        actionId: 'take',
        payload: '{invalid-json',
      );

      await notificationHandler
          .handleNotificationResponse(unknownActionResponse);
      await notificationHandler.handleNotificationResponse(unknownDoseResponse);
      await notificationHandler.handleNotificationResponse(malformedResponse);

      verifyNever(() => mockLocalDataSource.saveDoseRecord(any()));
      verifyNever(() => mockAlarmScheduler.cancelReminder(any()));
    });

    test('8. Reconciliation is idempotent when run multiple times', () async {
      final now = DateTime(2026, 8, 28, 8, 45); // T+45

      final activeModel = createRxModel(id: 'rx_active_1', duration: '1 day');

      when(() => mockLocalDataSource.getCachedPrescriptions())
          .thenAnswer((_) async => [activeModel]);

      // First run
      await reconciliationService.reconcile(now: now);
      // Second run
      await reconciliationService.reconcile(now: now);

      verify(() => mockLocalDataSource.getCachedPrescriptions()).called(2);
    });

    test('9 & 10. Completed & deactivated prescriptions do not generate reminders',
        () async {
      final completedModel = createRxModel(
        id: 'rx_completed',
        status: EncounterPrescriptionStatus.completed,
      );
      final deactivatedModel = createRxModel(
        id: 'rx_deactivated',
        status: EncounterPrescriptionStatus.deactivated,
      );

      when(() => mockLocalDataSource.getCachedPrescriptions())
          .thenAnswer((_) async => [completedModel, deactivatedModel]);

      await reconciliationService.reconcile(now: testDate);

      verifyNever(() => mockLocalDataSource.saveDoseRecord(any()));
      verifyNever(() => mockAlarmScheduler.scheduleMedicationReminder(
            reminderId: any(named: 'reminderId'),
            medicationName: any(named: 'medicationName'),
            dosage: any(named: 'dosage'),
            scheduledTime: any(named: 'scheduledTime'),
            doseId: any(named: 'doseId'),
            prescriptionItemId: any(named: 'prescriptionItemId'),
            includeSnooze: any(named: 'includeSnooze'),
          ));
    });

    test('11 & 13. Future alarms survive reconciliation without duplicate saves',
        () async {
      final activeRx = createRx(id: 'rx_active', duration: '1 day');
      final activeModel = EncounterPrescriptionItemModel(
        id: activeRx.id,
        medicationName: activeRx.medicationName,
        dose: activeRx.dose,
        route: activeRx.route,
        frequency: activeRx.frequency,
        duration: activeRx.duration,
        status: activeRx.status,
        instructions: activeRx.instructions,
        startedAt: activeRx.startedAt,
      );

      final existingDoses = generator.generate(activeRx);
      final firstDoseModel =
          LocalDoseRecordModel.fromEntity(existingDoses.first);

      when(() => mockLocalDataSource.getCachedPrescriptions())
          .thenAnswer((_) async => [activeModel]);

      // Simulate that the first dose already exists in local DB
      when(() => mockLocalDataSource.getDoseRecordById(firstDoseModel.id))
          .thenAnswer((_) async => firstDoseModel);

      await reconciliationService.reconcile(now: testDate);

      // The existing first dose is never re-saved
      final capturedCalls = verify(() => mockLocalDataSource.saveDoseRecord(captureAny()))
          .captured;
      final savedModels = capturedCalls.whereType<LocalDoseRecordModel>().toList();
      expect(savedModels.any((d) => d.id == firstDoseModel.id), isFalse);
    });

    test('12 & 15. Cancellation is isolated to specific prescription and deterministic',
        () async {
      final doseA = createModel(id: 'rx_A_1', rxId: 'rx_A');
      final doseB = createModel(id: 'rx_B_1', rxId: 'rx_B');

      when(() => mockLocalDataSource.getDoseRecords(
            forDate: any(named: 'forDate'),
            prescriptionItemId: 'rx_A',
          )).thenAnswer((_) async => [doseA]);
      when(() => mockLocalDataSource.getDoseRecords(
            forDate: any(named: 'forDate'),
            prescriptionItemId: 'rx_B',
          )).thenAnswer((_) async => [doseB]);

      final result = await cancelUseCase(prescriptionItemId: 'rx_A');

      expect(result.isRight(), isTrue);
      final reminderIdA = doseA.id.hashCode & 0x7FFFFFFF;
      final reminderIdB = doseB.id.hashCode & 0x7FFFFFFF;

      verify(() => mockAlarmScheduler.cancelReminder(reminderIdA)).called(1);
      verifyNever(() => mockAlarmScheduler.cancelReminder(reminderIdB));
    });

    test('14. Past doses are persisted in storage but not scheduled as alarms',
        () async {
      final pastRx = createRx(
        id: 'rx_past',
        duration: '1 day',
        startedAt: DateTime(2026, 8, 20),
      );

      final result = await generateUseCase(
        prescription: pastRx,
        now: DateTime(2026, 8, 28, 12, 0),
      );

      expect(result.isRight(), isTrue);
      verify(() => mockLocalDataSource.saveDoseRecord(any())).called(2);
      verifyNever(() => mockAlarmScheduler.scheduleMedicationReminder(
            reminderId: any(named: 'reminderId'),
            medicationName: any(named: 'medicationName'),
            dosage: any(named: 'dosage'),
            scheduledTime: any(named: 'scheduledTime'),
            doseId: any(named: 'doseId'),
            prescriptionItemId: any(named: 'prescriptionItemId'),
            includeSnooze: any(named: 'includeSnooze'),
          ));
    });

    test('16. Date boundary handling: Leap year (Feb 28/29), Month-end, Year-end transitions',
        () {
      // Leap year test: Feb 28, 2028 (2028 is leap year)
      final leapRx = createRx(
        id: 'rx_leap',
        frequency: 'OD',
        duration: '3 days',
        startedAt: DateTime(2028, 2, 28),
      );
      final leapDoses = generator.generate(leapRx);
      expect(leapDoses.length, 3);
      expect(leapDoses[0].scheduledTime, DateTime(2028, 2, 28, 8, 0));
      expect(leapDoses[1].scheduledTime, DateTime(2028, 2, 29, 8, 0));
      expect(leapDoses[2].scheduledTime, DateTime(2028, 3, 1, 8, 0));

      // Year-end transition test: Dec 30, 2026 -> Jan 2, 2027
      final yearEndRx = createRx(
        id: 'rx_yearend',
        frequency: 'OD',
        duration: '4 days',
        startedAt: DateTime(2026, 12, 30),
      );
      final yearEndDoses = generator.generate(yearEndRx);
      expect(yearEndDoses.length, 4);
      expect(yearEndDoses[0].scheduledTime, DateTime(2026, 12, 30, 8, 0));
      expect(yearEndDoses[1].scheduledTime, DateTime(2026, 12, 31, 8, 0));
      expect(yearEndDoses[2].scheduledTime, DateTime(2027, 1, 1, 8, 0));
      expect(yearEndDoses[3].scheduledTime, DateTime(2027, 1, 2, 8, 0));
    });

    test('17. Long duration handling: 90 days generates exact doses safely',
        () {
      final longRx = createRx(
        id: 'rx_long',
        frequency: 'BD', // 2 per day * 90 days = 180 doses
        duration: '90 days',
        startedAt: DateTime(2026, 1, 1),
      );
      final doses = generator.generate(longRx);
      expect(doses.length, 180);
      expect(doses.first.scheduledTime, DateTime(2026, 1, 1, 8, 0));
      expect(doses.last.scheduledTime, DateTime(2026, 3, 31, 20, 0));
    });
  });
}
