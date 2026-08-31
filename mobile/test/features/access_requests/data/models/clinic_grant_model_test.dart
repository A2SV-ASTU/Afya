import 'package:flutter_test/flutter_test.dart';

import 'package:afyamind_mobile/features/access_requests/data/models/clinic_grant_model.dart';

void main() {
  final tJson = {
    'grant_id': 'g1',
    'clinic_id': 'c1',
    'clinic_name': 'Clinic A',
    'granted_at': '2026-01-01T00:00:00.000',
  };

  final tModel = ClinicGrantModel(
    grantId: 'g1',
    clinicId: 'c1',
    clinicName: 'Clinic A',
    grantedAt: DateTime(2026, 1, 1),
  );

  group('ClinicGrantModel', () {
    test('fromJson should return a valid model', () {
      final result = ClinicGrantModel.fromJson(tJson);
      expect(result, equals(tModel));
    });

    test('toJson should return a valid JSON map', () {
      final result = tModel.toJson();
      expect(result, equals(tJson));
    });

    test('fromJson and toJson should be symmetric', () {
      final fromJsonResult = ClinicGrantModel.fromJson(tJson);
      final toJsonResult = fromJsonResult.toJson();
      expect(toJsonResult, equals(tJson));
    });

    test('fromJson should handle different valid JSON', () {
      final differentJson = {
        'grant_id': 'g2',
        'clinic_id': 'c2',
        'clinic_name': 'Clinic B',
        'granted_at': '2026-06-01T12:30:00.000',
      };

      final result = ClinicGrantModel.fromJson(differentJson);

      expect(result.grantId, 'g2');
      expect(result.clinicId, 'c2');
      expect(result.clinicName, 'Clinic B');
      expect(result.grantedAt, DateTime(2026, 6, 1, 12, 30));
    });
  });
}
