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
      grantId: json['grant_id'] as String,
      clinicId: json['clinic_id'] as String,
      clinicName: json['clinic_name'] as String,
      grantedAt: DateTime.parse(json['granted_at'] as String).toLocal(),
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
