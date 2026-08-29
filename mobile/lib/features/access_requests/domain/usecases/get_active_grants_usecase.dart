import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/clinic_grant_entity.dart';
import '../repositories/access_request_repository.dart';

class GetActiveGrantsUseCase {
  final AccessRequestRepository repository;

  const GetActiveGrantsUseCase(this.repository);

  Future<Either<Failure, List<ClinicGrantEntity>>> call() {
    return repository.getActiveGrants();
  }
}
