import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_session_entity.dart';
import '../entities/patient_user_entity.dart';

abstract class AuthRepository {
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
  });

  Future<Either<Failure, PatientUserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, AuthSessionEntity>> getAuthSession();

  Future<Either<Failure, AuthSessionEntity>> refreshSession();

  Future<Either<Failure, void>> setPin(String pin);

  Future<Either<Failure, PatientUserEntity>> loginWithPin(String pin);
}
