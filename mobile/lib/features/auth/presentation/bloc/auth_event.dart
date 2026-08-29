import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {
  const AppStarted();
}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class RegisterSubmitted extends AuthEvent {
  final String firstName;
  final String lastName;
  final String phone;
  final String password;
  final String email;
  final String? dateOfBirth;
  final String? sex;
  final String? bloodType;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String role;

  const RegisterSubmitted({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.password,
    required this.email,
    this.dateOfBirth,
    this.sex,
    this.bloodType,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.role = 'patient',
  });

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        phone,
        password,
        email,
        dateOfBirth,
        sex,
        bloodType,
        emergencyContactName,
        emergencyContactPhone,
        role,
      ];
}

class LogoutSubmitted extends AuthEvent {
  const LogoutSubmitted();
}

class PinLoginSubmitted extends AuthEvent {
  final String pin;

  const PinLoginSubmitted({required this.pin});

  @override
  List<Object?> get props => [pin];
}

class SetPinSubmitted extends AuthEvent {
  final String pin;

  const SetPinSubmitted({required this.pin});

  @override
  List<Object?> get props => [pin];
}
