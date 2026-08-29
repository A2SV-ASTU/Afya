import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class LogoutPatientUseCase {
  final AuthRepository _repository;

  LogoutPatientUseCase(this._repository);

  Future<Either<Failure, void>> call() {
    return _repository.logout();
  }
}
