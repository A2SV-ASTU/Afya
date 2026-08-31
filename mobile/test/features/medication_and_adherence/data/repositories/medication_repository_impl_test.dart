import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:afyamind_mobile/core/errors/exceptions.dart';
import 'package:afyamind_mobile/core/errors/failures.dart';
import 'package:afyamind_mobile/features/clinical_history/data/models/encounter_detail_model.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/entities/encounter_detail_entity.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/data/datasources/medication_local_data_source.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/data/datasources/medication_remote_data_source.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/data/models/local_dose_record_model.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/data/repositories/medication_repository_impl.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/entities/local_dose_record_entity.dart';

class MockMedicationRemoteDataSource extends Mock
    implements MedicationRemoteDataSource {}

class MockMedicationLocalDataSource extends Mock
    implements MedicationLocalDataSource {}

void main() {
  late MockMedicationRemoteDataSource mockRemoteDataSource;
  late MockMedicationLocalDataSource mockLocalDataSource;
  late MedicationRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(EncounterPrescriptionStatus.active);
    registerFallbackValue(
      LocalDoseRecordModel(
        id: 'fallback-id',
        prescriptionItemId: 'fallback-rx',
        medicationName: 'fallback-med',
        dose: 'fallback-dose',
        scheduledTime: DateTime(2026),
      ),
    );
  });

  setUp(() {
    mockRemoteDataSource = MockMedicationRemoteDataSource();
    mockLocalDataSource = MockMedicationLocalDataSource();
    repository = MedicationRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  const encounterId = 'enc-123';
  const prescriptionItemId = 'rx-item-123';

  final samplePrescriptionModel = EncounterPrescriptionItemModel(
    id: prescriptionItemId,
    medicationName: 'Amoxicillin',
    dose: '500mg',
    route: 'oral',
    frequency: 'TID',
    duration: '7 days',
    status: EncounterPrescriptionStatus.active,
    instructions: 'Take with food',
    startedAt: DateTime.parse('2026-08-28T08:00:00Z'),
  );

  final sampleDoseEntity = LocalDoseRecordEntity(
    id: 'dose-123',
    prescriptionItemId: prescriptionItemId,
    medicationName: 'Amoxicillin',
    dose: '500mg',
    scheduledTime: DateTime.parse('2026-08-28T08:00:00Z'),
    status: DoseStatus.taken,
    recordedAt: DateTime.parse('2026-08-28T08:05:00Z'),
  );

  group('getPrescriptions', () {
    test('remote success: caches and returns list of prescription entities',
        () async {
      when(() => mockRemoteDataSource.getPrescriptionsByEncounter(
            encounterId: encounterId,
          )).thenAnswer((_) async => [samplePrescriptionModel]);

      when(() => mockLocalDataSource.cachePrescriptions(any()))
          .thenAnswer((_) async {});

      final result = await repository.getPrescriptions(
        encounterId: encounterId,
      );

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('should be right'),
        (entities) {
          expect(entities.length, 1);
          expect(entities.first.id, prescriptionItemId);
          expect(entities.first.medicationName, 'Amoxicillin');
        },
      );

      verify(() =>
              mockLocalDataSource.cachePrescriptions([samplePrescriptionModel]))
          .called(1);
    });

    test('remote failure: falls back to local cache when available', () async {
      when(() => mockRemoteDataSource.getPrescriptionsByEncounter(
            encounterId: encounterId,
          )).thenThrow(const ServerException('Server offline', code: '503'));

      when(() => mockLocalDataSource.getCachedPrescriptions())
          .thenAnswer((_) async => [samplePrescriptionModel]);

      final result = await repository.getPrescriptions(
        encounterId: encounterId,
      );

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('should be right'),
        (entities) {
          expect(entities.first.id, prescriptionItemId);
        },
      );
    });

    test('remote failure + cache failure: returns ServerFailure', () async {
      when(() => mockRemoteDataSource.getPrescriptionsByEncounter(
            encounterId: encounterId,
          )).thenThrow(const ServerException('Network down', code: '500'));

      when(() => mockLocalDataSource.getCachedPrescriptions())
          .thenThrow(const CacheException('No cached data'));

      final result = await repository.getPrescriptions(
        encounterId: encounterId,
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Network down');
        },
        (_) => fail('should be left'),
      );
    });
  });

  group('getCachedPrescriptions', () {
    test('returns cached entities when cache is present', () async {
      when(() => mockLocalDataSource.getCachedPrescriptions())
          .thenAnswer((_) async => [samplePrescriptionModel]);

      final result = await repository.getCachedPrescriptions();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('should be right'),
        (entities) => expect(entities.first.id, prescriptionItemId),
      );
    });

    test('returns CacheFailure when cache read throws CacheException',
        () async {
      when(() => mockLocalDataSource.getCachedPrescriptions())
          .thenThrow(const CacheException('Cache empty'));

      final result = await repository.getCachedPrescriptions();

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('should be left'),
      );
    });
  });

  group('completePrescriptionItem', () {
    test(
        'remote PATCH success: updates local status and returns updated entity',
        () async {
      final completedModel = EncounterPrescriptionItemModel(
        id: prescriptionItemId,
        medicationName: 'Amoxicillin',
        dose: '500mg',
        route: 'oral',
        frequency: 'TID',
        duration: '7 days',
        status: EncounterPrescriptionStatus.completed,
        instructions: 'Take with food',
        startedAt: DateTime.parse('2026-08-28T08:00:00Z'),
      );

      when(() => mockRemoteDataSource.completePrescription(
            prescriptionItemId: prescriptionItemId,
          )).thenAnswer((_) async => completedModel);

      when(() => mockLocalDataSource.updatePrescriptionStatus(
            prescriptionItemId,
            EncounterPrescriptionStatus.completed,
          )).thenAnswer((_) async {});

      final result = await repository.completePrescriptionItem(
        prescriptionItemId: prescriptionItemId,
      );

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('should be right'),
        (entity) {
          expect(entity.id, prescriptionItemId);
          expect(entity.status, EncounterPrescriptionStatus.completed);
        },
      );

      verify(() => mockLocalDataSource.updatePrescriptionStatus(
            prescriptionItemId,
            EncounterPrescriptionStatus.completed,
          )).called(1);
    });

    test(
        'remote PATCH failure: returns ServerFailure and does not falsely update local cache',
        () async {
      when(() => mockRemoteDataSource.completePrescription(
            prescriptionItemId: prescriptionItemId,
          )).thenThrow(const ServerException('Unauthorized', code: '401'));

      final result = await repository.completePrescriptionItem(
        prescriptionItemId: prescriptionItemId,
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Unauthorized');
        },
        (_) => fail('should be left'),
      );

      verifyNever(
          () => mockLocalDataSource.updatePrescriptionStatus(any(), any()));
    });
  });

  group('recordDoseAdherence', () {
    test('local save success returns Right(null)', () async {
      when(() => mockLocalDataSource.saveDoseRecord(any()))
          .thenAnswer((_) async {});

      final result = await repository.recordDoseAdherence(
        doseRecord: sampleDoseEntity,
      );

      expect(result.isRight(), true);
      verify(() => mockLocalDataSource.saveDoseRecord(any())).called(1);
    });

    test('local save failure returns CacheFailure', () async {
      when(() => mockLocalDataSource.saveDoseRecord(any()))
          .thenThrow(const CacheException('Disk full'));

      final result = await repository.recordDoseAdherence(
        doseRecord: sampleDoseEntity,
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('should be left'),
      );
    });
  });

  group('getLocalDoseRecords & getLocalDoseRecordById', () {
    test('returns mapped entities from localDataSource', () async {
      final model = LocalDoseRecordModel.fromEntity(sampleDoseEntity);

      when(() => mockLocalDataSource.getDoseRecords(
            forDate: any(named: 'forDate'),
            prescriptionItemId: any(named: 'prescriptionItemId'),
          )).thenAnswer((_) async => [model]);

      final result = await repository.getLocalDoseRecords(
        prescriptionItemId: prescriptionItemId,
      );

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('should be right'),
        (entities) {
          expect(entities.length, 1);
          expect(entities.first.id, 'dose-123');
          expect(entities.first.status, DoseStatus.taken);
        },
      );
    });

    test('getLocalDoseRecordById returns mapped entity when present', () async {
      final model = LocalDoseRecordModel.fromEntity(sampleDoseEntity);

      when(() => mockLocalDataSource.getDoseRecordById('dose-123'))
          .thenAnswer((_) async => model);

      final result = await repository.getLocalDoseRecordById(id: 'dose-123');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('should be right'),
        (entity) {
          expect(entity, isNotNull);
          expect(entity!.id, 'dose-123');
        },
      );
    });
  });
}
