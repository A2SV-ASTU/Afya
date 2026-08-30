import 'package:equatable/equatable.dart';

class PatientUserEntity extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String dateOfBirth;
  final String sex;
  final String? bloodType;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final bool hasPin;

  const PatientUserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    this.dateOfBirth = '',
    this.sex = '',
    this.bloodType,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.hasPin = false,
  });

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        phone,
        email,
        dateOfBirth,
        sex,
        bloodType,
        emergencyContactName,
        emergencyContactPhone,
        hasPin,
      ];
}
