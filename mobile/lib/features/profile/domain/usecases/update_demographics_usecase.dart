import 'package:injectable/injectable.dart';

import '../entities/patient_profile_entity.dart';
import '../repositories/profile_repository.dart';

@injectable
class UpdateDemographicsUseCase {
  final ProfileRepository repository;

  UpdateDemographicsUseCase(this.repository);

  Future<PatientProfileEntity> call({
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
  }) {
    return repository.updateDemographics(
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
}
