import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:afyamind_mobile/core/notifications/local_alarm_scheduler.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/entities/encounter_detail_entity.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/data/datasources/medication_local_data_source.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/data/models/local_dose_record_model.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/entities/local_dose_record_entity.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/services/dose_schedule_generator.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/services/posology_parser.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/usecases/generate_dose_schedule_usecase.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/usecases/handle_snooze_usecase.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/usecases/process_missed_doses_usecase.dart';

class MockMedicationLocalDataSource extends Mock
    implements MedicationLocalDataSource {}

class MockLocalAlarmScheduler extends Mock implements LocalAlarmScheduler {}

void main() {
  late MockMedicationLocalDataSource mockLocalDataSource;
  late MockLocalAlarmScheduler mockAlarmScheduler;

  late GenerateDoseScheduleUseCase generateScheduleUseCase;
  late HandleSnoozeUseCase handleSnoozeUseCase;
  late ProcessMissedDosesUseCase processMissedDosesUseCase;

  // In-memory fake local database simulating MedicationLocalDataSource
  late Map<String, LocalDoseRecordModel> inMemoryDoseDb;

  setUpAll(() {
    registerFallbackValue(
      LocalDoseRecordModel(
        id: 'fallback_id',
        prescriptionItemId: 'fallback_rx',
        medicationName: 'Fallback',
        dose: '100mg',
        scheduledTime: DateTime(2026, 1, 1),
        status: DoseStatus.pending,
      ),
    );
    registerFallbackValue(DateTime.now());
  });

  setUp(() {
    mockLocalDataSource = MockMedicationLocalDataSource();
    mockAlarmScheduler = MockLocalAlarmScheduler();
    inMemoryDoseDb = {};

    // Wire in-memory storage to mockLocalDataSource
    when(() => mockLocalDataSource.getDoseRecordById(any()))
        .thenAnswer((invocation) async {
      final id = invocation.positionalArguments.first as String;
      return inMemoryDoseDb[id];
    });

    when(() => mockLocalDataSource.saveDoseRecord(any()))
        .thenAnswer((invocation) async {
      final model =
          invocation.positionalArguments.first as LocalDoseRecordModel;
      inMemoryDoseDb[model.id] = model;
    });

    when(() => mockLocalDataSource.getDoseRecords(
          prescriptionItemId: any(named: 'prescriptionItemId'),
        )).thenAnswer((invocation) async {
      final rxId = invocation.namedArguments[#prescriptionItemId] as String?;
      if (rxId != null) {
        return inMemoryDoseDb.values
            .where((m) => m.prescriptionItemId == rxId)
            .toList();
      }
      return inMemoryDoseDb.values.toList();
    });

    when(() => mockAlarmScheduler.scheduleMedicationReminder(
          reminderId: any(named: 'reminderId'),
          medicationName: any(named: 'medicationName'),
          dosage: any(named: 'dosage'),
          scheduledTime: any(named: 'scheduledTime'),
          doseId: any(named: 'doseId'),
          prescriptionItemId: any(named: 'prescriptionItemId'),
          includeSnooze: any(named: 'includeSnooze'),
        )).thenAnswer((_) async {});

    when(() => mockAlarmScheduler.scheduleSnoozeReminder(
          reminderId: any(named: 'reminderId'),
          medicationName: any(named: 'medicationName'),
          snoozeTime: any(named: 'snoozeTime'),
          doseId: any(named: 'doseId'),
          prescriptionItemId: any(named: 'prescriptionItemId'),
          includeSnooze: any(named: 'includeSnooze'),
        )).thenAnswer((_) async {});

    when(() => mockAlarmScheduler.cancelReminder(any()))
        .thenAnswer((_) async {});

    generateScheduleUseCase = GenerateDoseScheduleUseCase.withGenerator(
      mockLocalDataSource,
      mockAlarmScheduler,
      generator: const DoseScheduleGenerator(parser: PosologyParser()),
    );
    handleSnoozeUseCase =
        HandleSnoozeUseCase(mockLocalDataSource, mockAlarmScheduler);
    processMissedDosesUseCase =
        ProcessMissedDosesUseCase(mockLocalDataSource, mockAlarmScheduler);
  });

  test('Full Dose Scheduler & Bounded Snooze Lifecycle Integration Scenario',
      () async {
    // 1. Create an active prescription: Amoxicillin 500mg, BD, 3 days
    final startDate = DateTime(2026, 8, 28, 0, 0);
    final prescription = EncounterPrescriptionItemEntity(
      id: 'rx_amox_001',
      medicationName: 'Amoxicillin',
      dose: '500mg',
      route: 'oral',
      frequency: 'Twice daily (BD)',
      duration: '3 days',
      status: EncounterPrescriptionStatus.active,
      instructions: 'Take with food',
      startedAt: startDate,
    );

    // 2. Generate schedule at 06:00 (before first dose at 08:00)
    final generationTime = DateTime(2026, 8, 28, 6, 0);
    final scheduleResult = await generateScheduleUseCase(
      prescription: prescription,
      now: generationTime,
    );

    // 3. Verify 6 dose records are produced and persisted
    expect(scheduleResult.isRight(), isTrue);
    final doses = scheduleResult.getOrElse((_) => []);
    expect(doses.length, 6);
    expect(inMemoryDoseDb.length, 6);

    // Verify scheduled times: Day 1 (08:00, 20:00), Day 2 (08:00, 20:00), Day 3 (08:00, 20:00)
    final firstDose = doses.first;
    expect(firstDose.scheduledTime, DateTime(2026, 8, 28, 8, 0));
    expect(firstDose.status, DoseStatus.pending);
    expect(firstDose.snoozeCount, 0);
    expect(firstDose.snoozedUntil, isNull);

    // 4. Verify alarms scheduled for all 6 future doses
    verify(() => mockAlarmScheduler.scheduleMedicationReminder(
          reminderId: any(named: 'reminderId'),
          medicationName: 'Amoxicillin',
          dosage: '500mg',
          scheduledTime: any(named: 'scheduledTime'),
          doseId: any(named: 'doseId'),
          prescriptionItemId: 'rx_amox_001',
          includeSnooze: true,
        )).called(6);

    // 5 & 6. Select first dose at T+0 (08:00) and perform Snooze #1
    final snooze1Result = await handleSnoozeUseCase(doseId: firstDose.id);

    // 7. Verify Snooze #1: snoozeCount = 1, snoozedUntil = T+10 (08:10), status remains pending
    expect(snooze1Result.isRight(), isTrue);
    final snoozed1Dose = snooze1Result.getOrElse((_) => throw Exception());
    expect(snoozed1Dose.snoozeCount, 1);
    expect(snoozed1Dose.snoozedUntil, DateTime(2026, 8, 28, 8, 10));
    expect(snoozed1Dose.status, DoseStatus.pending);
    expect(inMemoryDoseDb[firstDose.id]?.snoozeCount, 1);
    expect(inMemoryDoseDb[firstDose.id]?.snoozedUntil,
        DateTime(2026, 8, 28, 8, 10));

    verify(() => mockAlarmScheduler.scheduleSnoozeReminder(
          reminderId: any(named: 'reminderId'),
          medicationName: 'Amoxicillin',
          snoozeTime: DateTime(2026, 8, 28, 8, 10),
          doseId: firstDose.id,
          prescriptionItemId: 'rx_amox_001',
          includeSnooze: true,
        )).called(1);

    // 8. Snooze #2
    final snooze2Result = await handleSnoozeUseCase(doseId: firstDose.id);

    // 9. Verify Snooze #2: snoozeCount = 2, snoozedUntil = T+20 (08:20), status remains pending, final reminder (includeSnooze = false)
    expect(snooze2Result.isRight(), isTrue);
    final snoozed2Dose = snooze2Result.getOrElse((_) => throw Exception());
    expect(snoozed2Dose.snoozeCount, 2);
    expect(snoozed2Dose.snoozedUntil, DateTime(2026, 8, 28, 8, 20));
    expect(snoozed2Dose.status, DoseStatus.pending);
    expect(inMemoryDoseDb[firstDose.id]?.snoozeCount, 2);
    expect(inMemoryDoseDb[firstDose.id]?.snoozedUntil,
        DateTime(2026, 8, 28, 8, 20));

    verify(() => mockAlarmScheduler.scheduleSnoozeReminder(
          reminderId: any(named: 'reminderId'),
          medicationName: 'Amoxicillin',
          snoozeTime: DateTime(2026, 8, 28, 8, 20),
          doseId: firstDose.id,
          prescriptionItemId: 'rx_amox_001',
          includeSnooze: false,
        )).called(1);

    // 10. Attempt Snooze #3
    final snooze3Result = await handleSnoozeUseCase(doseId: firstDose.id);

    // 11. Verify Snooze #3 is rejected (snoozeCount remains 2, snoozedUntil remains 08:20)
    expect(snooze3Result.isLeft(), isTrue);
    expect(inMemoryDoseDb[firstDose.id]?.snoozeCount, 2);
    expect(inMemoryDoseDb[firstDose.id]?.snoozedUntil,
        DateTime(2026, 8, 28, 8, 20));

    // 12. Process missed doses after T+30 (08:35) for unresolved dose
    final missedProcessingTime = DateTime(2026, 8, 28, 8, 35);
    final missedResult = await processMissedDosesUseCase(
      now: missedProcessingTime,
      prescriptionItemId: 'rx_amox_001',
    );

    // 13. Verify first dose transitions to DoseStatus.missed
    expect(missedResult.isRight(), isTrue);
    final transitionedDoses = missedResult.getOrElse((_) => []);
    expect(transitionedDoses.length, 1);
    expect(transitionedDoses.first.id, firstDose.id);
    expect(transitionedDoses.first.status, DoseStatus.missed);
    expect(transitionedDoses.first.recordedAt, missedProcessingTime);
    expect(inMemoryDoseDb[firstDose.id]?.status, DoseStatus.missed);

    // 14. Verify reminder alarm is cancelled when dose becomes missed
    final expectedReminderId = firstDose.id.hashCode & 0x7FFFFFFF;
    verify(() => mockAlarmScheduler.cancelReminder(expectedReminderId))
        .called(1);

    // Remaining 5 doses remain pending and unmodified
    final remainingPendingDoses = inMemoryDoseDb.values
        .where((m) => m.status == DoseStatus.pending)
        .toList();
    expect(remainingPendingDoses.length, 5);
  });
}
