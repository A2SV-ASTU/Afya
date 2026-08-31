import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/patient_user_entity.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class LoginWithPinUseCase {
  final AuthRepository _repository;

  LoginWithPinUseCase(this._repository);

  Future<Either<Failure, PatientUserEntity>> call(String pin) {
    return _repository.loginWithPin(pin);
  }
}
