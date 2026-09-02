import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/auth_session_entity.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class RefreshTokenUseCase {
  final AuthRepository _repository;

  RefreshTokenUseCase(this._repository);

  Future<Either<Failure, AuthSessionEntity>> call() {
    return _repository.refreshSession();
  }
}
