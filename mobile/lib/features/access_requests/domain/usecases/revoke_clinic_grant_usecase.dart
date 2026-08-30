import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/access_request_repository.dart';

@lazySingleton
class RevokeClinicGrantUseCase {
  final AccessRequestRepository repository;

  const RevokeClinicGrantUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String clinicId) {
    return repository.revokeClinicGrant(clinicId);
  }
}
