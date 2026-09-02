import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/patient_user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginPatientParams extends Equatable {
  final String email;
  final String password;

  const LoginPatientParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

@lazySingleton
class LoginPatientUseCase {
  final AuthRepository _repository;

  LoginPatientUseCase(this._repository);

  Future<Either<Failure, PatientUserEntity>> call(LoginPatientParams params) {
    return _repository.login(
      email: params.email,
      password: params.password,
    );
  }
}
