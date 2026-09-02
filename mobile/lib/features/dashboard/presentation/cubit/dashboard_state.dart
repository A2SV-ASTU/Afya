import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/patient_user_entity.dart';
import '../../../clinical_history/domain/entities/appointment_entity.dart';
import '../../../clinical_history/domain/entities/encounter_detail_entity.dart';
import '../../../medication_and_adherence/domain/entities/local_dose_record_entity.dart';

enum DashboardStatus {
  initial,
  loading,
  loaded,
  error,
}

class DashboardState extends Equatable {
  final DashboardStatus status;
  final PatientUserEntity? user;
  final List<LocalDoseRecordEntity> todayDoses;
  final List<EncounterPrescriptionItemEntity> cachedPrescriptions;
  final AppointmentEntity? nextAppointment;
  final String? errorMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.user,
    this.todayDoses = const [],
    this.cachedPrescriptions = const [],
    this.nextAppointment,
    this.errorMessage,
  });

  int get takenCount =>
      todayDoses.where((d) => d.status == DoseStatus.taken).length;

  int get pendingCount =>
      todayDoses.where((d) => d.status == DoseStatus.pending).length;

  int get missedCount =>
      todayDoses.where((d) => d.status == DoseStatus.missed).length;

  int get skippedCount =>
      todayDoses.where((d) => d.status == DoseStatus.skipped).length;

  int get totalCount => todayDoses.length;

  int get adherencePercentage =>
      totalCount > 0 ? ((takenCount / totalCount) * 100).round() : 0;

  DashboardState copyWith({
    DashboardStatus? status,
    PatientUserEntity? user,
    List<LocalDoseRecordEntity>? todayDoses,
    List<EncounterPrescriptionItemEntity>? cachedPrescriptions,
    AppointmentEntity? nextAppointment,
    bool clearNextAppointment = false,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      user: user ?? this.user,
      todayDoses: todayDoses ?? this.todayDoses,
      cachedPrescriptions: cachedPrescriptions ?? this.cachedPrescriptions,
      nextAppointment: clearNextAppointment
          ? null
          : (nextAppointment ?? this.nextAppointment),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        user,
        todayDoses,
        cachedPrescriptions,
        nextAppointment,
        errorMessage,
      ];
}
