import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/access_request_entity.dart';
import '../repositories/access_request_repository.dart';

@lazySingleton
class GetPendingAccessRequestsUseCase {
  final AccessRequestRepository repository;

  const GetPendingAccessRequestsUseCase(this.repository);

  Future<Either<Failure, List<AccessRequestEntity>>> call() {
    return repository.getPendingAccessRequests();
  }
}
