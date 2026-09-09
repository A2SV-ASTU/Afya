import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/patient_user_entity.dart';
import '../repositories/auth_repository.dart';

class VerifyEmailParams {
  final String email;
  final String otp;

  const VerifyEmailParams({required this.email, required this.otp});
}

@lazySingleton
class VerifyEmailUseCase {
  final AuthRepository _repository;

  VerifyEmailUseCase(this._repository);

  Future<Either<Failure, PatientUserEntity>> call(VerifyEmailParams params) {
    return _repository.verifyEmail(email: params.email, otp: params.otp);
  }
}
