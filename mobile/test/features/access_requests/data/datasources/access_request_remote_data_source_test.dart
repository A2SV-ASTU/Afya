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
      expect(result.length, 2);
      expect(result[0].grantId, 'grant_001');
      expect(result[0].clinicId, 'clinic_afya');
      expect(result[0].clinicName, 'Afya Hospital');
      expect(result[1].grantId, 'grant_002');
      expect(result[1].clinicId, 'clinic_aamc');
      expect(result[1].clinicName, 'Addis Ababa Medical Center');
    });

    test('should return updated list after a grant is revoked', () async {
      await dataSource.revokeClinicGrant('clinic_afya');
      final result = await dataSource.getActiveGrants();

      expect(result.length, 1);
      expect(result[0].clinicId, 'clinic_aamc');
    });
  });

  group('revokeClinicGrant', () {
    test('should remove the grant with matching clinicId', () async {
      final before = await dataSource.getActiveGrants();
      expect(before.length, 2);

      await dataSource.revokeClinicGrant('clinic_afya');

      final after = await dataSource.getActiveGrants();
      expect(after.length, 1);
      expect(after.any((g) => g.clinicId == 'clinic_afya'), isFalse);
    });

    test('should remove all grants when both are revoked', () async {
      await dataSource.revokeClinicGrant('clinic_afya');
      await dataSource.revokeClinicGrant('clinic_aamc');

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
