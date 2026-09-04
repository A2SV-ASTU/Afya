import '../../domain/entities/clinic_grant_entity.dart';

class ClinicGrantModel extends ClinicGrantEntity {
  const ClinicGrantModel({
    required super.grantId,
    required super.clinicId,
    required super.clinicName,
    required super.grantedAt,
  });

  factory ClinicGrantModel.fromJson(Map<String, dynamic> json) {
    return ClinicGrantModel(
      // Backend returns 'id', mobile expects 'grant_id'
      grantId: (json['grant_id'] ?? json['id']) as String,
      // Backend returns 'requesting_clinic_id', mobile expects 'clinic_id'
      clinicId: (json['clinic_id'] ?? json['requesting_clinic_id']) as String,
      // clinic_name may be populated by backend JOIN or may be absent
      clinicName: (json['clinic_name'] ?? 'Unknown Clinic') as String,
      // Backend returns 'created_at', mobile expects 'granted_at'
      grantedAt: DateTime.parse(
        (json['granted_at'] ?? json['created_at']) as String,
      ).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'grant_id': grantId,
      'clinic_id': clinicId,
      'clinic_name': clinicName,
      'granted_at': grantedAt.toIso8601String(),
    };
  }
}
