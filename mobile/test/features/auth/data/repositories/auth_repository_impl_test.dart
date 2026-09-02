import 'package:afyamind_mobile/core/errors/exceptions.dart';
import 'package:afyamind_mobile/core/errors/failures.dart';
import 'package:afyamind_mobile/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:afyamind_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:afyamind_mobile/features/auth/data/models/patient_user_model.dart';
import 'package:afyamind_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  const tUserModel = PatientUserModel(
    id: 'user_123',
    firstName: 'Jane',
    lastName: 'Doe',
    phone: '+1555444333',
    email: 'patient@example.com',
  );

  group('AuthRepositoryImpl - register', () {
    test('should save user session locally and return Right(user) when remote succeeds', () async {
      when(() => mockRemoteDataSource.register(
            firstName: any(named: 'firstName'),
            lastName: any(named: 'lastName'),
            phone: any(named: 'phone'),
            password: any(named: 'password'),
            email: any(named: 'email'),
            role: any(named: 'role'),
          )).thenAnswer((_) async => tUserModel);

      when(() => mockLocalDataSource.saveUserSession(tUserModel)).thenAnswer((_) async {});

      final result = await repository.register(
        firstName: 'Jane',
        lastName: 'Doe',
        phone: '+1555444333',
        password: 'patientpassword',
        email: 'patient@example.com',
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (l) => fail('Should have returned Right'),
        (user) {
          expect(user.id, 'user_123');
          expect(user.firstName, 'Jane');
        },
      );
      verify(() => mockLocalDataSource.saveUserSession(tUserModel)).called(1);
    });

    test('should return Left(ServerFailure) when ServerException occurs', () async {
      when(() => mockRemoteDataSource.register(
            firstName: any(named: 'firstName'),
            lastName: any(named: 'lastName'),
            phone: any(named: 'phone'),
            password: any(named: 'password'),
            email: any(named: 'email'),
            role: any(named: 'role'),
          )).thenThrow(const ServerException('Email conflict', code: '409'));

      final result = await repository.register(
        firstName: 'Jane',
        lastName: 'Doe',
        phone: '+1555444333',
        password: 'patientpassword',
        email: 'patient@example.com',
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.code, '409');
        },
        (_) => fail('Should have returned Left'),
      );
    });
  });

  group('AuthRepositoryImpl - getAuthSession', () {
    test('should return authenticated session when local user exists', () async {
      when(() => mockLocalDataSource.getUserSession()).thenAnswer((_) async => tUserModel);
      when(() => mockLocalDataSource.hasPin()).thenAnswer((_) async => true);

      final result = await repository.getAuthSession();

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be right'),
        (session) {
          expect(session.isAuthenticated, isTrue);
          expect(session.isPinSet, isTrue);
          expect(session.user?.id, 'user_123');
        },
      );
    });
  });
}
