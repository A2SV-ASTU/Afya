import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/access_request_repository.dart';

class ApproveAccessRequestUseCase {
  final AccessRequestRepository repository;

  const ApproveAccessRequestUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String requestId) {
    return repository.approveAccessRequest(requestId);
  }
}
