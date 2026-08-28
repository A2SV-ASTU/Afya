import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:afyamind_mobile/core/errors/failures.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/entities/appointment_entity.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/entities/encounter_detail_entity.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/entities/encounter_entity.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/entities/medical_history_summary_entity.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/repositories/clinical_history_repository.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/usecases/get_appointments_usecase.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/usecases/get_condensed_medical_history_usecase.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/usecases/get_encounter_detail_usecase.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/usecases/get_encounters_timeline_usecase.dart';

class MockClinicalHistoryRepository extends Mock
    implements ClinicalHistoryRepository {}

void main() {
  late MockClinicalHistoryRepository repository;
  late GetEncountersTimelineUseCase getEncountersTimelineUseCase;
  late GetCondensedMedicalHistoryUseCase getCondensedMedicalHistoryUseCase;
  late GetEncounterDetailUseCase getEncounterDetailUseCase;
  late GetAppointmentsUseCase getAppointmentsUseCase;

  setUp(() {
    repository = MockClinicalHistoryRepository();
    getEncountersTimelineUseCase = GetEncountersTimelineUseCase(repository);
    getCondensedMedicalHistoryUseCase =
        GetCondensedMedicalHistoryUseCase(repository);
    getEncounterDetailUseCase = GetEncounterDetailUseCase(repository);
    getAppointmentsUseCase = GetAppointmentsUseCase(repository);
  });

  const patientId = 'patient-123';
  const encounterId = 'enc-123';

  group('GetEncountersTimelineUseCase', () {
    test('forwards parameters to repository', () async {
      when(() => repository.getEncountersTimeline(
            patientId: patientId,
            page: 1,
            limit: 20,
          )).thenAnswer((_) async => const Right([]));

      final result = await getEncountersTimelineUseCase(
        patientId: patientId,
        page: 1,
        limit: 20,
      );

      expect(result, const Right<Failure, List<EncounterEntity>>([]));
      verify(() => repository.getEncountersTimeline(
            patientId: patientId,
            page: 1,
            limit: 20,
          )).called(1);
    });
  });

  group('GetCondensedMedicalHistoryUseCase', () {
    test('forwards encounterId to repository', () async {
      final summary = MedicalHistorySummaryEntity(
        encounterId: encounterId,
        date: DateTime.parse('2026-08-27T10:00:00Z'),
        chiefComplaint: 'Fever',
        prescription: const [],
        vitals: const MedicalHistoryVitalsEntity(),
      );

      when(() => repository.getCondensedMedicalHistory(
            encounterId: encounterId,
          )).thenAnswer((_) async => Right(summary));

      final result = await getCondensedMedicalHistoryUseCase(
        encounterId: encounterId,
      );

      expect(result, Right(summary));
      verify(() => repository.getCondensedMedicalHistory(
            encounterId: encounterId,
          )).called(1);
    });
  });

  group('GetEncounterDetailUseCase', () {
    test('forwards encounterId to repository', () async {
      final detail = EncounterDetailEntity(
        encounter: EncounterEntity(
          id: encounterId,
          patientId: patientId,
          clinicId: 'clinic-1',
          openedByDoctorId: 'doctor-1',
          status: EncounterStatus.open,
          startedAt: DateTime.parse('2026-08-27T10:00:00Z'),
        ),
        vitals: const [],
        labs: const [],
        diagnoses: const [],
        prescriptions: const [],
      );

      when(() => repository.getEncounterDetail(
            encounterId: encounterId,
          )).thenAnswer((_) async => Right(detail));

      final result = await getEncounterDetailUseCase(
        encounterId: encounterId,
      );

      expect(result, Right(detail));
      verify(() => repository.getEncounterDetail(
            encounterId: encounterId,
          )).called(1);
    });
  });

  group('GetAppointmentsUseCase', () {
    test('forwards parameters to repository', () async {
      when(() => repository.getAppointments(
            patientId: patientId,
            status: 'scheduled',
          )).thenAnswer((_) async => const Right([]));

      final result = await getAppointmentsUseCase(
        patientId: patientId,
        status: 'scheduled',
      );

      expect(result, const Right<Failure, List<AppointmentEntity>>([]));
      verify(() => repository.getAppointments(
            patientId: patientId,
            status: 'scheduled',
          )).called(1);
    });
  });
}
