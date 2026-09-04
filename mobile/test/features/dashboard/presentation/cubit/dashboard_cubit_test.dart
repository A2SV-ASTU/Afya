import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:afyamind_mobile/features/auth/domain/entities/auth_session_entity.dart';
import 'package:afyamind_mobile/features/auth/domain/entities/patient_user_entity.dart';
import 'package:afyamind_mobile/features/auth/domain/usecases/get_auth_session_usecase.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/entities/appointment_entity.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/entities/encounter_detail_entity.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/usecases/get_appointments_usecase.dart';
import 'package:afyamind_mobile/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:afyamind_mobile/features/dashboard/presentation/cubit/dashboard_state.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/entities/local_dose_record_entity.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/services/medication_reconciliation_service.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/usecases/get_local_dose_records_usecase.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/usecases/get_prescriptions_usecase.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/usecases/handle_snooze_usecase.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/usecases/record_dose_adherence_usecase.dart';

class MockGetAuthSessionUseCase extends Mock implements GetAuthSessionUseCase {}

class MockMedicationReconciliationService extends Mock
    implements MedicationReconciliationService {}

class MockGetLocalDoseRecordsUseCase extends Mock
    implements GetLocalDoseRecordsUseCase {}

class MockRecordDoseAdherenceUseCase extends Mock
    implements RecordDoseAdherenceUseCase {}

class MockHandleSnoozeUseCase extends Mock implements HandleSnoozeUseCase {}

class MockGetAppointmentsUseCase extends Mock
    implements GetAppointmentsUseCase {}

class MockGetPrescriptionsUseCase extends Mock
    implements GetPrescriptionsUseCase {}

