import 'package:injectable/injectable.dart';

import '../repositories/profile_repository.dart';

@injectable
class DeactivateAccountUseCase {
  final ProfileRepository repository;

  DeactivateAccountUseCase(this.repository);

  Future<void> call() {
    return repository.deactivateAccount();
  }
}