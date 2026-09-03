import 'package:injectable/injectable.dart';

import '../repositories/profile_repository.dart';

@injectable
class LogoutUseCase {
  final ProfileRepository repository;

  LogoutUseCase(this.repository);

  Future<void> call() {
    return repository.logout();
  }
}