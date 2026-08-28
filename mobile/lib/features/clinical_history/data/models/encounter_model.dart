import '../../domain/entities/encounter_entity.dart';

class EncounterModel {
  final String id;
  final String patientId;
  final String clinicId;
  final String openedByDoctorId;
  final String? clinicName;
  final String? doctorName;
  final EncounterStatus status;
  final DateTime startedAt;
  final DateTime? endedAt;

  const EncounterModel({
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

  factory EncounterModel.fromJson(Map<String, dynamic> json) {
    return EncounterModel(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      clinicId: json['clinic_id'] as String,
      openedByDoctorId: json['opened_by_doctor_id'] as String,
      clinicName: json['clinic_name'] as String?,
      doctorName: json['doctor_name'] as String?,
      status: _parseStatus(json['status'] as String),
      startedAt: DateTime.parse(json['started_at'] as String),
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'] as String)
          : null,
    );
  }

  static EncounterStatus _parseStatus(String value) {
    switch (value) {
      case 'open':
      case 'opened':
        return EncounterStatus.open;
      case 'closed':
        return EncounterStatus.closed;
      default:
        throw FormatException('Unknown encounter status: $value');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'clinic_id': clinicId,
      'opened_by_doctor_id': openedByDoctorId,
      if (clinicName != null) 'clinic_name': clinicName,
      if (doctorName != null) 'doctor_name': doctorName,
      'status': status == EncounterStatus.open ? 'open' : 'closed',
      'started_at': startedAt.toIso8601String(),
      if (endedAt != null) 'ended_at': endedAt!.toIso8601String(),
    };
  }

  EncounterEntity toEntity() {
    return EncounterEntity(
      id: id,
      patientId: patientId,
      clinicId: clinicId,
      openedByDoctorId: openedByDoctorId,
      clinicName: clinicName,
      doctorName: doctorName,
      status: status,
      startedAt: startedAt,
      endedAt: endedAt,
    );
  }
}
