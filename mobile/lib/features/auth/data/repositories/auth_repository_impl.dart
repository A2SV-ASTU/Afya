import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/auth_session_entity.dart';
import '../../domain/entities/patient_user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/patient_user_model.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, PatientUserEntity>> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    required String email,
    String? dateOfBirth,
    String? sex,
    String? bloodType,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String role = 'patient',
  }) async {
    try {
      final userModel = await _remoteDataSource.register(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        password: password,
        email: email,
        dateOfBirth: dateOfBirth,
        sex: sex,
        bloodType: bloodType,
        emergencyContactName: emergencyContactName,
        emergencyContactPhone: emergencyContactPhone,
        role: role,
      );
      await _localDataSource.saveUserSession(userModel);
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PatientUserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await _remoteDataSource.login(
        email: email,
        password: password,
      );
      await _localDataSource.saveUserSession(userModel);
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (_) {
      // Ignore network errors during logout to allow clearing local session offline
    } finally {
      await _localDataSource.clearUserSession();
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, AuthSessionEntity>> getAuthSession() async {
    try {
      final cachedUser = await _localDataSource.getUserSession();
      if (cachedUser != null) {
        final isPinSet = await _localDataSource.hasPin();
        return Right(AuthSessionEntity(
          user: cachedUser,
          isAuthenticated: true,
          isPinSet: isPinSet,
        ));
      }
      return const Right(AuthSessionEntity.unauthenticated());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return const Right(AuthSessionEntity.unauthenticated());
    }
  }

  @override
  Future<Either<Failure, AuthSessionEntity>> refreshSession() async {
    try {
      final refreshedUser = await _remoteDataSource.refreshSession();
      if (refreshedUser != null) {
        await _localDataSource.saveUserSession(refreshedUser);
        final isPinSet = await _localDataSource.hasPin();
        return Right(AuthSessionEntity(
          user: refreshedUser,
          isAuthenticated: true,
          isPinSet: isPinSet,
        ));
      }
      return const Right(AuthSessionEntity.unauthenticated());
    } on ServerException catch (e) {
      if (e.code == '401' || e.code == '403') {
        await _localDataSource.clearUserSession();
        return const Right(AuthSessionEntity.unauthenticated());
      }
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setPin(String pin) async {
    try {
      await _localDataSource.savePin(pin);
      final currentUser = await _localDataSource.getUserSession();
      if (currentUser != null) {
        final updatedModel = PatientUserModel(
          id: currentUser.id,
          firstName: currentUser.firstName,
          lastName: currentUser.lastName,
          phone: currentUser.phone,
          email: currentUser.email,
          dateOfBirth: currentUser.dateOfBirth,
          sex: currentUser.sex,
          hasPin: true,
        );
        await _localDataSource.saveUserSession(updatedModel);
      }
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, PatientUserEntity>> loginWithPin(String pin) async {
    try {
      final isValid = await _localDataSource.verifyPin(pin);
      if (!isValid) {
        return const Left(ServerFailure('Invalid PIN code', code: '401'));
      }
      final cachedUser = await _localDataSource.getUserSession();
      if (cachedUser == null) {
        return const Left(ServerFailure('No local session found', code: '404'));
      }
      return Right(cachedUser);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
