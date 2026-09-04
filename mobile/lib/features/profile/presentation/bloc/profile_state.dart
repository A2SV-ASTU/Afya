import '../../domain/entities/patient_profile_entity.dart';

sealed class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileActionLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final PatientProfileEntity profile;

  ProfileLoaded(this.profile);
}

class ProfileUpdated extends ProfileState {
  final PatientProfileEntity profile;

  ProfileUpdated(this.profile);
}

class PasswordChanged extends ProfileState {}

class ProfileLoggedOut extends ProfileState {}

class ProfileDeactivated extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}