import '../../domain/entities/access_request_entity.dart';

class AccessRequestModel extends AccessRequestEntity {
  const AccessRequestModel({
    required super.id,
    required super.clinicId,
    required super.clinicName,
    required super.doctorName,
    required super.reason,
    required super.status,
    required super.expiresAt,
    required super.createdAt,
  });

  factory AccessRequestModel.fromJson(Map<String, dynamic> json) {
    return AccessRequestModel(
      id: json['id'] as String,
      // Backend uses 'requesting_clinic_id', mobile uses 'clinicId'
      clinicId: (json['clinic_id'] ?? json['requesting_clinic_id']) as String,
      // clinic_name may be populated by backend JOIN or may be absent
      clinicName: (json['clinic_name'] ?? 'Unknown Clinic') as String,
      // doctor_name may be populated by backend JOIN or may be absent
      doctorName: (json['doctor_name'] ?? 'Unknown Doctor') as String,
      reason: (json['reason'] ?? '') as String,
      status: json['status'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String).toLocal(),
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clinic_id': clinicId,
      'clinic_name': clinicName,
      'doctor_name': doctorName,
      'reason': reason,
      'status': status,
      'expires_at': expiresAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
