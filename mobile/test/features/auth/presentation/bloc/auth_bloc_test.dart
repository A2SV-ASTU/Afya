import 'package:afyamind_mobile/core/errors/failures.dart';
import 'package:afyamind_mobile/features/auth/domain/entities/auth_session_entity.dart';
import 'package:afyamind_mobile/features/auth/domain/entities/patient_user_entity.dart';
import 'package:afyamind_mobile/features/auth/domain/usecases/get_auth_session_usecase.dart';
import 'package:afyamind_mobile/features/auth/domain/usecases/login_patient_usecase.dart';
import 'package:afyamind_mobile/features/auth/domain/usecases/login_with_pin_usecase.dart';
import 'package:afyamind_mobile/features/auth/domain/usecases/logout_patient_usecase.dart';
import 'package:afyamind_mobile/features/auth/domain/usecases/register_patient_usecase.dart';
import 'package:afyamind_mobile/features/auth/domain/usecases/set_pin_usecase.dart';
import 'package:afyamind_mobile/features/auth/domain/usecases/verify_email_usecase.dart';
import 'package:afyamind_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:afyamind_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:afyamind_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAuthSessionUseCase extends Mock implements GetAuthSessionUseCase {}

class MockLoginPatientUseCase extends Mock implements LoginPatientUseCase {}

class MockRegisterPatientUseCase extends Mock
    implements RegisterPatientUseCase {}

class MockLogoutPatientUseCase extends Mock implements LogoutPatientUseCase {}

class MockLoginWithPinUseCase extends Mock implements LoginWithPinUseCase {}

class MockSetPinUseCase extends Mock implements SetPinUseCase {}

class MockVerifyEmailUseCase extends Mock implements VerifyEmailUseCase {}

