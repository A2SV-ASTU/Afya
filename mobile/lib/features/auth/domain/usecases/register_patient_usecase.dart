import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/patient_user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterPatientParams extends Equatable {
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

  const RegisterPatientParams({
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

@lazySingleton
class RegisterPatientUseCase {
  final AuthRepository _repository;

  RegisterPatientUseCase(this._repository);

  Future<Either<Failure, PatientUserEntity>> call(RegisterPatientParams params) {
    return _repository.register(
      firstName: params.firstName,
      lastName: params.lastName,
      phone: params.phone,
      password: params.password,
      email: params.email,
      dateOfBirth: params.dateOfBirth,
      sex: params.sex,
      bloodType: params.bloodType,
      emergencyContactName: params.emergencyContactName,
      emergencyContactPhone: params.emergencyContactPhone,
      role: params.role,
    );
  }
}
