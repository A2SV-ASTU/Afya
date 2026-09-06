sealed class ProfileEvent {}

class LoadProfile extends ProfileEvent {}

class UpdateProfileRequested extends ProfileEvent {
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? gender;
  final DateTime? dateOfBirth;

  // Medical / Emergency Information
  final String? bloodType;
  final String? emergencyContactName;
  final String? emergencyContactPhone;

  UpdateProfileRequested({
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.gender,
    this.dateOfBirth,
    this.bloodType,
    this.emergencyContactName,
    this.emergencyContactPhone,
  });
}

class ChangePasswordRequested extends ProfileEvent {
  final String oldPassword;
  final String newPassword;

  ChangePasswordRequested({
    required this.oldPassword,
    required this.newPassword,
  });
}

class LogoutRequested extends ProfileEvent {}

class DeactivateRequested extends ProfileEvent {}
