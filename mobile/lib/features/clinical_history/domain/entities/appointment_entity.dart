import 'package:equatable/equatable.dart';

enum AppointmentStatus {
  scheduled,
  attended,
  cancelled,
}

class AppointmentEntity extends Equatable {
  final String id;
  final String clinicId;
  final String doctorId;
  final String patientId;
  final DateTime scheduledAt;
  final AppointmentStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppointmentEntity({
    required this.id,
    required this.clinicId,
    required this.doctorId,
    required this.patientId,
    required this.scheduledAt,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        clinicId,
        doctorId,
        patientId,
        scheduledAt,
        status,
        notes,
        createdAt,
        updatedAt,
      ];
}
