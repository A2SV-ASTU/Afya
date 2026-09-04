import 'package:injectable/injectable.dart';

import '../entities/patient_profile_entity.dart';
import '../repositories/profile_repository.dart';

@injectable
class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  Future<PatientProfileEntity> call() {
    return repository.getProfile();
  }
}