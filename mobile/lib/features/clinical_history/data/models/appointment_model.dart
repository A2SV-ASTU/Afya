import '../../domain/entities/appointment_entity.dart';

class AppointmentModel {
  final String id;
  final String clinicId;
  final String doctorId;
  final String patientId;
  final DateTime scheduledAt;
  final AppointmentStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppointmentModel({
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

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String,
      clinicId: json['clinic_id'] as String,
      doctorId: json['doctor_id'] as String,
      patientId: json['patient_id'] as String,
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      status: _parseStatus(json['status'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static AppointmentStatus _parseStatus(String value) {
    switch (value) {
      case 'scheduled':
        return AppointmentStatus.scheduled;
      case 'attended':
        return AppointmentStatus.attended;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      default:
        throw FormatException('Unknown appointment status: $value');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clinic_id': clinicId,
      'doctor_id': doctorId,
      'patient_id': patientId,
      'scheduled_at': scheduledAt.toIso8601String(),
      'status': status.name,
      if (notes != null) 'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  AppointmentEntity toEntity() {
    return AppointmentEntity(
      id: id,
      clinicId: clinicId,
      doctorId: doctorId,
      patientId: patientId,
      scheduledAt: scheduledAt,
      status: status,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
