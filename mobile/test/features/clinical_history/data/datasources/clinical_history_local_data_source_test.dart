import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';

import 'package:afyamind_mobile/core/errors/exceptions.dart';
import 'package:afyamind_mobile/features/clinical_history/data/datasources/clinical_history_local_data_source.dart';
import 'package:afyamind_mobile/features/clinical_history/data/models/appointment_model.dart';
import 'package:afyamind_mobile/features/clinical_history/data/models/clinical_evaluation_model.dart';
import 'package:afyamind_mobile/features/clinical_history/data/models/encounter_detail_model.dart';
import 'package:afyamind_mobile/features/clinical_history/data/models/encounter_model.dart';
import 'package:afyamind_mobile/features/clinical_history/data/models/medical_history_summary_model.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/entities/appointment_entity.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/entities/encounter_entity.dart';

class MockBox extends Mock implements Box {}

void main() {
  late MockBox mockBox;
  late ClinicalHistoryLocalDataSourceImpl dataSource;

  setUp(() {
    mockBox = MockBox();
    dataSource = ClinicalHistoryLocalDataSourceImpl.withBox(mockBox);
  });

  group('ClinicalHistoryLocalDataSourceImpl', () {
    const patientId = 'patient-123';
    const encounterId = 'enc-123';

    final encounterModel = EncounterModel(
      id: encounterId,
      patientId: patientId,
      clinicId: 'clinic-1',
      openedByDoctorId: 'doctor-1',
      status: EncounterStatus.open,
      startedAt: DateTime.parse('2026-08-27T10:00:00Z'),
    );

    final summaryModel = MedicalHistorySummaryModel(
      encounterId: encounterId,
      date: DateTime.parse('2026-08-27T10:00:00Z'),
      chiefComplaint: 'Fever',
      prescription: [],
      vitals: const MedicalHistoryVitalsModel(systolicBp: 120),
    );

    final evaluationModel = ClinicalEvaluationModel(
      id: 'eval-1',
      encounterId: encounterId,
      chiefComplaint: 'Fever and cough',
      historyOfPresentIllness: 'Started 2 days ago',
      createdAt: DateTime.parse('2026-08-27T10:00:00Z'),
    );

    final detailModel = EncounterDetailModel(
      encounter: encounterModel,
      vitals: [],
      labs: [],
      diagnoses: [],
      prescriptions: [],
    );

    final appointmentModel = AppointmentModel(
      id: 'app-1',
      clinicId: 'clinic-1',
      doctorId: 'doctor-1',
      patientId: patientId,
      scheduledAt: DateTime.parse('2026-08-30T10:00:00Z'),
      status: AppointmentStatus.scheduled,
      createdAt: DateTime.parse('2026-08-27T10:00:00Z'),
      updatedAt: DateTime.parse('2026-08-27T10:00:00Z'),
    );

    group('cacheEncounters & getCachedEncounters', () {
      test('stores encounters json list in box', () async {
        when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

        await dataSource.cacheEncounters(patientId, [encounterModel]);

        verify(() =>
                mockBox.put('encounters_$patientId', [encounterModel.toJson()]))
            .called(1);
      });

      test('retrieves and deserializes cached encounters', () async {
        when(() => mockBox.get('encounters_$patientId'))
            .thenReturn([encounterModel.toJson()]);

        final result = await dataSource.getCachedEncounters(patientId);

        expect(result.length, 1);
        expect(result.first.id, encounterId);
      });

      test('throws CacheException when null', () async {
        when(() => mockBox.get('encounters_$patientId')).thenReturn(null);

        expect(
          () => dataSource.getCachedEncounters(patientId),
          throwsA(isA<CacheException>()),
        );
      });
    });

    group('cacheMedicalHistory & getCachedMedicalHistory', () {
      test('stores medical history json in box', () async {
        when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

        await dataSource.cacheMedicalHistory(summaryModel);

        verify(() => mockBox.put('summary_$encounterId', summaryModel.toJson()))
            .called(1);
      });

      test('retrieves cached medical history', () async {
        when(() => mockBox.get('summary_$encounterId'))
            .thenReturn(summaryModel.toJson());

        final result = await dataSource.getCachedMedicalHistory(encounterId);

        expect(result.encounterId, encounterId);
        expect(result.chiefComplaint, 'Fever');
      });

      test('throws CacheException on missing summary', () async {
        when(() => mockBox.get('summary_$encounterId')).thenReturn(null);

        expect(
          () => dataSource.getCachedMedicalHistory(encounterId),
          throwsA(isA<CacheException>()),
        );
      });
    });

    group('cacheEncounterDetail & getCachedEncounterDetail', () {
      test('stores detail and evaluation wrapper json in box', () async {
        when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

        await dataSource.cacheEncounterDetail(
          encounterId,
          detailModel,
          evaluationModel,
        );

        final expectedJson = CachedEncounterDetail(
          detail: detailModel,
          clinicalEvaluation: evaluationModel,
        ).toJson();

        verify(() => mockBox.put('detail_$encounterId', expectedJson))
            .called(1);
      });

      test('retrieves cached encounter detail and evaluation', () async {
        final cached = CachedEncounterDetail(
          detail: detailModel,
          clinicalEvaluation: evaluationModel,
        );

        when(() => mockBox.get('detail_$encounterId'))
            .thenReturn(cached.toJson());

        final result = await dataSource.getCachedEncounterDetail(encounterId);

        expect(result.detail.encounter.id, encounterId);
        expect(result.clinicalEvaluation?.id, 'eval-1');
      });

      test('throws CacheException on missing detail', () async {
        when(() => mockBox.get('detail_$encounterId')).thenReturn(null);

        expect(
          () => dataSource.getCachedEncounterDetail(encounterId),
          throwsA(isA<CacheException>()),
        );
      });
    });

    group('cacheAppointments & getCachedAppointments', () {
      test('stores appointments json list in box', () async {
        when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

        await dataSource.cacheAppointments(patientId, [appointmentModel]);

        verify(() => mockBox.put(
              'appointments_$patientId',
              [appointmentModel.toJson()],
            )).called(1);
      });

      test('retrieves cached appointments', () async {
        when(() => mockBox.get('appointments_$patientId'))
            .thenReturn([appointmentModel.toJson()]);

        final result = await dataSource.getCachedAppointments(patientId);

        expect(result.length, 1);
        expect(result.first.id, 'app-1');
      });

      test('throws CacheException on missing appointments', () async {
        when(() => mockBox.get('appointments_$patientId')).thenReturn(null);

        expect(
          () => dataSource.getCachedAppointments(patientId),
          throwsA(isA<CacheException>()),
        );
      });
    });
  });
}
