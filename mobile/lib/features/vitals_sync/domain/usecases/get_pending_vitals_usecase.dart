import 'package:injectable/injectable.dart';

import '../entities/vital_sign_entity.dart';
import '../repositories/vitals_repository.dart';

@lazySingleton
class GetPendingVitalsUseCase {
  final VitalsRepository repository;

  GetPendingVitalsUseCase(this.repository);

  Future<List<VitalSignEntity>> call() {
    return repository.getPendingVitals();
  }
}