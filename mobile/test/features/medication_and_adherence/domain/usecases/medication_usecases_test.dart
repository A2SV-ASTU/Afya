import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:afyamind_mobile/core/errors/failures.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/entities/encounter_detail_entity.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/entities/local_dose_record_entity.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/repositories/medication_repository.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/usecases/cancel_prescription_reminders_usecase.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/usecases/complete_prescription_usecase.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/usecases/generate_dose_schedule_usecase.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/usecases/get_local_dose_records_usecase.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/usecases/get_prescriptions_usecase.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/usecases/record_dose_adherence_usecase.dart';

class MockMedicationRepository extends Mock implements MedicationRepository {}

class MockGenerateDoseScheduleUseCase extends Mock
    implements GenerateDoseScheduleUseCase {}

class MockCancelPrescriptionRemindersUseCase extends Mock
    implements CancelPrescriptionRemindersUseCase {}

void main() {
  late MockMedicationRepository mockRepository;
  late MockGenerateDoseScheduleUseCase mockGenerateScheduleUseCase;
  late MockCancelPrescriptionRemindersUseCase mockCancelRemindersUseCase;

  setUpAll(() {
    registerFallbackValue(
      LocalDoseRecordEntity(
        id: 'fb-id',
        prescriptionItemId: 'fb-rx',
        medicationName: 'fb-med',
        dose: 'fb-dose',
        scheduledTime: DateTime(2026),
      ),
    );
    registerFallbackValue(
      EncounterPrescriptionItemEntity(
        id: 'fb-rx',
        medicationName: 'Amox',
        dose: '500mg',
        route: 'oral',
        frequency: 'OD',
        duration: '3 days',
        status: EncounterPrescriptionStatus.active,
        instructions: '',
        startedAt: DateTime(2026),
      ),
    );
  });

  setUp(() {
    mockRepository = MockMedicationRepository();
    mockGenerateScheduleUseCase = MockGenerateDoseScheduleUseCase();
    mockCancelRemindersUseCase = MockCancelPrescriptionRemindersUseCase();
  });

  final samplePrescriptionEntity = EncounterPrescriptionItemEntity(
    id: 'rx-1',
    medicationName: 'Amoxicillin',
    dose: '500mg',
    route: 'oral',
    frequency: 'TID',
    duration: '7 days',
    status: EncounterPrescriptionStatus.active,
    instructions: 'Take with water',
    startedAt: DateTime.parse('2026-08-28T08:00:00Z'),
  );

  final sampleDoseRecord = LocalDoseRecordEntity(
    id: 'dose-1',
    prescriptionItemId: 'rx-1',
    medicationName: 'Amoxicillin',
    dose: '500mg',
    scheduledTime: DateTime.parse('2026-08-28T08:00:00Z'),
    status: DoseStatus.taken,
    recordedAt: DateTime.parse('2026-08-28T08:05:00Z'),
  );

  group('GetPrescriptionsUseCase', () {
    test(
        'forwards parameters to repository, generates dose schedules for active items, and returns Right list',
        () async {
      final useCase = GetPrescriptionsUseCase(
        mockRepository,
        mockGenerateScheduleUseCase,
      );

      when(() => mockRepository.getPrescriptions(
            encounterId: 'enc-1',
            forceRefresh: true,
          )).thenAnswer((_) async => Right([samplePrescriptionEntity]));

      when(() => mockGenerateScheduleUseCase(
            prescription: any(named: 'prescription'),
            now: any(named: 'now'),
          )).thenAnswer((_) async => const Right([]));

      final result = await useCase(encounterId: 'enc-1', forceRefresh: true);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('should be right'),
        (items) => expect(items.first.id, 'rx-1'),
      );
      verify(() => mockRepository.getPrescriptions(
            encounterId: 'enc-1',
            forceRefresh: true,
          )).called(1);
      verify(() => mockGenerateScheduleUseCase(
            prescription: samplePrescriptionEntity,
          )).called(1);
    });

    test('getCached calls repository.getCachedPrescriptions', () async {
      final useCase = GetPrescriptionsUseCase(
        mockRepository,
        mockGenerateScheduleUseCase,
      );

      when(() => mockRepository.getCachedPrescriptions())
          .thenAnswer((_) async => Right([samplePrescriptionEntity]));

      final result = await useCase.getCached();

      expect(result.isRight(), true);
      verify(() => mockRepository.getCachedPrescriptions()).called(1);
    });
  });

  group('CompletePrescriptionUseCase', () {
    test(
        'forwards prescriptionItemId to repository, cancels pending reminders, and returns updated entity',
        () async {
      final useCase = CompletePrescriptionUseCase(
        mockRepository,
        mockCancelRemindersUseCase,
      );

      final completedEntity = EncounterPrescriptionItemEntity(
        id: 'rx-1',
        medicationName: 'Amoxicillin',
        dose: '500mg',
        route: 'oral',
        frequency: 'TID',
        duration: '7 days',
        status: EncounterPrescriptionStatus.completed,
        instructions: 'Take with water',
        startedAt: DateTime.parse('2026-08-28T08:00:00Z'),
      );

      when(() => mockRepository.completePrescriptionItem(
            prescriptionItemId: 'rx-1',
          )).thenAnswer((_) async => Right(completedEntity));

      when(() => mockCancelRemindersUseCase(
            prescriptionItemId: 'rx-1',
          )).thenAnswer((_) async => const Right(2));

      final result = await useCase(prescriptionItemId: 'rx-1');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('should be right'),
        (item) => expect(item.status, EncounterPrescriptionStatus.completed),
      );
      verify(() => mockRepository.completePrescriptionItem(
            prescriptionItemId: 'rx-1',
          )).called(1);
      verify(() => mockCancelRemindersUseCase(
            prescriptionItemId: 'rx-1',
          )).called(1);
    });

    test(
        'returns ServerFailure when completion fails and does not cancel reminders',
        () async {
      final useCase = CompletePrescriptionUseCase(
        mockRepository,
        mockCancelRemindersUseCase,
      );

      when(() => mockRepository.completePrescriptionItem(
            prescriptionItemId: 'rx-1',
          )).thenAnswer((_) async => const Left(ServerFailure('Failed')));

      final result = await useCase(prescriptionItemId: 'rx-1');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, 'Failed'),
        (_) => fail('should be left'),
      );
      verifyNever(() => mockCancelRemindersUseCase(
            prescriptionItemId: any(named: 'prescriptionItemId'),
          ));
    });
  });

  group('RecordDoseAdherenceUseCase', () {
    test('forwards dose record to repository', () async {
      final useCase = RecordDoseAdherenceUseCase(mockRepository);

      when(() => mockRepository.recordDoseAdherence(
            doseRecord: any(named: 'doseRecord'),
          )).thenAnswer((_) async => const Right(null));

      final result = await useCase(doseRecord: sampleDoseRecord);

      expect(result.isRight(), true);
      verify(() => mockRepository.recordDoseAdherence(
            doseRecord: sampleDoseRecord,
          )).called(1);
    });
  });

  group('GetLocalDoseRecordsUseCase', () {
    test('forwards filters to repository and returns list of dose records',
        () async {
      final useCase = GetLocalDoseRecordsUseCase(mockRepository);
      final date = DateTime(2026, 8, 28);

      when(() => mockRepository.getLocalDoseRecords(
            forDate: date,
            prescriptionItemId: 'rx-1',
          )).thenAnswer((_) async => Right([sampleDoseRecord]));

      final result = await useCase(forDate: date, prescriptionItemId: 'rx-1');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('should be right'),
        (items) => expect(items.first.id, 'dose-1'),
      );
      verify(() => mockRepository.getLocalDoseRecords(
            forDate: date,
            prescriptionItemId: 'rx-1',
          )).called(1);
    });

    test('getById forwards id to repository', () async {
      final useCase = GetLocalDoseRecordsUseCase(mockRepository);

      when(() => mockRepository.getLocalDoseRecordById(id: 'dose-1'))
          .thenAnswer((_) async => Right(sampleDoseRecord));

      final result = await useCase.getById(id: 'dose-1');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('should be right'),
        (item) => expect(item?.id, 'dose-1'),
      );
      verify(() => mockRepository.getLocalDoseRecordById(id: 'dose-1'))
          .called(1);
    });
  });
}
