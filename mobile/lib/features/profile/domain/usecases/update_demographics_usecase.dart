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
    String? phone,
    String? gender,
    DateTime? dateOfBirth,
  }) {
    return repository.updateDemographics(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      gender: gender,
      dateOfBirth: dateOfBirth,
    );
  }
}