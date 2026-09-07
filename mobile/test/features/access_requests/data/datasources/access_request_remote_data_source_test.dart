import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:afyamind_mobile/core/network/api_client.dart';
import 'package:afyamind_mobile/features/access_requests/data/datasources/access_request_remote_data_source.dart';
import 'package:afyamind_mobile/features/access_requests/data/models/access_request_dto.dart';
import 'package:afyamind_mobile/features/access_requests/data/models/clinic_grant_dto.dart';
import 'package:afyamind_mobile/core/errors/exceptions.dart';

class MockApiClient extends Mock implements ApiClient {}
class MockDio extends Mock implements Dio {}

void main() {
  late AccessRequestRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;
  late MockDio mockDio;

  setUp(() {
    mockApiClient = MockApiClient();
    mockDio = MockDio();
    when(() => mockApiClient.dio).thenReturn(mockDio);
    dataSource = AccessRequestRemoteDataSourceImpl(mockApiClient);
  });

  group('getPendingAccessRequests', () {
    test('should return list of AccessRequestDto when response code is 200', () async {
      final mockData = {
        'data': [
          {
            'id': 'req-1',
            'clinic_id': 'clinic-3',
            'clinic_name': 'St. Paul Hospital',
            'doctor_name': 'Dr. Jane Smith',
            'reason': 'Checkup',
            'status': 'pending',
            'expires_at': '2026-09-07T12:00:00Z',
            'created_at': '2026-09-07T11:00:00Z',
          }
        ]
      };

      when(() => mockDio.get('/access-requests?status=pending')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: mockData,
        ),
      );

      final result = await dataSource.getPendingAccessRequests();

      expect(result, isA<List<AccessRequestDto>>());
      expect(result.length, 1);
      expect(result.first.id, 'req-1');
    });

    test('should throw ServerException when response code is not 200', () async {
      when(() => mockDio.get('/access-requests?status=pending')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 400,
          data: {'message': 'Error'},
        ),
      );

      expect(() => dataSource.getPendingAccessRequests(), throwsA(isA<ServerException>()));
    });
  });

  group('approveAccessRequest', () {
    test('should complete successfully when status is 200', () async {
      when(() => mockDio.patch(
            '/access-requests/req-1/decision',
            data: {'decision': 'approve'},
          )).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        ),
      );

      await expectLater(dataSource.approveAccessRequest('req-1'), completes);
    });
  });

  group('denyAccessRequest', () {
    test('should complete successfully when status is 200', () async {
      when(() => mockDio.patch(
            '/access-requests/req-1/decision',
            data: {'decision': 'deny'},
          )).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        ),
      );

      await expectLater(dataSource.denyAccessRequest('req-1'), completes);
    });
  });

  group('getActiveGrants', () {
    test('should return list of ClinicGrantDto when status is 200', () async {
      final mockData = {
        'data': [
          {
            'grant_id': 'grant-1',
            'clinic_id': 'clinic-1',
            'clinic_name': 'Afya Hospital',
            'granted_at': '2026-09-07T11:00:00Z',
          }
        ]
      };

      when(() => mockDio.get('/clinic-grants')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: mockData,
        ),
      );

      final result = await dataSource.getActiveGrants();

      expect(result, isA<List<ClinicGrantDto>>());
      expect(result.length, 1);
      expect(result.first.grantId, 'grant-1');
    });
  });

  group('revokeClinicGrant', () {
    test('should complete successfully when status is 200', () async {
      when(() => mockDio.delete('/clinic-grants/clinic-1')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        ),
      );

      await expectLater(dataSource.revokeClinicGrant('clinic-1'), completes);
    });
  });
}
