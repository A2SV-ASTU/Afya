import 'package:injectable/injectable.dart';

import '../../domain/entities/patient_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_data_source.dart';
import '../datasources/profile_remote_data_source.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remote;
  final ProfileLocalDataSource local;

  ProfileRepositoryImpl({
    required this.remote,
    required this.local,
  });

  @override
  Future<PatientProfileEntity> getProfile() async {
    try {
      // Try to get the latest profile from the backend.
      final profile = await remote.getProfile();

      // Save the latest profile locally.
      await local.saveProfile(profile);

      return profile;
    } catch (e) {
      // Backend unavailable/offline.
      // Try the cached profile instead.
      final cachedProfile = await local.getProfile();

      if (cachedProfile != null) {
        return cachedProfile;
      }

      // No cached profile exists, so let the BLoC show the error.
      rethrow;
    }
  }

  @override
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
  }) async {
    final profile = await remote.updateDemographics(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      gender: gender,
      dateOfBirth: dateOfBirth,
      bloodType: bloodType,
      emergencyContactName: emergencyContactName,
      emergencyContactPhone: emergencyContactPhone,
    );

    // Keep the local cache updated.
    await local.saveProfile(profile);

    return profile;
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) {
    return remote.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<void> deactivateAccount() {
    return remote.deactivateAccount();
  }

  @override
  Future<void> logout() {
    return remote.logout();
  }
}