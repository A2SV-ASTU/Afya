import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:afyamind_mobile/core/network/api_client.dart';
import 'package:afyamind_mobile/features/access_requests/data/datasources/access_request_remote_data_source.dart';
import 'package:afyamind_mobile/features/access_requests/data/models/access_request_model.dart';
import 'package:afyamind_mobile/features/access_requests/data/models/clinic_grant_model.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late AccessRequestRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = AccessRequestRemoteDataSourceImpl(mockApiClient);
  });

  group('getPendingAccessRequests', () {
    test('should return empty list (no pending requests displayed)', () async {
      final result = await dataSource.getPendingAccessRequests();

      expect(result, isA<List<AccessRequestModel>>());
      expect(result, isEmpty);
    });
  });

  group('approveAccessRequest', () {
    test('should not throw when called', () async {
      await expectLater(
        dataSource.approveAccessRequest('any-id'),
        completes,
      );
    });
  });

  group('denyAccessRequest', () {
    test('should not throw when called', () async {
      await expectLater(
        dataSource.denyAccessRequest('any-id'),
        completes,
      );
    });
  });

  group('getActiveGrants', () {
    test('should return the mock list of ClinicGrantModel', () async {
      final result = await dataSource.getActiveGrants();

      expect(result, isA<List<ClinicGrantModel>>());
      expect(result.length, 5);
      expect(result[0].grantId, 'grant_001');
      expect(result[0].clinicId, 'clinic_tikur');
      expect(result[0].clinicName, 'Tikur Anbessa Specialized Hospital');
      expect(result[1].grantId, 'grant_002');
      expect(result[1].clinicId, 'clinic_afya');
      expect(result[1].clinicName, 'Afya Specialized Hospital');
    });

    test('should return updated list after a grant is revoked', () async {
      await dataSource.revokeClinicGrant('clinic_tikur');
      final result = await dataSource.getActiveGrants();

      expect(result.length, 4);
      expect(result.any((g) => g.clinicId == 'clinic_tikur'), isFalse);
    });
  });

  group('revokeClinicGrant', () {
    test('should remove the grant with matching clinicId', () async {
      final before = await dataSource.getActiveGrants();
      expect(before.length, 5);

      await dataSource.revokeClinicGrant('clinic_tikur');

      final after = await dataSource.getActiveGrants();
      expect(after.length, 4);
      expect(after.any((g) => g.clinicId == 'clinic_tikur'), isFalse);
    });

    test('should remove all grants when all are revoked', () async {
      final grants = await dataSource.getActiveGrants();
      for (final grant in grants) {
        await dataSource.revokeClinicGrant(grant.clinicId);
      }

      final result = await dataSource.getActiveGrants();
      expect(result, isEmpty);
    });

    test('should not throw when clinicId does not exist', () async {
      await expectLater(
        dataSource.revokeClinicGrant('non-existent-id'),
        completes,
      );
    });
  });
}
