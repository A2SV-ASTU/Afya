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
      clinicId: json['clinic_id'] as String,
      clinicName: json['clinic_name'] as String,
      doctorName: json['doctor_name'] as String,
      reason: json['reason'] as String,
      status: json['status'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
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
