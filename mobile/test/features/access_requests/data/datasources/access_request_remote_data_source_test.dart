import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:afyamind_mobile/features/access_requests/data/datasources/access_request_remote_data_source.dart';
import 'package:afyamind_mobile/features/access_requests/data/models/access_request_model.dart';
import 'package:afyamind_mobile/features/access_requests/data/models/clinic_grant_model.dart';

class MockDio extends Mock implements Dio {}

class MockResponse extends Mock implements Response {}

void main() {
  late AccessRequestRemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = AccessRequestRemoteDataSourceImpl(dio: mockDio);
  });

  final tAccessRequestJson = {
    'id': '1',
    'clinic_id': 'c1',
    'clinic_name': 'Clinic A',
    'doctor_name': 'Dr. Smith',
    'reason': 'Checkup',
    'status': 'pending',
    'expires_at': '2026-02-01T00:00:00.000',
    'created_at': '2026-01-01T00:00:00.000',
  };

  final tClinicGrantJson = {
    'grant_id': 'g1',
    'clinic_id': 'c1',
    'clinic_name': 'Clinic A',
    'granted_at': '2026-01-01T00:00:00.000',
  };

  group('getPendingAccessRequests', () {
    test('should return list of AccessRequestModel on success', () async {
      final response = Response(
        data: [tAccessRequestJson],
        statusCode: 200,
        requestOptions: RequestOptions(path: '/patient/access-requests/active'),
      );
      when(() => mockDio.get('/patient/access-requests/active'))
          .thenAnswer((_) async => response);

      final result = await dataSource.getPendingAccessRequests();

      expect(result, isA<List<AccessRequestModel>>());
      expect(result.length, 1);
      expect(result[0].id, '1');
      expect(result[0].clinicId, 'c1');
      expect(result[0].clinicName, 'Clinic A');
      verify(() => mockDio.get('/patient/access-requests/active')).called(1);
    });

    test('should throw DioException on failure', () async {
      when(() => mockDio.get('/patient/access-requests/active')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/patient/access-requests/active'),
          message: 'Network error',
        ),
      );

      expect(
        () => dataSource.getPendingAccessRequests(),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('approveAccessRequest', () {
    test('should post to correct endpoint on success', () async {
      final response = Response(
        data: null,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/patient/access-requests/1/approve'),
      );
      when(() => mockDio.post('/patient/access-requests/1/approve'))
          .thenAnswer((_) async => response);

      await dataSource.approveAccessRequest('1');

      verify(() => mockDio.post('/patient/access-requests/1/approve')).called(1);
    });

    test('should throw DioException on failure', () async {
      when(() => mockDio.post('/patient/access-requests/1/approve')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/patient/access-requests/1/approve'),
          message: 'Server error',
        ),
      );

      expect(
        () => dataSource.approveAccessRequest('1'),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('denyAccessRequest', () {
    test('should post to correct endpoint on success', () async {
      final response = Response(
        data: null,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/patient/access-requests/1/deny'),
      );
      when(() => mockDio.post('/patient/access-requests/1/deny'))
          .thenAnswer((_) async => response);

      await dataSource.denyAccessRequest('1');

      verify(() => mockDio.post('/patient/access-requests/1/deny')).called(1);
    });

    test('should throw DioException on failure', () async {
      when(() => mockDio.post('/patient/access-requests/1/deny')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/patient/access-requests/1/deny'),
          message: 'Server error',
        ),
      );

      expect(
        () => dataSource.denyAccessRequest('1'),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('getActiveGrants', () {
    test('should return list of ClinicGrantModel on success', () async {
      final response = Response(
        data: [tClinicGrantJson],
        statusCode: 200,
        requestOptions: RequestOptions(path: '/patient/grants'),
      );
      when(() => mockDio.get('/patient/grants'))
          .thenAnswer((_) async => response);

      final result = await dataSource.getActiveGrants();

      expect(result, isA<List<ClinicGrantModel>>());
      expect(result.length, 1);
      expect(result[0].grantId, 'g1');
      expect(result[0].clinicId, 'c1');
      expect(result[0].clinicName, 'Clinic A');
      verify(() => mockDio.get('/patient/grants')).called(1);
    });

    test('should throw DioException on failure', () async {
      when(() => mockDio.get('/patient/grants')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/patient/grants'),
          message: 'Network error',
        ),
      );

      expect(
        () => dataSource.getActiveGrants(),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('revokeClinicGrant', () {
    test('should post to correct endpoint on success', () async {
      final response = Response(
        data: null,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/patient/grants/c1/revoke'),
      );
      when(() => mockDio.post('/patient/grants/c1/revoke'))
          .thenAnswer((_) async => response);

      await dataSource.revokeClinicGrant('c1');

      verify(() => mockDio.post('/patient/grants/c1/revoke')).called(1);
    });

    test('should throw DioException on failure', () async {
      when(() => mockDio.post('/patient/grants/c1/revoke')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/patient/grants/c1/revoke'),
          message: 'Server error',
        ),
      );

      expect(
        () => dataSource.revokeClinicGrant('c1'),
        throwsA(isA<DioException>()),
      );
    });
  });
}
