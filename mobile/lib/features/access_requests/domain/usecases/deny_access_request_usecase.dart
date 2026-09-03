import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/access_request_repository.dart';

@lazySingleton
class DenyAccessRequestUseCase {
  final AccessRequestRepository repository;

  const DenyAccessRequestUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String requestId) {
    return repository.denyAccessRequest(requestId);
  }
}
