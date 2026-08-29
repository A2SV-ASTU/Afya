import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:afyamind_mobile/core/notifications/local_alarm_scheduler.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/data/datasources/medication_local_data_source.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/data/models/local_dose_record_model.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/entities/local_dose_record_entity.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/usecases/process_missed_doses_usecase.dart';

class MockMedicationLocalDataSource extends Mock
    implements MedicationLocalDataSource {}

class MockLocalAlarmScheduler extends Mock implements LocalAlarmScheduler {}

void main() {
  late MockMedicationLocalDataSource mockLocalDataSource;
  late MockLocalAlarmScheduler mockAlarmScheduler;
  late ProcessMissedDosesUseCase useCase;

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
  });

  setUp(() {
    mockLocalDataSource = MockMedicationLocalDataSource();
    mockAlarmScheduler = MockLocalAlarmScheduler();
    useCase =
        ProcessMissedDosesUseCase(mockLocalDataSource, mockAlarmScheduler);
  });

  final scheduledTime = DateTime(2026, 8, 28, 8, 0);

  LocalDoseRecordModel createDoseModel({
    required String id,
    DateTime? st,
    DateTime? snoozedUntil,
    DoseStatus status = DoseStatus.pending,
    int snoozeCount = 0,
  }) {
    return LocalDoseRecordModel(
      id: id,
      prescriptionItemId: 'rx_1',
      medicationName: 'Amoxicillin',
      dose: '500mg',
      scheduledTime: st ?? scheduledTime,
      snoozedUntil: snoozedUntil,
      status: status,
      snoozeCount: snoozeCount,
    );
  }

  group('ProcessMissedDosesUseCase', () {
    test('pending unsnoozed dose before threshold (T+25) remains pending',
        () async {
      final dose = createDoseModel(id: 'dose_1', status: DoseStatus.pending);
      final now = scheduledTime.add(const Duration(minutes: 25));

      when(() => mockLocalDataSource.getDoseRecords(
            prescriptionItemId: any(named: 'prescriptionItemId'),
          )).thenAnswer((_) async => [dose]);

      final result = await useCase(now: now);

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Should succeed'), (transitioned) {
        expect(transitioned, isEmpty);
      });

      verifyNever(() => mockLocalDataSource.saveDoseRecord(any()));
      verifyNever(() => mockAlarmScheduler.cancelReminder(any()));
    });

    test('pending unsnoozed dose at boundary (T+29) remains pending', () async {
      final dose = createDoseModel(id: 'dose_1', status: DoseStatus.pending);
      final now = scheduledTime.add(const Duration(minutes: 29));

      when(() => mockLocalDataSource.getDoseRecords(
            prescriptionItemId: any(named: 'prescriptionItemId'),
          )).thenAnswer((_) async => [dose]);

      final result = await useCase(now: now);

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Should succeed'), (transitioned) {
        expect(transitioned, isEmpty);
      });

      verifyNever(() => mockLocalDataSource.saveDoseRecord(any()));
      verifyNever(() => mockAlarmScheduler.cancelReminder(any()));
    });

    test('pending unsnoozed dose past boundary (T+31) becomes missed',
        () async {
      final dose = createDoseModel(id: 'dose_1', status: DoseStatus.pending);
      final now = scheduledTime.add(const Duration(minutes: 31));

      when(() => mockLocalDataSource.getDoseRecords(
            prescriptionItemId: any(named: 'prescriptionItemId'),
          )).thenAnswer((_) async => [dose]);
      when(() => mockLocalDataSource.saveDoseRecord(any()))
          .thenAnswer((_) async {});
      when(() => mockAlarmScheduler.cancelReminder(any()))
          .thenAnswer((_) async {});

      final result = await useCase(now: now);

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Should succeed'), (transitioned) {
        expect(transitioned.length, 1);
        expect(transitioned.first.status, DoseStatus.missed);
      });

      verify(() => mockLocalDataSource.saveDoseRecord(any())).called(1);
      final reminderId = 'dose_1'.hashCode & 0x7FFFFFFF;
      verify(() => mockAlarmScheduler.cancelReminder(reminderId)).called(1);
    });

    test(
        'pending unsnoozed dose after threshold (T+35) becomes missed and active reminder cancelled',
        () async {
      final dose = createDoseModel(id: 'dose_1', status: DoseStatus.pending);
      final now = scheduledTime.add(const Duration(minutes: 35));

      when(() => mockLocalDataSource.getDoseRecords(
            prescriptionItemId: any(named: 'prescriptionItemId'),
          )).thenAnswer((_) async => [dose]);
      when(() => mockLocalDataSource.saveDoseRecord(any()))
          .thenAnswer((_) async {});
      when(() => mockAlarmScheduler.cancelReminder(any()))
          .thenAnswer((_) async {});

      final result = await useCase(now: now);

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Should succeed'), (transitioned) {
        expect(transitioned.length, 1);
        expect(transitioned.first.id, 'dose_1');
        expect(transitioned.first.status, DoseStatus.missed);
        expect(transitioned.first.recordedAt, now);
      });

      final captured = verify(
        () => mockLocalDataSource.saveDoseRecord(captureAny()),
      ).captured.first as LocalDoseRecordModel;
      expect(captured.status, DoseStatus.missed);
      expect(captured.recordedAt, now);

      final reminderId = 'dose_1'.hashCode & 0x7FFFFFFF;
      verify(() => mockAlarmScheduler.cancelReminder(reminderId)).called(1);
    });

    test(
        'first-snoozed dose (snoozedUntil=T+10) at T+25 remains pending before final T+30 threshold',
        () async {
      final dose = createDoseModel(
        id: 'dose_snoozed_1',
        snoozeCount: 1,
        snoozedUntil: scheduledTime.add(const Duration(minutes: 10)),
        status: DoseStatus.pending,
      );
      final now = scheduledTime.add(const Duration(minutes: 25));

      when(() => mockLocalDataSource.getDoseRecords(
            prescriptionItemId: any(named: 'prescriptionItemId'),
          )).thenAnswer((_) async => [dose]);

      final result = await useCase(now: now);

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Should succeed'), (transitioned) {
        expect(transitioned, isEmpty);
      });

      verifyNever(() => mockLocalDataSource.saveDoseRecord(any()));
      verifyNever(() => mockAlarmScheduler.cancelReminder(any()));
    });

    test(
        'fully expired snoozed dose at T+35 transitions to missed and cancels reminder',
        () async {
      final dose = createDoseModel(
        id: 'dose_snoozed_2',
        snoozeCount: 2,
        snoozedUntil: scheduledTime.add(const Duration(minutes: 20)),
        status: DoseStatus.pending,
      );
      final now = scheduledTime.add(const Duration(minutes: 35));

      when(() => mockLocalDataSource.getDoseRecords(
            prescriptionItemId: any(named: 'prescriptionItemId'),
          )).thenAnswer((_) async => [dose]);
      when(() => mockLocalDataSource.saveDoseRecord(any()))
          .thenAnswer((_) async {});
      when(() => mockAlarmScheduler.cancelReminder(any()))
          .thenAnswer((_) async {});

      final result = await useCase(now: now);

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Should succeed'), (transitioned) {
        expect(transitioned.length, 1);
        expect(transitioned.first.status, DoseStatus.missed);
      });

      verify(() => mockLocalDataSource.saveDoseRecord(any())).called(1);
      final reminderId = 'dose_snoozed_2'.hashCode & 0x7FFFFFFF;
      verify(() => mockAlarmScheduler.cancelReminder(reminderId)).called(1);
    });

    test(
        'taken, skipped, and already missed doses remain untouched even if past threshold',
        () async {
      final takenDose =
          createDoseModel(id: 'dose_taken', status: DoseStatus.taken);
      final skippedDose =
          createDoseModel(id: 'dose_skipped', status: DoseStatus.skipped);
      final missedDose =
          createDoseModel(id: 'dose_missed', status: DoseStatus.missed);
      final now = scheduledTime.add(const Duration(hours: 2));

      when(() => mockLocalDataSource.getDoseRecords(
            prescriptionItemId: any(named: 'prescriptionItemId'),
          )).thenAnswer((_) async => [takenDose, skippedDose, missedDose]);

      final result = await useCase(now: now);

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Should succeed'), (transitioned) {
        expect(transitioned, isEmpty);
      });

      verifyNever(() => mockLocalDataSource.saveDoseRecord(any()));
      verifyNever(() => mockAlarmScheduler.cancelReminder(any()));
    });

    test('repeated execution is safe and does not re-process transitioned dose',
        () async {
      final dose = createDoseModel(id: 'dose_1', status: DoseStatus.pending);
      final now = scheduledTime.add(const Duration(minutes: 35));

      var currentDose = dose;

      when(() => mockLocalDataSource.getDoseRecords(
            prescriptionItemId: any(named: 'prescriptionItemId'),
          )).thenAnswer((_) async => [currentDose]);

      when(() => mockLocalDataSource.saveDoseRecord(any()))
          .thenAnswer((invocation) async {
        currentDose =
            invocation.positionalArguments.first as LocalDoseRecordModel;
      });

      when(() => mockAlarmScheduler.cancelReminder(any()))
          .thenAnswer((_) async {});

      // First run transitions dose to missed
      final result1 = await useCase(now: now);
      expect(result1.isRight(), isTrue);
      expect(currentDose.status, DoseStatus.missed);

      // Second run leaves it untouched
      final result2 = await useCase(now: now.add(const Duration(minutes: 5)));
      expect(result2.isRight(), isTrue);
      result2.fold((_) => fail('Should succeed'), (transitioned) {
        expect(transitioned, isEmpty);
      });

      verify(() => mockLocalDataSource.saveDoseRecord(any())).called(1);
    });
  });
}
