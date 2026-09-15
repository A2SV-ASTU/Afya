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

  PatientUserEntity copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? dateOfBirth,
    String? sex,
    String? bloodType,
    String? emergencyContactName,
    String? emergencyContactPhone,
    bool? hasPin,
  }) {
    return PatientUserEntity(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      sex: sex ?? this.sex,
      bloodType: bloodType ?? this.bloodType,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      hasPin: hasPin ?? this.hasPin,
    );
  }

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
