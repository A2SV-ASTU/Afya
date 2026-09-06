import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/deactivate_account_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/update_demographics_usecase.dart';

import 'profile_event.dart';
import 'profile_state.dart';

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfile;
  final UpdateDemographicsUseCase updateDemographics;
  final ChangePasswordUseCase changePassword;
  final DeactivateAccountUseCase deactivateAccount;
  final LogoutUseCase logout;

  ProfileBloc({
    required this.getProfile,
    required this.updateDemographics,
    required this.changePassword,
    required this.deactivateAccount,
    required this.logout,
  }) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfileRequested>(_onUpdateProfile);
    on<ChangePasswordRequested>(_onChangePassword);
    on<LogoutRequested>(_onLogout);
    on<DeactivateRequested>(_onDeactivate);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    try {
      final profile = await getProfile();
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileActionLoading());

    try {
      final profile = await updateDemographics(
        firstName: event.firstName,
        lastName: event.lastName,
        phone: event.phone,
        email: event.email,
        gender: event.gender,
        dateOfBirth: event.dateOfBirth,

        // Medical / Emergency Information
        bloodType: event.bloodType,
        emergencyContactName: event.emergencyContactName,
        emergencyContactPhone: event.emergencyContactPhone,
      );

      emit(ProfileUpdated(profile));
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onChangePassword(
    ChangePasswordRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileActionLoading());

    try {
      await changePassword(
        oldPassword: event.oldPassword,
        newPassword: event.newPassword,
      );

      emit(PasswordChanged());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onLogout(
    LogoutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileActionLoading());

    try {
      await logout();
      emit(ProfileLoggedOut());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onDeactivate(
    DeactivateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileActionLoading());

    try {
      await deactivateAccount();
      emit(ProfileDeactivated());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}