void main() {
  late MockGetAuthSessionUseCase mockAuthSession;
  late MockMedicationReconciliationService mockReconciliation;
  late MockGetLocalDoseRecordsUseCase mockGetDoses;
  late MockRecordDoseAdherenceUseCase mockRecordDose;
  late MockHandleSnoozeUseCase mockHandleSnooze;
  late MockGetAppointmentsUseCase mockGetAppointments;
  late MockGetPrescriptionsUseCase mockGetPrescriptions;

  const sampleUser = PatientUserEntity(
    id: 'user-1',
    firstName: 'Alex',
    lastName: 'Morgan',
    phone: '1234567890',
    email: 'alex@example.com',
  );

  final sampleDose1 = LocalDoseRecordEntity(
    id: 'dose-1',
    prescriptionItemId: 'rx-1',
    medicationName: 'Lisinopril',
    dose: '10mg',
    scheduledTime: DateTime.parse('2026-08-30T08:00:00Z'),
    status: DoseStatus.taken,
  );

  final sampleDose2 = LocalDoseRecordEntity(
    id: 'dose-2',
    prescriptionItemId: 'rx-2',
    medicationName: 'Atorvastatin',
    dose: '20mg',
    scheduledTime: DateTime.parse('2026-08-30T13:00:00Z'),
    status: DoseStatus.pending,
  );

  final sampleDose3 = LocalDoseRecordEntity(
    id: 'dose-3',
    prescriptionItemId: 'rx-3',
    medicationName: 'Metformin',
    dose: '500mg',
    scheduledTime: DateTime.parse('2026-08-30T20:00:00Z'),
    status: DoseStatus.missed,
  );

  final sampleAppointment = AppointmentEntity(
    id: 'appt-1',
    clinicId: 'clinic-1',
    doctorId: 'doc-1',
    patientId: 'user-1',
    scheduledAt: DateTime.parse('2026-08-31T10:30:00Z'),
    status: AppointmentStatus.scheduled,
    createdAt: DateTime.parse('2026-08-30T00:00:00Z'),
    updatedAt: DateTime.parse('2026-08-30T00:00:00Z'),
  );

  final samplePrescription = EncounterPrescriptionItemEntity(
    id: 'rx-1',
    medicationName: 'Lisinopril',
    dose: '10mg',
    route: 'Oral',
    frequency: 'Daily',
    duration: '30 days',
    status: EncounterPrescriptionStatus.active,
    instructions: 'Take in the morning with water',
    startedAt: DateTime.parse('2026-08-01T08:00:00Z'),
  );

  setUpAll(() {
    registerFallbackValue(sampleDose1);
  });

  setUp(() {
    mockAuthSession = MockGetAuthSessionUseCase();
    mockReconciliation = MockMedicationReconciliationService();
    mockGetDoses = MockGetLocalDoseRecordsUseCase();
    mockRecordDose = MockRecordDoseAdherenceUseCase();
    mockHandleSnooze = MockHandleSnoozeUseCase();
    mockGetAppointments = MockGetAppointmentsUseCase();
    mockGetPrescriptions = MockGetPrescriptionsUseCase();

    when(() => mockReconciliation.reconcile(now: any(named: 'now')))
        .thenAnswer((_) async {});
  });

  DashboardCubit createCubit() {
    return DashboardCubit(
      getAuthSessionUseCase: mockAuthSession,
      reconciliationService: mockReconciliation,
      getLocalDoseRecordsUseCase: mockGetDoses,
      recordDoseAdherenceUseCase: mockRecordDose,
      handleSnoozeUseCase: mockHandleSnooze,
      getAppointmentsUseCase: mockGetAppointments,
      getPrescriptionsUseCase: mockGetPrescriptions,
    );
  }

  group('DashboardCubit', () {
    test('initial state has status initial', () {
      final cubit = createCubit();
      expect(cubit.state.status, DashboardStatus.initial);
      expect(cubit.state.todayDoses, isEmpty);
      expect(cubit.state.totalCount, 0);
      expect(cubit.state.adherencePercentage, 0);
    });

    blocTest<DashboardCubit, DashboardState>(
      'loads dashboard successfully with user, doses, and appointments',
      build: () {
        when(() => mockAuthSession()).thenAnswer(
          (_) async => const Right(AuthSessionEntity(
            user: sampleUser,
            isAuthenticated: true,
          )),
        );
        when(() => mockGetDoses(forDate: any(named: 'forDate'))).thenAnswer(
          (_) async => Right([sampleDose1, sampleDose2, sampleDose3]),
        );
        when(() => mockGetPrescriptions.getCached()).thenAnswer(
          (_) async => Right([samplePrescription]),
        );
        when(() => mockGetAppointments(
              patientId: any(named: 'patientId'),
              status: any(named: 'status'),
            )).thenAnswer((_) async => Right([sampleAppointment]));

        return createCubit();
      },
      act: (cubit) => cubit.loadDashboard(),
      expect: () => [
        const DashboardState(status: DashboardStatus.loading),
        DashboardState(
          status: DashboardStatus.loaded,
          user: sampleUser,
          todayDoses: [sampleDose1, sampleDose2, sampleDose3],
          cachedPrescriptions: [samplePrescription],
          nextAppointment: sampleAppointment,
        ),
      ],
      verify: (_) {
        verify(() => mockReconciliation.reconcile()).called(1);
        verify(() => mockAuthSession()).called(1);
        verify(() => mockGetDoses(forDate: any(named: 'forDate'))).called(1);
      },
    );

    test('adherence percentage calculation is accurate', () {
      final state = DashboardState(
        todayDoses: [sampleDose1, sampleDose2, sampleDose3],
      );
      // 1 taken out of 3 total = 33%
      expect(state.takenCount, 1);
      expect(state.pendingCount, 1);
      expect(state.missedCount, 1);
      expect(state.totalCount, 3);
      expect(state.adherencePercentage, 33);

      final state2 = DashboardState(
        todayDoses: [
          sampleDose1,
          sampleDose1.copyWith(id: 'd-2'),
          sampleDose2,
        ],
      );
      // 2 taken out of 3 total = 67% (matches screenshot!)
      expect(state2.takenCount, 2);
      expect(state2.pendingCount, 1);
      expect(state2.totalCount, 3);
      expect(state2.adherencePercentage, 67);
    });

    blocTest<DashboardCubit, DashboardState>(
      'markDoseTaken updates adherence and reloads doses',
      build: () {
        when(() => mockRecordDose(doseRecord: any(named: 'doseRecord')))
            .thenAnswer((_) async => const Right(null));
        when(() => mockGetDoses(forDate: any(named: 'forDate'))).thenAnswer(
          (_) async => Right([sampleDose1.copyWith(status: DoseStatus.taken)]),
        );
        return createCubit();
      },
      act: (cubit) => cubit.markDoseTaken(sampleDose2),
      expect: () => [
        DashboardState(
          todayDoses: [sampleDose1.copyWith(status: DoseStatus.taken)],
        ),
      ],
      verify: (_) {
        verify(() => mockRecordDose(doseRecord: any(named: 'doseRecord')))
            .called(1);
      },
    );

    blocTest<DashboardCubit, DashboardState>(
      'snoozeDose triggers handleSnooze and reloads doses',
      build: () {
        when(() => mockHandleSnooze(doseId: 'dose-2')).thenAnswer(
          (_) async => Right(sampleDose2.copyWith(snoozeCount: 1)),
        );
        when(() => mockGetDoses(forDate: any(named: 'forDate'))).thenAnswer(
          (_) async => Right([sampleDose2.copyWith(snoozeCount: 1)]),
        );
        return createCubit();
      },
      act: (cubit) => cubit.snoozeDose(sampleDose2),
      expect: () => [
        DashboardState(
          todayDoses: [sampleDose2.copyWith(snoozeCount: 1)],
        ),
      ],
      verify: (_) {
        verify(() => mockHandleSnooze(doseId: 'dose-2')).called(1);
      },
    );
  });
}
