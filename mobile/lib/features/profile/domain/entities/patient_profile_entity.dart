class PatientProfileEntity {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? gender;

  // Medical / Emergency Information
  final String? bloodType;
  final String? emergencyContactName;
  final String? emergencyContactPhone;

  const PatientProfileEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.bloodType,
    this.emergencyContactName,
    this.emergencyContactPhone,
  });
}
