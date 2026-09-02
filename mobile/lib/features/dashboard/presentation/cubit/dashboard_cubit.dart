import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../auth/domain/usecases/get_auth_session_usecase.dart';
import '../../../clinical_history/domain/entities/appointment_entity.dart';
import '../../../clinical_history/domain/entities/encounter_detail_entity.dart';
import '../../../clinical_history/domain/usecases/get_appointments_usecase.dart';
import '../../../medication_and_adherence/domain/entities/local_dose_record_entity.dart';
import '../../../medication_and_adherence/domain/services/medication_reconciliation_service.dart';
import '../../../medication_and_adherence/domain/usecases/get_local_dose_records_usecase.dart';
import '../../../medication_and_adherence/domain/usecases/get_prescriptions_usecase.dart';
import '../../../medication_and_adherence/domain/usecases/handle_snooze_usecase.dart';
import '../../../medication_and_adherence/domain/usecases/record_dose_adherence_usecase.dart';
import 'dashboard_state.dart';

@injectable
class DashboardCubit extends Cubit<DashboardState> {
  final GetAuthSessionUseCase _getAuthSessionUseCase;
  final MedicationReconciliationService _reconciliationService;
  final GetLocalDoseRecordsUseCase _getLocalDoseRecordsUseCase;
  final RecordDoseAdherenceUseCase _recordDoseAdherenceUseCase;
  final HandleSnoozeUseCase _handleSnoozeUseCase;
  final GetAppointmentsUseCase _getAppointmentsUseCase;
  final GetPrescriptionsUseCase _getPrescriptionsUseCase;

  DashboardCubit({
    required GetAuthSessionUseCase getAuthSessionUseCase,
    required MedicationReconciliationService reconciliationService,
    required GetLocalDoseRecordsUseCase getLocalDoseRecordsUseCase,
    required RecordDoseAdherenceUseCase recordDoseAdherenceUseCase,
    required HandleSnoozeUseCase handleSnoozeUseCase,
    required GetAppointmentsUseCase getAppointmentsUseCase,
    required GetPrescriptionsUseCase getPrescriptionsUseCase,
  })  : _getAuthSessionUseCase = getAuthSessionUseCase,
        _reconciliationService = reconciliationService,
        _getLocalDoseRecordsUseCase = getLocalDoseRecordsUseCase,
        _recordDoseAdherenceUseCase = recordDoseAdherenceUseCase,
        _handleSnoozeUseCase = handleSnoozeUseCase,
        _getAppointmentsUseCase = getAppointmentsUseCase,
        _getPrescriptionsUseCase = getPrescriptionsUseCase,
        super(const DashboardState());

  Future<void> loadDashboard({bool forceRefresh = false}) async {
    if (state.status == DashboardStatus.initial || forceRefresh) {
      emit(state.copyWith(status: DashboardStatus.loading));
    }

    try {
      // 1. Reconcile overdue doses
      await _reconciliationService.reconcile();

      // 2. Fetch current user session
      final sessionResult = await _getAuthSessionUseCase();
      final user = sessionResult.fold((_) => null, (session) => session.user);

      // 3. Fetch today's dose records
      final now = DateTime.now();
      final doseResult = await _getLocalDoseRecordsUseCase(forDate: now);
      final List<LocalDoseRecordEntity> doses = doseResult.fold(
        (_) => [],
        (items) => List<LocalDoseRecordEntity>.from(items)
          ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime)),
      );

      // 4. Fetch cached prescriptions for route/instructions lookup
      final rxResult = await _getPrescriptionsUseCase.getCached();
      final List<EncounterPrescriptionItemEntity> cachedRx =
          rxResult.fold((_) => [], (items) => items);

      // 5. Fetch upcoming appointments
      final apptResult = await _getAppointmentsUseCase(
        patientId: 'me',
        status: 'scheduled',
      );
      final AppointmentEntity? nextAppt = apptResult.fold(
        (_) => null,
        (appointments) {
          final upcoming = appointments
              .where((a) => a.status == AppointmentStatus.scheduled)
              .toList()
            ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
          return upcoming.isEmpty ? null : upcoming.first;
        },
      );

      emit(state.copyWith(
        status: DashboardStatus.loaded,
        user: user,
        todayDoses: doses,
        cachedPrescriptions: cachedRx,
        nextAppointment: nextAppt,
        clearNextAppointment: nextAppt == null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> markDoseTaken(LocalDoseRecordEntity dose) async {
    final updatedDose = dose.copyWith(
      status: DoseStatus.taken,
      recordedAt: DateTime.now(),
    );
    final result = await _recordDoseAdherenceUseCase(doseRecord: updatedDose);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => _reloadDoses(),
    );
  }

  Future<void> snoozeDose(LocalDoseRecordEntity dose) async {
    final result = await _handleSnoozeUseCase(doseId: dose.id);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => _reloadDoses(),
    );
  }

  Future<void> skipDose(LocalDoseRecordEntity dose, String reason) async {
    final updatedDose = dose.copyWith(
      status: DoseStatus.skipped,
      recordedAt: DateTime.now(),
      skipReason: reason,
    );
    final result = await _recordDoseAdherenceUseCase(doseRecord: updatedDose);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => _reloadDoses(),
    );
  }

  Future<void> _reloadDoses() async {
    final doseResult =
        await _getLocalDoseRecordsUseCase(forDate: DateTime.now());
    doseResult.fold(
      (_) => null,
      (items) {
        final sorted = List<LocalDoseRecordEntity>.from(items)
          ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
        emit(state.copyWith(todayDoses: sorted));
      },
    );
  }
}
