import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/get_auth_session_usecase.dart';
import '../../domain/usecases/login_patient_usecase.dart';
import '../../domain/usecases/login_with_pin_usecase.dart';
import '../../domain/usecases/logout_patient_usecase.dart';
import '../../domain/usecases/register_patient_usecase.dart';
import '../../domain/usecases/set_pin_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@lazySingleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetAuthSessionUseCase _getAuthSessionUseCase;
  final LoginPatientUseCase _loginPatientUseCase;
  final RegisterPatientUseCase _registerPatientUseCase;
  final LogoutPatientUseCase _logoutPatientUseCase;
  final LoginWithPinUseCase _loginWithPinUseCase;
  final SetPinUseCase _setPinUseCase;

  AuthBloc({
    required GetAuthSessionUseCase getAuthSessionUseCase,
    required LoginPatientUseCase loginPatientUseCase,
    required RegisterPatientUseCase registerPatientUseCase,
    required LogoutPatientUseCase logoutPatientUseCase,
    required LoginWithPinUseCase loginWithPinUseCase,
    required SetPinUseCase setPinUseCase,
  })  : _getAuthSessionUseCase = getAuthSessionUseCase,
        _loginPatientUseCase = loginPatientUseCase,
        _registerPatientUseCase = registerPatientUseCase,
        _logoutPatientUseCase = logoutPatientUseCase,
        _loginWithPinUseCase = loginWithPinUseCase,
        _setPinUseCase = setPinUseCase,
        super(const AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<LogoutSubmitted>(_onLogoutSubmitted);
    on<PinLoginSubmitted>(_onPinLoginSubmitted);
    on<SetPinSubmitted>(_onSetPinSubmitted);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _getAuthSessionUseCase();
    result.fold(
      (failure) => emit(const Unauthenticated()),
      (session) {
        if (session.isAuthenticated && session.user != null) {
          if (session.isPinSet) {
            emit(PinRequired(user: session.user!));
          } else {
            emit(Authenticated(user: session.user!));
          }
        } else {
          emit(const Unauthenticated());
        }
      },
    );
  }

  Future<void> _onLoginSubmitted(LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _loginPatientUseCase(LoginPatientParams(
      email: event.email,
      password: event.password,
    ));

    result.fold(
      (failure) => emit(AuthFailure(message: failure.message, code: failure.code)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  Future<void> _onRegisterSubmitted(RegisterSubmitted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _registerPatientUseCase(RegisterPatientParams(
      firstName: event.firstName,
      lastName: event.lastName,
      phone: event.phone,
      password: event.password,
      dateOfBirth: event.dateOfBirth,
      sex: event.sex,
      email: event.email,
      bloodType: event.bloodType,
      emergencyContactName: event.emergencyContactName,
      emergencyContactPhone: event.emergencyContactPhone,
    ));

    result.fold(
      (failure) => emit(AuthFailure(message: failure.message, code: failure.code)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  Future<void> _onLogoutSubmitted(LogoutSubmitted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    await _logoutPatientUseCase();
    emit(const Unauthenticated());
  }

  Future<void> _onPinLoginSubmitted(PinLoginSubmitted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _loginWithPinUseCase(event.pin);

    result.fold(
      (failure) => emit(AuthFailure(message: failure.message, code: failure.code)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  Future<void> _onSetPinSubmitted(SetPinSubmitted event, Emitter<AuthState> emit) async {
    final result = await _setPinUseCase(event.pin);
    result.fold(
      (failure) => emit(AuthFailure(message: failure.message, code: failure.code)),
      (_) {
        if (state is Authenticated) {
          final user = (state as Authenticated).user;
          emit(Authenticated(user: user));
        }
      },
    );
  }
}
