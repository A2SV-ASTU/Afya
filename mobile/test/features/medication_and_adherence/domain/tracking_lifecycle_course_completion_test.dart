import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:afyamind_mobile/core/notifications/local_alarm_scheduler.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/entities/encounter_detail_entity.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/data/datasources/medication_local_data_source.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/data/models/local_dose_record_model.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/entities/local_dose_record_entity.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/models/medication_course_progress.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/usecases/cancel_prescription_reminders_usecase.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/usecases/process_missed_doses_usecase.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/usecases/stop_medication_tracking_usecase.dart';

class MockMedicationLocalDataSource extends Mock
    implements MedicationLocalDataSource {}

class MockLocalAlarmScheduler extends Mock implements LocalAlarmScheduler {}

class FakeLocalDoseRecordModel extends Fake implements LocalDoseRecordModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeLocalDoseRecordModel());
  });

  late MockMedicationLocalDataSource mockDataSource;
  late MockLocalAlarmScheduler mockAlarmScheduler;
  late CancelPrescriptionRemindersUseCase cancelRemindersUseCase;
  late StopMedicationTrackingUseCase stopTrackingUseCase;
  late ProcessMissedDosesUseCase processMissedDosesUseCase;

  final startDate = DateTime(2026, 9, 2, 8, 0);
  final day1 = DateTime(2026, 9, 2, 8, 0);
  final day2 = DateTime(2026, 9, 3, 8, 0);
  final day3 = DateTime(2026, 9, 4, 8, 0);
  final day4 = DateTime(2026, 9, 5, 8, 0);
  final day5 = DateTime(2026, 9, 6, 8, 0);

  final tRxVitaminE = EncounterPrescriptionItemEntity(
    id: 'rx_vit_e',
    medicationName: 'Vitamin E',
    dose: '400 IU',
    route: 'Oral Capsule',
    frequency: '1 capsule once daily',
    duration: '5 days (5 capsules total)',
    status: EncounterPrescriptionStatus.active,
    instructions: 'Take 1 capsule daily with food',
    startedAt: startDate,
    isTrackingActive: true,
  );

  setUp(() {
    mockDataSource = MockMedicationLocalDataSource();
    mockAlarmScheduler = MockLocalAlarmScheduler();

    cancelRemindersUseCase = CancelPrescriptionRemindersUseCase(
      mockDataSource,
      mockAlarmScheduler,
    );

    stopTrackingUseCase = StopMedicationTrackingUseCase(
      mockDataSource,
      cancelRemindersUseCase,
    );

    processMissedDosesUseCase = ProcessMissedDosesUseCase(
      mockDataSource,
      mockAlarmScheduler,
    );

    when(() => mockAlarmScheduler.cancelReminder(any()))
        .thenAnswer((_) async {});
  });

  group('Part 10 — Course Tracking Lifecycle & Completion Tests', () {
    test('TEST 1: Normal Completion — 5/5 Taken -> Course Completed, Tracking Stopped', () {
      final records = [
        LocalDoseRecordEntity(
          id: 'd1',
          prescriptionItemId: 'rx_vit_e',
          medicationName: 'Vitamin E',
          dose: '400 IU',
          scheduledTime: day1,
          status: DoseStatus.taken,
        ),
        LocalDoseRecordEntity(
          id: 'd2',
          prescriptionItemId: 'rx_vit_e',
          medicationName: 'Vitamin E',
          dose: '400 IU',
          scheduledTime: day2,
          status: DoseStatus.taken,
        ),
        LocalDoseRecordEntity(
          id: 'd3',
          prescriptionItemId: 'rx_vit_e',
          medicationName: 'Vitamin E',
          dose: '400 IU',
          scheduledTime: day3,
          status: DoseStatus.taken,
        ),
        LocalDoseRecordEntity(
          id: 'd4',
          prescriptionItemId: 'rx_vit_e',
          medicationName: 'Vitamin E',
          dose: '400 IU',
          scheduledTime: day4,
          status: DoseStatus.taken,
        ),
        LocalDoseRecordEntity(
          id: 'd5',
          prescriptionItemId: 'rx_vit_e',
          medicationName: 'Vitamin E',
          dose: '400 IU',
          scheduledTime: day5,
          status: DoseStatus.taken,
        ),
      ];

      final progress = MedicationCourseProgress.calculate(
        prescription: tRxVitaminE,
        doseRecords: records,
      );

      expect(progress.totalScheduled, 5);
      expect(progress.takenCount, 5);
      expect(progress.remainingCount, 0);
      expect(progress.isComplete, true);
      // When course is complete, tracking is no longer active
      expect(progress.isTrackingActive, false);
      expect(progress.completionRatio, 1.0);
    });

    test('TEST 2: Missed Dose — 2 Taken, 1 Missed, 2 Pending -> Missed not counted as taken, tracking remains active', () {
      final records = [
        LocalDoseRecordEntity(
          id: 'd1',
          prescriptionItemId: 'rx_vit_e',
          medicationName: 'Vitamin E',
          dose: '400 IU',
          scheduledTime: day1,
          status: DoseStatus.taken,
        ),
        LocalDoseRecordEntity(
          id: 'd2',
          prescriptionItemId: 'rx_vit_e',
          medicationName: 'Vitamin E',
          dose: '400 IU',
          scheduledTime: day2,
          status: DoseStatus.taken,
        ),
        LocalDoseRecordEntity(
          id: 'd3',
          prescriptionItemId: 'rx_vit_e',
          medicationName: 'Vitamin E',
          dose: '400 IU',
          scheduledTime: day3,
          status: DoseStatus.missed,
        ),
        LocalDoseRecordEntity(
          id: 'd4',
          prescriptionItemId: 'rx_vit_e',
          medicationName: 'Vitamin E',
          dose: '400 IU',
          scheduledTime: day4,
          status: DoseStatus.pending,
        ),
        LocalDoseRecordEntity(
          id: 'd5',
          prescriptionItemId: 'rx_vit_e',
          medicationName: 'Vitamin E',
          dose: '400 IU',
          scheduledTime: day5,
          status: DoseStatus.pending,
        ),
      ];

      final progress = MedicationCourseProgress.calculate(
        prescription: tRxVitaminE,
        doseRecords: records,
      );

      expect(progress.totalScheduled, 5);
      expect(progress.takenCount, 2);
      expect(progress.missedCount, 1);
      expect(progress.pendingCount, 2);
      // 5 total - 2 taken = 3 remaining to satisfy full prescribed course
      expect(progress.remainingCount, 3);
      expect(progress.isComplete, false);
      expect(progress.isTrackingActive, true);
    });

    test('TEST 3: Missed Day Does NOT Reset Start Date or Shorten Course', () {
      final records = [
        LocalDoseRecordEntity(
          id: 'd1',
          prescriptionItemId: 'rx_vit_e',
          medicationName: 'Vitamin E',
          dose: '400 IU',
          scheduledTime: day1,
          status: DoseStatus.taken,
        ),
        LocalDoseRecordEntity(
          id: 'd2',
          prescriptionItemId: 'rx_vit_e',
          medicationName: 'Vitamin E',
          dose: '400 IU',
          scheduledTime: day2,
          status: DoseStatus.missed,
        ),
        LocalDoseRecordEntity(
          id: 'd3',
          prescriptionItemId: 'rx_vit_e',
          medicationName: 'Vitamin E',
          dose: '400 IU',
          scheduledTime: day3,
          status: DoseStatus.pending,
        ),
      ];

      final progress = MedicationCourseProgress.calculate(
        prescription: tRxVitaminE,
        doseRecords: records,
      );

      // Start date MUST remain original date (Sep 2, 2026), never overwritten with today
      expect(progress.startDate, startDate);
      expect(tRxVitaminE.startedAt, startDate);
      expect(progress.takenCount, 1);
      expect(progress.missedCount, 1);
      expect(progress.isComplete, false);
    });

    test('TEST 4: Calendar End Date Passing with Missed Doses Does NOT Mark Course Complete', () {
      // All 5 days have passed; 2 taken, 3 missed
      final records = [
        LocalDoseRecordEntity(
          id: 'd1',
          prescriptionItemId: 'rx_vit_e',
          medicationName: 'Vitamin E',
          dose: '400 IU',
          scheduledTime: day1,
          status: DoseStatus.taken,
        ),
        LocalDoseRecordEntity(
          id: 'd2',
          prescriptionItemId: 'rx_vit_e',
          medicationName: 'Vitamin E',
          dose: '400 IU',
          scheduledTime: day2,
          status: DoseStatus.taken,
        ),
        LocalDoseRecordEntity(
          id: 'd3',
          prescriptionItemId: 'rx_vit_e',
          medicationName: 'Vitamin E',
          dose: '400 IU',
          scheduledTime: day3,
          status: DoseStatus.missed,
        ),
        LocalDoseRecordEntity(
          id: 'd4',
          prescriptionItemId: 'rx_vit_e',
          medicationName: 'Vitamin E',
          dose: '400 IU',
          scheduledTime: day4,
          status: DoseStatus.missed,
        ),
        LocalDoseRecordEntity(
          id: 'd5',
          prescriptionItemId: 'rx_vit_e',
          medicationName: 'Vitamin E',
          dose: '400 IU',
          scheduledTime: day5,
          status: DoseStatus.missed,
        ),
      ];

      final progress = MedicationCourseProgress.calculate(
        prescription: tRxVitaminE,
        doseRecords: records,
      );

      expect(progress.totalScheduled, 5);
      expect(progress.takenCount, 2);
      expect(progress.missedCount, 3);
      expect(progress.pendingCount, 0);
      expect(progress.remainingCount, 3);
      // Course is NOT complete just because calendar time arrived
      expect(progress.isComplete, false);
      expect(progress.isTrackingActive, true);
    });

    test('TEST 5: Stop Tracking Before Completion — Cancels Future Notifications, Preserves History, Does Not Falsely Mark Complete', () async {
      final records = [
        LocalDoseRecordModel(
          id: 'd1',
          prescriptionItemId: 'rx_vit_e',
          medicationName: 'Vitamin E',
          dose: '400 IU',
          scheduledTime: day1,
          status: DoseStatus.taken,
        ),
        LocalDoseRecordModel(
          id: 'd2',
          prescriptionItemId: 'rx_vit_e',
          medicationName: 'Vitamin E',
          dose: '400 IU',
          scheduledTime: day2,
          status: DoseStatus.taken,
        ),
        LocalDoseRecordModel(
          id: 'd3',
          prescriptionItemId: 'rx_vit_e',
          medicationName: 'Vitamin E',
          dose: '400 IU',
          scheduledTime: day3,
          status: DoseStatus.pending,
        ),
        LocalDoseRecordModel(
          id: 'd4',
          prescriptionItemId: 'rx_vit_e',
          medicationName: 'Vitamin E',
          dose: '400 IU',
          scheduledTime: day4,
          status: DoseStatus.pending,
        ),
      ];

      when(() => mockDataSource.updatePrescriptionTracking('rx_vit_e', false))
          .thenAnswer((_) async {});
      when(() => mockDataSource.getDoseRecords(prescriptionItemId: 'rx_vit_e'))
          .thenAnswer((_) async => records);

      final result = await stopTrackingUseCase(prescription: tRxVitaminE);

      expect(result.isRight(), true);
      final updatedRx = result.getOrElse((_) => tRxVitaminE);
      expect(updatedRx.isTrackingActive, false);

      // Verify pending reminders cancelled
      verify(() => mockAlarmScheduler.cancelReminder('d3'.hashCode & 0x7FFFFFFF))
          .called(1);
      verify(() => mockAlarmScheduler.cancelReminder('d4'.hashCode & 0x7FFFFFFF))
          .called(1);

      // Verify progress calculation on stopped prescription:
      final entities = records.map((m) => m.toEntity()).toList();
      final progress = MedicationCourseProgress.calculate(
        prescription: updatedRx,
        doseRecords: entities,
      );

      expect(progress.isTrackingActive, false);
      expect(progress.isComplete, false); // NOT falsely complete!
      expect(progress.takenCount, 2);
    });

    test('TEST 6: Notification Continuation — Processing a missed dose cancels only that dose reminder and does not cancel future dose reminders', () async {
      final overdueDose = LocalDoseRecordModel(
        id: 'd1',
        prescriptionItemId: 'rx_vit_e',
        medicationName: 'Vitamin E',
        dose: '400 IU',
        scheduledTime: DateTime.now().subtract(const Duration(hours: 3)),
        status: DoseStatus.pending,
      );

      final futureDose = LocalDoseRecordModel(
        id: 'd2',
        prescriptionItemId: 'rx_vit_e',
        medicationName: 'Vitamin E',
        dose: '400 IU',
        scheduledTime: DateTime.now().add(const Duration(hours: 5)),
        status: DoseStatus.pending,
      );

      when(() => mockDataSource.getDoseRecords())
          .thenAnswer((_) async => [overdueDose, futureDose]);
      when(() => mockDataSource.saveDoseRecord(any()))
          .thenAnswer((_) async {});

      final result = await processMissedDosesUseCase();

      expect(result.isRight(), true);
      final missedList = result.getOrElse((_) => []);
      expect(missedList.length, 1);

      // Only overdue dose reminder is cancelled
      verify(() => mockAlarmScheduler.cancelReminder(overdueDose.id.hashCode & 0x7FFFFFFF))
          .called(1);
      // Future dose reminder is NEVER cancelled
      verifyNever(() => mockAlarmScheduler.cancelReminder(futureDose.id.hashCode & 0x7FFFFFFF));
    });

    test('TEST 7: Course Completion Stops All Future Reminders', () async {
      // When all doses are taken, no pending doses exist to trigger alarms
      when(() => mockDataSource.getDoseRecords(prescriptionItemId: 'rx_vit_e'))
          .thenAnswer((_) async => [
                LocalDoseRecordModel(
                  id: 'd1',
                  prescriptionItemId: 'rx_vit_e',
                  medicationName: 'Vitamin E',
                  dose: '400 IU',
                  scheduledTime: day1,
                  status: DoseStatus.taken,
                ),
                LocalDoseRecordModel(
                  id: 'd2',
                  prescriptionItemId: 'rx_vit_e',
                  medicationName: 'Vitamin E',
                  dose: '400 IU',
                  scheduledTime: day2,
                  status: DoseStatus.taken,
                ),
              ]);

      final cancelResult = await cancelRemindersUseCase(
        prescriptionItemId: 'rx_vit_e',
      );

      expect(cancelResult.isRight(), true);
      final cancelled = cancelResult.getOrElse((_) => -1);
      // 0 pending reminders because all are taken
      expect(cancelled, 0);
      verifyNever(() => mockAlarmScheduler.cancelReminder(any()));
    });
  });
}
