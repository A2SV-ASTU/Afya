import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/auth_session_entity.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class GetAuthSessionUseCase {
  final AuthRepository _repository;

  GetAuthSessionUseCase(this._repository);

  Future<Either<Failure, AuthSessionEntity>> call() {
    return _repository.getAuthSession();
  }
}
