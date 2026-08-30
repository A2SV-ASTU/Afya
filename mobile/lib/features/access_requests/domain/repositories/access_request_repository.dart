import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/access_request_entity.dart';
import '../entities/clinic_grant_entity.dart';

abstract class AccessRequestRepository {
  Future<Either<Failure, List<AccessRequestEntity>>> getPendingAccessRequests();
  Future<Either<Failure, Unit>> approveAccessRequest(String requestId);
  Future<Either<Failure, Unit>> denyAccessRequest(String requestId);
  Future<Either<Failure, List<ClinicGrantEntity>>> getActiveGrants();
  Future<Either<Failure, Unit>> revokeClinicGrant(String clinicId);
}
