import 'package:injectable/injectable.dart';

import '../../domain/entities/patient_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remote;

  ProfileRepositoryImpl(this.remote);

  @override
  Future<PatientProfileEntity> getProfile() {
    return remote.getProfile();
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
}) {
  return remote.updateDemographics(
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