void main() {
  late MockGetAuthSessionUseCase mockGetAuthSessionUseCase;
  late MockLoginPatientUseCase mockLoginPatientUseCase;
  late MockRegisterPatientUseCase mockRegisterPatientUseCase;
  late MockLogoutPatientUseCase mockLogoutPatientUseCase;
  late MockLoginWithPinUseCase mockLoginWithPinUseCase;
  late MockSetPinUseCase mockSetPinUseCase;
  late MockVerifyEmailUseCase mockVerifyEmailUseCase;
  late AuthBloc authBloc;

  setUpAll(() {
    registerFallbackValue(const LoginPatientParams(email: '', password: ''));
    registerFallbackValue(const RegisterPatientParams(
      firstName: '',
      lastName: '',
      phone: '',
      password: '',
      email: '',
    ));
  });

  setUp(() {
    mockGetAuthSessionUseCase = MockGetAuthSessionUseCase();
    mockLoginPatientUseCase = MockLoginPatientUseCase();
    mockRegisterPatientUseCase = MockRegisterPatientUseCase();
    mockLogoutPatientUseCase = MockLogoutPatientUseCase();
    mockLoginWithPinUseCase = MockLoginWithPinUseCase();
    mockSetPinUseCase = MockSetPinUseCase();
    mockVerifyEmailUseCase = MockVerifyEmailUseCase();

    authBloc = AuthBloc(
      getAuthSessionUseCase: mockGetAuthSessionUseCase,
      loginPatientUseCase: mockLoginPatientUseCase,
      registerPatientUseCase: mockRegisterPatientUseCase,
      logoutPatientUseCase: mockLogoutPatientUseCase,
      loginWithPinUseCase: mockLoginWithPinUseCase,
      setPinUseCase: mockSetPinUseCase,
      verifyEmailUseCase: mockVerifyEmailUseCase,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  const tPatientUserNoPin = PatientUserEntity(
    id: 'user_123',
    firstName: 'Jane',
    lastName: 'Doe',
    phone: '+1555444333',
    email: 'patient@example.com',
    hasPin: false,
  );

  const tPatientUserWithPin = PatientUserEntity(
    id: 'user_123',
    firstName: 'Jane',
    lastName: 'Doe',
    phone: '+1555444333',
    email: 'patient@example.com',
    hasPin: true,
  );

  test('initial state is AuthInitial', () {
    expect(authBloc.state, equals(const AuthInitial()));
  });

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, CreatePinRequired] when AppStarted finds active session without PIN',
    build: () {
      when(() => mockGetAuthSessionUseCase()).thenAnswer(
        (_) async => const Right(AuthSessionEntity(
          user: tPatientUserNoPin,
          isAuthenticated: true,
          isPinSet: false,
        )),
      );
      return authBloc;
    },
    act: (bloc) => bloc.add(const AppStarted()),
    expect: () => [
      const AuthLoading(),
      const CreatePinRequired(user: tPatientUserNoPin),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, PinRequired] when AppStarted finds active session with PIN set',
    build: () {
      when(() => mockGetAuthSessionUseCase()).thenAnswer(
        (_) async => const Right(AuthSessionEntity(
          user: tPatientUserWithPin,
          isAuthenticated: true,
          isPinSet: true,
        )),
      );
      return authBloc;
    },
    act: (bloc) => bloc.add(const AppStarted()),
    expect: () => [
      const AuthLoading(),
      const PinRequired(user: tPatientUserWithPin),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, Unauthenticated] when AppStarted finds no session',
    build: () {
      when(() => mockGetAuthSessionUseCase()).thenAnswer(
        (_) async => const Right(AuthSessionEntity.unauthenticated()),
      );
      return authBloc;
    },
    act: (bloc) => bloc.add(const AppStarted()),
    expect: () => [
      const AuthLoading(),
      const Unauthenticated(),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, CreatePinRequired] on successful LoginSubmitted without PIN',
    build: () {
      when(() => mockLoginPatientUseCase(any())).thenAnswer(
        (_) async => const Right(tPatientUserNoPin),
      );
      return authBloc;
    },
    act: (bloc) => bloc.add(const LoginSubmitted(
      email: 'patient@example.com',
      password: 'patientpassword',
    )),
    expect: () => [
      const AuthLoading(),
      const CreatePinRequired(user: tPatientUserNoPin),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, Authenticated] on successful LoginSubmitted with PIN',
    build: () {
      when(() => mockLoginPatientUseCase(any())).thenAnswer(
        (_) async => const Right(tPatientUserWithPin),
      );
      return authBloc;
    },
    act: (bloc) => bloc.add(const LoginSubmitted(
      email: 'patient@example.com',
      password: 'patientpassword',
    )),
    expect: () => [
      const AuthLoading(),
      const Authenticated(user: tPatientUserWithPin),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthFailure] on failed LoginSubmitted',
    build: () {
      when(() => mockLoginPatientUseCase(any())).thenAnswer(
        (_) async =>
            const Left(ServerFailure('Invalid credentials', code: '401')),
      );
      return authBloc;
    },
    act: (bloc) => bloc.add(const LoginSubmitted(
      email: 'patient@example.com',
      password: 'WrongPassword',
    )),
    expect: () => [
      const AuthLoading(),
      const AuthFailure(message: 'Invalid credentials', code: '401'),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, EmailVerificationRequired] on successful RegisterSubmitted',
    build: () {
      when(() => mockRegisterPatientUseCase(any())).thenAnswer(
        (_) async => const Right(tPatientUserNoPin),
      );
      return authBloc;
    },
    act: (bloc) => bloc.add(const RegisterSubmitted(
      firstName: 'Jane',
      lastName: 'Doe',
      email: 'patient@example.com',
      phone: '+1555444333',
      password: 'patientpassword',
    )),
    expect: () => [
      const AuthLoading(),
      const EmailVerificationRequired(email: 'patient@example.com'),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits PinRequired when AppLockRequested',
    build: () {
      when(() => mockGetAuthSessionUseCase()).thenAnswer(
        (_) async => const Right(AuthSessionEntity(
          user: tPatientUserWithPin,
          isAuthenticated: true,
          isPinSet: true,
        )),
      );
      return authBloc;
    },
    seed: () => const Authenticated(user: tPatientUserWithPin),
    act: (bloc) => bloc.add(const AppLockRequested()),
    expect: () => [
      const PinRequired(user: tPatientUserWithPin),
    ],
  );
}
