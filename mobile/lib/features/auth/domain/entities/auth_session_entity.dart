import 'package:equatable/equatable.dart';
import 'patient_user_entity.dart';

class AuthSessionEntity extends Equatable {
  final PatientUserEntity? user;
  final bool isAuthenticated;
  final bool isPinSet;

  const AuthSessionEntity({
    this.user,
    required this.isAuthenticated,
    this.isPinSet = false,
  });

  const AuthSessionEntity.unauthenticated()
      : user = null,
        isAuthenticated = false,
        isPinSet = false;

  @override
  List<Object?> get props => [user, isAuthenticated, isPinSet];
}
