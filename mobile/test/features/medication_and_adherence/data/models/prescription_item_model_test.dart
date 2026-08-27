import 'package:afyamind_mobile/features/medication_and_adherence/data/models/prescription_item_model.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/entities/prescription_item_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tModel = PrescriptionItemModel(
    id: 'rx-101',
    encounterId: 'enc-202',
    medicationName: 'Amoxicillin',
    dosage: '500mg',
    frequency: 'twice daily',
    durationDays: 7,
    instructions: 'Take with food',
    status: PrescriptionItemStatus.active,
    startDate: DateTime.parse('2026-08-28T08:00:00.000Z'),
    endDate: DateTime.parse('2026-09-04T08:00:00.000Z'),
    createdAt: DateTime.parse('2026-08-28T08:00:00.000Z'),
    updatedAt: DateTime.parse('2026-08-28T08:00:00.000Z'),
  );

  group('PrescriptionItemModel', () {
    test('should be a subclass of PrescriptionItemEntity', () {
      expect(tModel, isA<PrescriptionItemEntity>());
    });

    test('should correctly parse valid snake_case JSON from API', () {
      final jsonMap = {
        'id': 'rx-101',
        'encounter_id': 'enc-202',
        'medication_name': 'Amoxicillin',
        'dosage': '500mg',
        'frequency': 'twice daily',
        'duration_days': 7,
        'instructions': 'Take with food',
        'status': 'active',
        'start_date': '2026-08-28T08:00:00.000Z',
        'end_date': '2026-09-04T08:00:00.000Z',
        'created_at': '2026-08-28T08:00:00.000Z',
        'updated_at': '2026-08-28T08:00:00.000Z',
      };

      final result = PrescriptionItemModel.fromJson(jsonMap);

      expect(result.id, 'rx-101');
      expect(result.encounterId, 'enc-202');
      expect(result.medicationName, 'Amoxicillin');
      expect(result.dosage, '500mg');
      expect(result.frequency, 'twice daily');
      expect(result.durationDays, 7);
      expect(result.instructions, 'Take with food');
      expect(result.status, PrescriptionItemStatus.active);
      expect(result.startDate, DateTime.parse('2026-08-28T08:00:00.000Z'));
    });

    test('should parse completed and deactivated statuses accurately', () {
      final completedJson = {
        'id': 'rx-1',
        'encounter_id': 'enc-1',
        'medication_name': 'Metformin',
        'dosage': '850mg',
        'frequency': 'once daily',
        'status': 'completed',
      };
      final deactivatedJson = {
        'id': 'rx-2',
        'encounter_id': 'enc-1',
        'medication_name': 'Lisinopril',
        'dosage': '10mg',
        'frequency': 'once daily',
        'status': 'deactivated',
      };

      final completedResult = PrescriptionItemModel.fromJson(completedJson);
      final deactivatedResult = PrescriptionItemModel.fromJson(deactivatedJson);

      expect(completedResult.status, PrescriptionItemStatus.completed);
      expect(deactivatedResult.status, PrescriptionItemStatus.deactivated);
    });

    test('should throw FormatException when encountering unknown status value',
        () {
      final invalidJson = {
        'id': 'rx-1',
        'encounter_id': 'enc-1',
        'medication_name': 'Drug',
        'dosage': '10mg',
        'frequency': 'once daily',
        'status': 'unknown_status_value',
      };

      expect(
        () => PrescriptionItemModel.fromJson(invalidJson),
        throwsA(isA<FormatException>()),
      );
    });

    test('should throw FormatException when status field is missing', () {
      final missingStatusJson = {
        'id': 'rx-1',
        'encounter_id': 'enc-1',
        'medication_name': 'Drug',
        'dosage': '10mg',
        'frequency': 'once daily',
      };

      expect(
        () => PrescriptionItemModel.fromJson(missingStatusJson),
        throwsA(isA<FormatException>()),
      );
    });

    test('should serialize to JSON map accurately', () {
      final jsonMap = tModel.toJson();

      expect(jsonMap['id'], 'rx-101');
      expect(jsonMap['encounter_id'], 'enc-202');
      expect(jsonMap['medication_name'], 'Amoxicillin');
      expect(jsonMap['dosage'], '500mg');
      expect(jsonMap['frequency'], 'twice daily');
      expect(jsonMap['duration_days'], 7);
      expect(jsonMap['status'], 'active');
      expect(jsonMap['start_date'], '2026-08-28T08:00:00.000Z');
    });

    test('should convert to and from PrescriptionItemEntity', () {
      final entity = tModel.toEntity();
      expect(entity, isA<PrescriptionItemEntity>());
      expect(entity.id, tModel.id);

      final fromEntity = PrescriptionItemModel.fromEntity(entity);
      expect(fromEntity, tModel);
    });
  });
}
