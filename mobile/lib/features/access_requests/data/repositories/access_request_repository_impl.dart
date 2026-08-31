import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/access_request_entity.dart';
import '../../domain/entities/clinic_grant_entity.dart';
import '../../domain/repositories/access_request_repository.dart';
import '../datasources/access_request_remote_data_source.dart';

@LazySingleton(as: AccessRequestRepository)
class AccessRequestRepositoryImpl implements AccessRequestRepository {
  final AccessRequestRemoteDataSource remoteDataSource;

  const AccessRequestRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<AccessRequestEntity>>>
      getPendingAccessRequests() async {
    try {
      final result = await remoteDataSource.getPendingAccessRequests();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } on DioException catch (e) {
      if (e.error is ServerException) {
        final serverEx = e.error as ServerException;
        return Left(ServerFailure(serverEx.message, code: serverEx.code));
      }
      return Left(ServerFailure(
        e.message ?? e.error?.toString() ?? 'An unexpected error occurred',
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> approveAccessRequest(String requestId) async {
    try {
      await remoteDataSource.approveAccessRequest(requestId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } on DioException catch (e) {
      if (e.error is ServerException) {
        final serverEx = e.error as ServerException;
        return Left(ServerFailure(serverEx.message, code: serverEx.code));
      }
      return Left(ServerFailure(
        e.message ?? e.error?.toString() ?? 'An unexpected error occurred',
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> denyAccessRequest(String requestId) async {
    try {
      await remoteDataSource.denyAccessRequest(requestId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } on DioException catch (e) {
      if (e.error is ServerException) {
        final serverEx = e.error as ServerException;
        return Left(ServerFailure(serverEx.message, code: serverEx.code));
      }
      return Left(ServerFailure(
        e.message ?? e.error?.toString() ?? 'An unexpected error occurred',
      ));
    }
  }

  @override
  Future<Either<Failure, List<ClinicGrantEntity>>> getActiveGrants() async {
    try {
      final result = await remoteDataSource.getActiveGrants();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } on DioException catch (e) {
      if (e.error is ServerException) {
        final serverEx = e.error as ServerException;
        return Left(ServerFailure(serverEx.message, code: serverEx.code));
      }
      return Left(ServerFailure(
        e.message ?? e.error?.toString() ?? 'An unexpected error occurred',
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> revokeClinicGrant(String clinicId) async {
    try {
      await remoteDataSource.revokeClinicGrant(clinicId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } on DioException catch (e) {
      if (e.error is ServerException) {
        final serverEx = e.error as ServerException;
        return Left(ServerFailure(serverEx.message, code: serverEx.code));
      }
      return Left(ServerFailure(
        e.message ?? e.error?.toString() ?? 'An unexpected error occurred',
      ));
    }
  }
}
