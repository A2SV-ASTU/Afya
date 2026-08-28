import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:afyamind_mobile/core/errors/exceptions.dart';
import 'package:afyamind_mobile/core/errors/failures.dart';
import 'package:afyamind_mobile/features/clinical_history/data/datasources/clinical_history_local_data_source.dart';
import 'package:afyamind_mobile/features/clinical_history/data/datasources/clinical_history_remote_data_source.dart';
import 'package:afyamind_mobile/features/clinical_history/data/models/appointment_model.dart';
import 'package:afyamind_mobile/features/clinical_history/data/models/clinical_evaluation_model.dart';
import 'package:afyamind_mobile/features/clinical_history/data/models/encounter_detail_model.dart';
import 'package:afyamind_mobile/features/clinical_history/data/models/encounter_model.dart';
import 'package:afyamind_mobile/features/clinical_history/data/models/medical_history_summary_model.dart';
import 'package:afyamind_mobile/features/clinical_history/data/repositories/clinical_history_repository_impl.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/entities/appointment_entity.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/entities/encounter_entity.dart';

class MockRemoteDataSource extends Mock
    implements ClinicalHistoryRemoteDataSource {}

class MockLocalDataSource extends Mock
    implements ClinicalHistoryLocalDataSource {}

void main() {
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late ClinicalHistoryRepositoryImpl repository;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    repository = ClinicalHistoryRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  const patientId = 'patient-123';
  const encounterId = 'enc-123';

  final olderEncounter = EncounterModel(
    id: 'enc-1',
    patientId: patientId,
    clinicId: 'clinic-1',
    openedByDoctorId: 'doctor-1',
    status: EncounterStatus.closed,
    startedAt: DateTime.parse('2026-08-20T10:00:00Z'),
  );

  final newerEncounter = EncounterModel(
    id: 'enc-2',
    patientId: patientId,
    clinicId: 'clinic-1',
    openedByDoctorId: 'doctor-1',
    status: EncounterStatus.open,
    startedAt: DateTime.parse('2026-08-27T10:00:00Z'),
  );

  final summaryModel = MedicalHistorySummaryModel(
    encounterId: encounterId,
    date: DateTime.parse('2026-08-27T10:00:00Z'),
    chiefComplaint: 'Headache',
    prescription: [],
    vitals: const MedicalHistoryVitalsModel(),
  );

  final evaluationModel = ClinicalEvaluationModel(
    id: 'eval-1',
    encounterId: encounterId,
    chiefComplaint: 'Headache',
    historyOfPresentIllness: 'Duration 3 days',
    createdAt: DateTime.parse('2026-08-27T10:00:00Z'),
  );

  final detailModel = EncounterDetailModel(
    encounter: newerEncounter,
    vitals: [],
    labs: [],
    diagnoses: [],
    prescriptions: [],
  );

  final app1 = AppointmentModel(
    id: 'app-1',
    clinicId: 'clinic-1',
    doctorId: 'doctor-1',
    patientId: patientId,
    scheduledAt: DateTime.parse('2026-08-30T10:00:00Z'),
    status: AppointmentStatus.scheduled,
    createdAt: DateTime.parse('2026-08-27T10:00:00Z'),
    updatedAt: DateTime.parse('2026-08-27T10:00:00Z'),
  );

  group('getEncountersTimeline', () {
    test('remote success: caches and returns reverse chronological list',
        () async {
      when(() => mockRemoteDataSource.getEncountersTimeline(
            patientId: patientId,
            page: 1,
            limit: 20,
          )).thenAnswer((_) async => [olderEncounter, newerEncounter]);

      when(() => mockLocalDataSource.cacheEncounters(patientId, any()))
          .thenAnswer((_) async {});

      final result =
          await repository.getEncountersTimeline(patientId: patientId);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('should be right'),
        (entities) {
          expect(entities.length, 2);
          expect(entities.first.id, 'enc-2'); // newer first
          expect(entities.last.id, 'enc-1');
        },
      );

      verify(() => mockLocalDataSource.cacheEncounters(
          patientId, [olderEncounter, newerEncounter])).called(1);
    });

    test('remote failure: falls back to local cache when available', () async {
      when(() => mockRemoteDataSource.getEncountersTimeline(
            patientId: patientId,
            page: 1,
            limit: 20,
          )).thenThrow(const ServerException('Server error', code: '500'));

      when(() => mockLocalDataSource.getCachedEncounters(patientId))
          .thenAnswer((_) async => [olderEncounter, newerEncounter]);

      final result =
          await repository.getEncountersTimeline(patientId: patientId);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('should be right'),
        (entities) {
          expect(entities.first.id, 'enc-2');
        },
      );
    });

    test('remote failure + cache failure: returns ServerFailure', () async {
      when(() => mockRemoteDataSource.getEncountersTimeline(
            patientId: patientId,
            page: 1,
            limit: 20,
          )).thenThrow(const ServerException('Server error', code: '500'));

      when(() => mockLocalDataSource.getCachedEncounters(patientId))
          .thenThrow(const CacheException('No cache'));

      final result =
          await repository.getEncountersTimeline(patientId: patientId);

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Server error');
        },
        (_) => fail('should be left'),
      );
    });
  });

  group('getCondensedMedicalHistory', () {
    test('remote success: caches and returns summary entity', () async {
      when(() => mockRemoteDataSource.getCondensedMedicalHistory(
            encounterId: encounterId,
          )).thenAnswer((_) async => summaryModel);

      when(() => mockLocalDataSource.cacheMedicalHistory(summaryModel))
          .thenAnswer((_) async {});

      final result = await repository.getCondensedMedicalHistory(
        encounterId: encounterId,
      );

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('should be right'),
        (entity) => expect(entity.encounterId, encounterId),
      );
    });

    test('remote failure: falls back to cached summary', () async {
      when(() => mockRemoteDataSource.getCondensedMedicalHistory(
            encounterId: encounterId,
          )).thenThrow(const ServerException('Network down'));

      when(() => mockLocalDataSource.getCachedMedicalHistory(encounterId))
          .thenAnswer((_) async => summaryModel);

      final result = await repository.getCondensedMedicalHistory(
        encounterId: encounterId,
      );

      expect(result.isRight(), true);
    });
  });

  group('getEncounterDetail', () {
    test('remote success: combines aggregate detail + clinical evaluation',
        () async {
      when(() => mockRemoteDataSource.getEncounterDetail(
            encounterId: encounterId,
          )).thenAnswer((_) async => detailModel);

      when(() => mockRemoteDataSource.getClinicalEvaluation(
            encounterId: encounterId,
          )).thenAnswer((_) async => evaluationModel);

      when(() => mockLocalDataSource.cacheEncounterDetail(
            encounterId,
            detailModel,
            evaluationModel,
          )).thenAnswer((_) async {});

      final result = await repository.getEncounterDetail(
        encounterId: encounterId,
      );

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('should be right'),
        (entity) {
          expect(entity.encounter.id, 'enc-2');
          expect(entity.clinicalEvaluation?.id, 'eval-1');
        },
      );
    });

    test('remote failure: falls back to cached detail wrapper', () async {
      when(() => mockRemoteDataSource.getEncounterDetail(
            encounterId: encounterId,
          )).thenThrow(const ServerException('Server error'));

      when(() => mockLocalDataSource.getCachedEncounterDetail(encounterId))
          .thenAnswer((_) async => CachedEncounterDetail(
                detail: detailModel,
                clinicalEvaluation: evaluationModel,
              ));

      final result = await repository.getEncounterDetail(
        encounterId: encounterId,
      );

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('should be right'),
        (entity) {
          expect(entity.clinicalEvaluation?.id, 'eval-1');
        },
      );
    });
  });

  group('getAppointments', () {
    test('remote success: caches and returns sorted appointments', () async {
      when(() => mockRemoteDataSource.getAppointments(
            patientId: patientId,
            status: null,
          )).thenAnswer((_) async => [app1]);

      when(() => mockLocalDataSource.cacheAppointments(patientId, [app1]))
          .thenAnswer((_) async {});

      final result = await repository.getAppointments(patientId: patientId);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('should be right'),
        (entities) => expect(entities.first.id, 'app-1'),
      );
    });
  });
}
