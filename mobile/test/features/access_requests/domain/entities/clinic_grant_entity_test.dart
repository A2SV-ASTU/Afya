import 'package:flutter_test/flutter_test.dart';

import 'package:afyamind_mobile/features/access_requests/domain/entities/clinic_grant_entity.dart';

void main() {
  final tDateTime = DateTime(2026, 1, 1);

  final tClinicGrantEntity = ClinicGrantEntity(
    grantId: 'g1',
    clinicId: 'c1',
    clinicName: 'Clinic A',
    grantedAt: tDateTime,
  );

  group('ClinicGrantEntity', () {
    test('should be an Equatable', () {
      expect(tClinicGrantEntity, isA<ClinicGrantEntity>());
    });

    test('should return correct props', () {
      expect(
        tClinicGrantEntity.props,
        ['g1', 'c1', 'Clinic A', tDateTime],
      );
    });

    test('two instances with same data should be equal', () {
      final another = ClinicGrantEntity(
        grantId: 'g1',
        clinicId: 'c1',
        clinicName: 'Clinic A',
        grantedAt: tDateTime,
      );
      expect(tClinicGrantEntity, equals(another));
    });

    test('two instances with different data should not be equal', () {
      final different = ClinicGrantEntity(
        grantId: 'g2',
        clinicId: 'c2',
        clinicName: 'Clinic B',
        grantedAt: DateTime(2026, 6, 1),
      );
      expect(tClinicGrantEntity, isNot(equals(different)));
    });
  });
}
