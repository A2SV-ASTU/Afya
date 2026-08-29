import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class SetPinUseCase {
  final AuthRepository _repository;

  SetPinUseCase(this._repository);

  Future<Either<Failure, void>> call(String pin) {
    return _repository.setPin(pin);
  }
}
