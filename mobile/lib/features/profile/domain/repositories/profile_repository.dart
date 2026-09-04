import '../entities/patient_profile_entity.dart';


abstract class ProfileRepository {


  Future<PatientProfileEntity> getProfile();


  Future<PatientProfileEntity> updateDemographics({
    required String firstName,
    required String lastName,
    String? phone,
    String? gender,
    DateTime? dateOfBirth,
  });



  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });



  Future<void> deactivateAccount();



  Future<void> logout();

}