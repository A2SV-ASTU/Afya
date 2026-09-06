import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();

  Future<ProfileModel> updateDemographics({
    required String firstName,
    required String lastName,
    String? email,
    String? phone,
    String? gender,
    DateTime? dateOfBirth,

    // Medical / Emergency Information
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
