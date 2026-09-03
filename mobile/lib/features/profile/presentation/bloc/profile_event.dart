sealed class ProfileEvent {}

class LoadProfile extends ProfileEvent {}

class UpdateProfileRequested extends ProfileEvent {
  final String firstName;
  final String lastName;
  final String? phone;
  final String? gender;
  final DateTime? dateOfBirth;

  UpdateProfileRequested({
    required this.firstName,
    required this.lastName,
    this.phone,
    this.gender,
    this.dateOfBirth,
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