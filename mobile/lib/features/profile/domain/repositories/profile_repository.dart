import '../entities/patient_profile_entity.dart';

abstract class ProfileRepository {
  Future<PatientProfileEntity> getProfile();

  Future<PatientProfileEntity> updateDemographics({
  required String firstName,
  required String lastName,
  String? email,
  String? phone,
  String? gender,
  DateTime? dateOfBirth,
  String? bloodType,
  String? emergencyContactName,
  String? emergencyContactPhone,
});

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  Future<void> deactivateAccount();

  Future<void> logout();
}