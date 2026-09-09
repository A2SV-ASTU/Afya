import 'package:equatable/equatable.dart';
import '../../domain/entities/patient_user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final PatientUserEntity user;

  const Authenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class PinRequired extends AuthState {
  final PatientUserEntity user;

  const PinRequired({required this.user});

  @override
  List<Object?> get props => [user];
}

class CreatePinRequired extends AuthState {
  final PatientUserEntity user;

  const CreatePinRequired({required this.user});

  @override
  List<Object?> get props => [user];
}

class EmailVerificationRequired extends AuthState {
  final String email;

  const EmailVerificationRequired({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthFailure extends AuthState {
  final String message;
  final String? code;

  const AuthFailure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}
