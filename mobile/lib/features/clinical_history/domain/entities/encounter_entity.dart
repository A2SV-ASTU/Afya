import 'package:equatable/equatable.dart';

enum EncounterStatus {
  open,
  closed,
}

class EncounterEntity extends Equatable {
  final String id;
  final String patientId;
  final String clinicId;
  final String openedByDoctorId;
  final String? clinicName;
  final String? doctorName;
  final EncounterStatus status;
  final DateTime startedAt;
  final DateTime? endedAt;

  const EncounterEntity({
    required this.id,
    required this.patientId,
    required this.clinicId,
    required this.openedByDoctorId,
    this.clinicName,
    this.doctorName,
    required this.status,
    required this.startedAt,
    this.endedAt,
  });

  @override
  List<Object?> get props => [
        id,
        patientId,
        clinicId,
        openedByDoctorId,
        clinicName,
        doctorName,
        status,
        startedAt,
        endedAt,
      ];
}
