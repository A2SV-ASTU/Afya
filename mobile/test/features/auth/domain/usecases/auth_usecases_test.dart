import 'package:afyamind_mobile/features/auth/domain/entities/auth_session_entity.dart';
import 'package:afyamind_mobile/features/auth/domain/entities/patient_user_entity.dart';
import 'package:afyamind_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:afyamind_mobile/features/auth/domain/usecases/get_auth_session_usecase.dart';
import 'package:afyamind_mobile/features/auth/domain/usecases/login_patient_usecase.dart';
import 'package:afyamind_mobile/features/auth/domain/usecases/logout_patient_usecase.dart';
import 'package:afyamind_mobile/features/auth/domain/usecases/register_patient_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late RegisterPatientUseCase registerUseCase;
  late LoginPatientUseCase loginUseCase;
  late LogoutPatientUseCase logoutUseCase;
  late GetAuthSessionUseCase getSessionUseCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    registerUseCase = RegisterPatientUseCase(mockRepository);
    loginUseCase = LoginPatientUseCase(mockRepository);
    logoutUseCase = LogoutPatientUseCase(mockRepository);
    getSessionUseCase = GetAuthSessionUseCase(mockRepository);
  });

  const tPatientUser = PatientUserEntity(
    id: 'user_123',
    firstName: 'Jane',
    lastName: 'Doe',
    phone: '+1555444333',
    email: 'patient@example.com',
  );

  test('RegisterPatientUseCase should delegate to repository.register', () async {
    when(() => mockRepository.register(
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
          phone: any(named: 'phone'),
          password: any(named: 'password'),
          email: any(named: 'email'),
          role: any(named: 'role'),
        )).thenAnswer((_) async => const Right(tPatientUser));

    const params = RegisterPatientParams(
      firstName: 'Jane',
      lastName: 'Doe',
      phone: '+1555444333',
      password: 'patientpassword',
      email: 'patient@example.com',
    );

    final result = await registerUseCase(params);
    expect(result, equals(const Right(tPatientUser)));
    verify(() => mockRepository.register(
          firstName: 'Jane',
          lastName: 'Doe',
          phone: '+1555444333',
          password: 'patientpassword',
          email: 'patient@example.com',
          role: 'patient',
        )).called(1);
  });

  test('LoginPatientUseCase should delegate to repository.login', () async {
    when(() => mockRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => const Right(tPatientUser));

    const params = LoginPatientParams(email: 'patient@example.com', password: 'patientpassword');

    final result = await loginUseCase(params);
    expect(result, equals(const Right(tPatientUser)));
    verify(() => mockRepository.login(email: 'patient@example.com', password: 'patientpassword')).called(1);
  });

  test('LogoutPatientUseCase should delegate to repository.logout', () async {
    when(() => mockRepository.logout()).thenAnswer((_) async => const Right(null));

    final result = await logoutUseCase();
    expect(result, equals(const Right(null)));
    verify(() => mockRepository.logout()).called(1);
  });

  test('GetAuthSessionUseCase should delegate to repository.getAuthSession', () async {
    const tSession = AuthSessionEntity(user: tPatientUser, isAuthenticated: true);
    when(() => mockRepository.getAuthSession()).thenAnswer((_) async => const Right(tSession));

    final result = await getSessionUseCase();
    expect(result, equals(const Right(tSession)));
  });
}
