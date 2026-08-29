import 'package:flutter_test/flutter_test.dart';

import 'package:afyamind_mobile/features/access_requests/domain/entities/access_request_entity.dart';

void main() {
  final tDateTime = DateTime(2026, 1, 1);
  final tExpiresAt = DateTime(2026, 2, 1);

  final tAccessRequestEntity = AccessRequestEntity(
    id: '1',
    clinicId: 'c1',
    clinicName: 'Clinic A',
    doctorName: 'Dr. Smith',
    reason: 'Checkup',
    status: 'pending',
    expiresAt: tExpiresAt,
    createdAt: tDateTime,
  );

  group('AccessRequestEntity', () {
    test('should be an Equatable', () {
      expect(tAccessRequestEntity, isA<AccessRequestEntity>());
    });

    test('should return correct props', () {
      expect(
        tAccessRequestEntity.props,
        [
          '1',
          'c1',
          'Clinic A',
          'Dr. Smith',
          'Checkup',
          'pending',
          tExpiresAt,
          tDateTime,
        ],
      );
    });

    test('two instances with same data should be equal', () {
      final another = AccessRequestEntity(
        id: '1',
        clinicId: 'c1',
        clinicName: 'Clinic A',
        doctorName: 'Dr. Smith',
        reason: 'Checkup',
        status: 'pending',
        expiresAt: tExpiresAt,
        createdAt: tDateTime,
      );
      expect(tAccessRequestEntity, equals(another));
    });

    test('two instances with different data should not be equal', () {
      final different = AccessRequestEntity(
        id: '2',
        clinicId: 'c2',
        clinicName: 'Clinic B',
        doctorName: 'Dr. Jones',
        reason: 'Emergency',
        status: 'approved',
        expiresAt: tExpiresAt,
        createdAt: tDateTime,
      );
      expect(tAccessRequestEntity, isNot(equals(different)));
    });
  });
}
