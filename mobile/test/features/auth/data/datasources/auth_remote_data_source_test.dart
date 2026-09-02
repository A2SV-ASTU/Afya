import 'package:afyamind_mobile/core/constants/api_endpoints.dart';
import 'package:afyamind_mobile/core/errors/exceptions.dart';
import 'package:afyamind_mobile/core/network/api_client.dart';
import 'package:afyamind_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockDio extends Mock implements Dio {}

void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;
  late MockDio mockDio;

  setUp(() {
    mockApiClient = MockApiClient();
    mockDio = MockDio();
    when(() => mockApiClient.dio).thenReturn(mockDio);
    dataSource = AuthRemoteDataSourceImpl(mockApiClient);
  });

  group('AuthRemoteDataSourceImpl - register', () {
    const tFirstName = 'Jane';
    const tLastName = 'Doe';
    const tPhone = '+1555444333';
    const tPassword = 'patientpassword';
    const tEmail = 'patient@example.com';

    final tSuccessResponse = {
      'user': {
        'id': 'user_123',
        'first_name': tFirstName,
        'last_name': tLastName,
        'phone': tPhone,
        'email': tEmail,
      }
    };

    test('should return PatientUserModel when registration succeeds', () async {
      when(() => mockDio.post(
            ApiEndpoints.signup,
            data: any(named: 'data'),
          )).thenAnswer(
        (_) async => Response(
          data: tSuccessResponse,
          statusCode: 201,
          requestOptions: RequestOptions(path: ApiEndpoints.signup),
        ),
      );

      final result = await dataSource.register(
        firstName: tFirstName,
        lastName: tLastName,
        phone: tPhone,
        password: tPassword,
        email: tEmail,
      );

      expect(result.id, 'user_123');
      expect(result.firstName, tFirstName);
      expect(result.phone, tPhone);
    });

    test('should throw ServerException when registration fails', () async {
      when(() => mockDio.post(
            ApiEndpoints.signup,
            data: any(named: 'data'),
          )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.signup),
          response: Response(
            data: {
              'error': {'message': 'Email already registered', 'code': '409'}
            },
            statusCode: 409,
            requestOptions: RequestOptions(path: ApiEndpoints.signup),
          ),
        ),
      );

      expect(
        () => dataSource.register(
          firstName: tFirstName,
          lastName: tLastName,
          phone: tPhone,
          password: tPassword,
          email: tEmail,
        ),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('AuthRemoteDataSourceImpl - login', () {
    const tEmail = 'patient@example.com';
    const tPassword = 'patientpassword';

    test('should return PatientUserModel when login succeeds', () async {
      when(() => mockDio.post(
            ApiEndpoints.login,
            data: any(named: 'data'),
          )).thenAnswer(
        (_) async => Response(
          data: {
            'user': {
              'id': 'user_123',
              'first_name': 'Jane',
              'last_name': 'Doe',
              'phone': '+1555444333',
              'email': tEmail,
            }
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiEndpoints.login),
        ),
      );

      final result = await dataSource.login(email: tEmail, password: tPassword);

      expect(result.id, 'user_123');
      expect(result.email, tEmail);
    });

    test('should throw ServerException on HTTP 401 invalid credentials', () async {
      when(() => mockDio.post(
            ApiEndpoints.login,
            data: any(named: 'data'),
          )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.login),
          response: Response(
            data: {
              'error': {'message': 'Invalid credentials', 'code': '401'}
            },
            statusCode: 401,
            requestOptions: RequestOptions(path: ApiEndpoints.login),
          ),
        ),
      );

      expect(
        () => dataSource.login(email: tEmail, password: tPassword),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
