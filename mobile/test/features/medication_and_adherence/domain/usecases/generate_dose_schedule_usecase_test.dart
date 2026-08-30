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

class MockMedicationLocalDataSource extends Mock
    implements MedicationLocalDataSource {}

class MockLocalAlarmScheduler extends Mock implements LocalAlarmScheduler {}

void main() {
  late MockMedicationLocalDataSource mockLocalDataSource;
  late MockLocalAlarmScheduler mockAlarmScheduler;
  late GenerateDoseScheduleUseCase useCase;

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
    useCase = GenerateDoseScheduleUseCase.withGenerator(
      mockLocalDataSource,
      mockAlarmScheduler,
      generator: const DoseScheduleGenerator(parser: PosologyParser()),
    );
  });

  final testStartedAt = DateTime(2026, 8, 28, 0, 0);

  EncounterPrescriptionItemEntity createPrescription({
    String id = 'rx_item_1',
    String medicationName = 'Amoxicillin',
    String dose = '500mg',
    String route = 'oral',
    String frequency = 'Once daily (OD)',
    String duration = '3 days',
    EncounterPrescriptionStatus status = EncounterPrescriptionStatus.active,
    DateTime? startedAt,
  }) {
    return EncounterPrescriptionItemEntity(
      id: id,
      medicationName: medicationName,
      dose: dose,
      route: route,
      frequency: frequency,
      duration: duration,
      status: status,
      instructions: 'Take with food',
      startedAt: startedAt ?? testStartedAt,
    );
  }

  group('GenerateDoseScheduleUseCase', () {
    test(
        'active prescription generates, persists doses, and schedules future alarms',
        () async {
      final rx = createPrescription(
        frequency: 'Once daily (OD)',
        duration: '3 days',
      );
      final fixedNow = DateTime(2026, 8, 28, 6, 0);

      when(() => mockLocalDataSource.getDoseRecordById(any()))
          .thenAnswer((_) async => null);
      when(() => mockLocalDataSource.saveDoseRecord(any()))
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

      final result = await useCase(prescription: rx, now: fixedNow);

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Should succeed'), (doses) {
        expect(doses.length, 3);
        expect(doses[0].status, DoseStatus.pending);
      });

      verify(() => mockLocalDataSource.saveDoseRecord(any())).called(3);
      verify(() => mockAlarmScheduler.scheduleMedicationReminder(
            reminderId: any(named: 'reminderId'),
            medicationName: 'Amoxicillin',
            dosage: '500mg',
            scheduledTime: any(named: 'scheduledTime'),
            doseId: any(named: 'doseId'),
            prescriptionItemId: 'rx_item_1',
            includeSnooze: true,
          )).called(3);
    });

    test('inactive prescription (completed / deactivated) produces 0 doses',
        () async {
      final rxCompleted = createPrescription(
        status: EncounterPrescriptionStatus.completed,
      );

      final result = await useCase(prescription: rxCompleted);

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Should succeed'), (doses) {
        expect(doses, isEmpty);
      });

      verifyNever(() => mockLocalDataSource.saveDoseRecord(any()));
      verifyNever(() => mockAlarmScheduler.scheduleMedicationReminder(
            reminderId: any(named: 'reminderId'),
            medicationName: any(named: 'medicationName'),
            dosage: any(named: 'dosage'),
            scheduledTime: any(named: 'scheduledTime'),
          ));
    });

    test('idempotency: already existing doses are not re-saved or re-scheduled',
        () async {
      final rx = createPrescription(
        frequency: 'Once daily (OD)',
        duration: '2 days',
      );
      final existingModel = LocalDoseRecordModel(
        id: 'rx_item_1_${DateTime(2026, 8, 28, 8, 0).millisecondsSinceEpoch}',
        prescriptionItemId: 'rx_item_1',
        medicationName: 'Amoxicillin',
        dose: '500mg',
        scheduledTime: DateTime(2026, 8, 28, 8, 0),
        status: DoseStatus.taken,
      );

      when(() => mockLocalDataSource.getDoseRecordById(existingModel.id))
          .thenAnswer((_) async => existingModel);
      when(() => mockLocalDataSource.getDoseRecordById(
            'rx_item_1_${DateTime(2026, 8, 29, 8, 0).millisecondsSinceEpoch}',
          )).thenAnswer((_) async => null);
      when(() => mockLocalDataSource.saveDoseRecord(any()))
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

      final result = await useCase(
        prescription: rx,
        now: DateTime(2026, 8, 28, 6, 0),
      );

      expect(result.isRight(), isTrue);
      // Only the 2nd dose should be saved and scheduled
      verify(() => mockLocalDataSource.saveDoseRecord(any())).called(1);
      verify(() => mockAlarmScheduler.scheduleMedicationReminder(
            reminderId: any(named: 'reminderId'),
            medicationName: any(named: 'medicationName'),
            dosage: any(named: 'dosage'),
            scheduledTime: any(named: 'scheduledTime'),
            doseId: any(named: 'doseId'),
            prescriptionItemId: any(named: 'prescriptionItemId'),
            includeSnooze: any(named: 'includeSnooze'),
          )).called(1);
    });

    test('running use case twice does not duplicate records or schedules',
        () async {
      final rx = createPrescription(
        frequency: 'Once daily (OD)',
        duration: '2 days',
      );
      final fixedNow = DateTime(2026, 8, 28, 6, 0);

      final persistedRecords = <String, LocalDoseRecordModel>{};

      when(() => mockLocalDataSource.getDoseRecordById(any()))
          .thenAnswer((invocation) async {
        final id = invocation.positionalArguments.first as String;
        return persistedRecords[id];
      });

      when(() => mockLocalDataSource.saveDoseRecord(any()))
          .thenAnswer((invocation) async {
        final model =
            invocation.positionalArguments.first as LocalDoseRecordModel;
        persistedRecords[model.id] = model;
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

      // First run
      final firstResult = await useCase(prescription: rx, now: fixedNow);
      expect(firstResult.isRight(), isTrue);
      expect(persistedRecords.length, 2);
      verify(() => mockLocalDataSource.saveDoseRecord(any())).called(2);
      verify(() => mockAlarmScheduler.scheduleMedicationReminder(
            reminderId: any(named: 'reminderId'),
            medicationName: any(named: 'medicationName'),
            dosage: any(named: 'dosage'),
            scheduledTime: any(named: 'scheduledTime'),
            doseId: any(named: 'doseId'),
            prescriptionItemId: any(named: 'prescriptionItemId'),
            includeSnooze: any(named: 'includeSnooze'),
          )).called(2);

      // Second run
      final secondResult = await useCase(prescription: rx, now: fixedNow);
      expect(secondResult.isRight(), isTrue);
      // No new saves or schedules
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

    test('multiple prescriptions generate distinct non-interfering schedules',
        () async {
      final rxA = createPrescription(
        id: 'rx_A',
        medicationName: 'Amoxicillin',
        frequency: 'Once daily (OD)',
        duration: '1 day',
      );
      final rxB = createPrescription(
        id: 'rx_B',
        medicationName: 'Metformin',
        frequency: 'Twice daily (BD)',
        duration: '1 day',
      );
      final fixedNow = DateTime(2026, 8, 28, 6, 0);

      when(() => mockLocalDataSource.getDoseRecordById(any()))
          .thenAnswer((_) async => null);
      when(() => mockLocalDataSource.saveDoseRecord(any()))
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

      final resultA = await useCase(prescription: rxA, now: fixedNow);
      final resultB = await useCase(prescription: rxB, now: fixedNow);

      expect(resultA.isRight(), isTrue);
      expect(resultB.isRight(), isTrue);

      resultA.fold((_) => fail('A should succeed'), (doses) {
        expect(doses.length, 1);
        expect(doses.first.prescriptionItemId, 'rx_A');
      });

      resultB.fold((_) => fail('B should succeed'), (doses) {
        expect(doses.length, 2);
        expect(doses.first.prescriptionItemId, 'rx_B');
      });
    });

    test('past doses are persisted but not scheduled with alarm scheduler',
        () async {
      final rx = createPrescription(
        frequency: 'Once daily (OD)',
        duration: '2 days',
      );
      // now is 2026-08-28 12:00 -> day 1 (08:00) is past, day 2 (08:00) is future
      final fixedNow = DateTime(2026, 8, 28, 12, 0);

      when(() => mockLocalDataSource.getDoseRecordById(any()))
          .thenAnswer((_) async => null);
      when(() => mockLocalDataSource.saveDoseRecord(any()))
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

      final result = await useCase(prescription: rx, now: fixedNow);

      expect(result.isRight(), isTrue);
      // Both saved
      verify(() => mockLocalDataSource.saveDoseRecord(any())).called(2);
      // Only 1 scheduled (the future one)
      verify(() => mockAlarmScheduler.scheduleMedicationReminder(
            reminderId: any(named: 'reminderId'),
            medicationName: any(named: 'medicationName'),
            dosage: any(named: 'dosage'),
            scheduledTime: any(named: 'scheduledTime'),
            doseId: any(named: 'doseId'),
            prescriptionItemId: any(named: 'prescriptionItemId'),
            includeSnooze: any(named: 'includeSnooze'),
          )).called(1);
    });

    test('PRN prescription produces no scheduled doses and no alarms',
        () async {
      final rx = createPrescription(
        frequency: 'As needed (PRN)',
        duration: '7 days',
      );

      final result = await useCase(prescription: rx);

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Should succeed'), (doses) {
        expect(doses, isEmpty);
      });

      verifyNever(() => mockLocalDataSource.saveDoseRecord(any()));
      verifyNever(() => mockAlarmScheduler.scheduleMedicationReminder(
            reminderId: any(named: 'reminderId'),
            medicationName: any(named: 'medicationName'),
            dosage: any(named: 'dosage'),
            scheduledTime: any(named: 'scheduledTime'),
          ));
    });

    test('invalid frequency or duration produces 0 doses', () async {
      final rxInvalidFreq = createPrescription(
        frequency: 'unknown-frequency-xyz',
      );
      final rxInvalidDur = createPrescription(
        duration: 'invalid-dur',
      );

      final resultFreq = await useCase(prescription: rxInvalidFreq);
      final resultDur = await useCase(prescription: rxInvalidDur);

      expect(resultFreq.isRight(), isTrue);
      expect(resultDur.isRight(), isTrue);
      verifyNever(() => mockLocalDataSource.saveDoseRecord(any()));
    });
  });
}
