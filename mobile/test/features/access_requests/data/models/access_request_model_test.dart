import 'package:flutter_test/flutter_test.dart';

import 'package:afyamind_mobile/features/access_requests/data/models/access_request_model.dart';

void main() {
  final tJson = {
    'id': '1',
    'clinic_id': 'c1',
    'clinic_name': 'Clinic A',
    'doctor_name': 'Dr. Smith',
    'reason': 'Checkup',
    'status': 'pending',
    'expires_at': '2026-02-01T00:00:00.000',
    'created_at': '2026-01-01T00:00:00.000',
  };

  final tModel = AccessRequestModel(
    id: '1',
    clinicId: 'c1',
    clinicName: 'Clinic A',
    doctorName: 'Dr. Smith',
    reason: 'Checkup',
    status: 'pending',
    expiresAt: DateTime(2026, 2, 1),
    createdAt: DateTime(2026, 1, 1),
  );

  group('AccessRequestModel', () {
    test('fromJson should return a valid model', () {
      final result = AccessRequestModel.fromJson(tJson);
      expect(result, equals(tModel));
    });

    test('toJson should return a valid JSON map', () {
      final result = tModel.toJson();
      expect(result, equals(tJson));
    });

    test('fromJson and toJson should be symmetric', () {
      final fromJsonResult = AccessRequestModel.fromJson(tJson);
      final toJsonResult = fromJsonResult.toJson();
      expect(toJsonResult, equals(tJson));
    });

    test('fromJson should handle different valid JSON', () {
      final differentJson = {
        'id': '2',
        'clinic_id': 'c2',
        'clinic_name': 'Clinic B',
        'doctor_name': 'Dr. Jones',
        'reason': 'Emergency',
        'status': 'approved',
        'expires_at': '2026-06-01T12:30:00.000',
        'created_at': '2026-05-01T08:00:00.000',
      };

      final result = AccessRequestModel.fromJson(differentJson);

      expect(result.id, '2');
      expect(result.clinicId, 'c2');
      expect(result.clinicName, 'Clinic B');
      expect(result.doctorName, 'Dr. Jones');
      expect(result.reason, 'Emergency');
      expect(result.status, 'approved');
      expect(result.expiresAt, DateTime(2026, 6, 1, 12, 30));
      expect(result.createdAt, DateTime(2026, 5, 1, 8, 0));
    });
  });
}
