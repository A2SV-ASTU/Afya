import '../models/profile_model.dart';

abstract class ProfileLocalDataSource {
  Future<void> saveProfile(ProfileModel profile);

  Future<ProfileModel?> getProfile();

  Future<void> clearProfile();
}