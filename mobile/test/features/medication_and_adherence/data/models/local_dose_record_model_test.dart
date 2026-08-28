import 'package:flutter_test/flutter_test.dart';

import 'package:afyamind_mobile/features/medication_and_adherence/data/models/local_dose_record_model.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/entities/local_dose_record_entity.dart';

void main() {
  group('LocalDoseRecordModel', () {
    final testDateTime = DateTime.parse('2026-08-28T08:00:00Z');
    final snoozedDateTime = DateTime.parse('2026-08-28T08:30:00Z');
    final recordedDateTime = DateTime.parse('2026-08-28T08:35:00Z');

    final fullJson = {
      'id': 'dose-1',
      'prescription_item_id': 'rx-item-1',
      'medication_name': 'Amoxicillin',
      'dose': '500mg',
      'scheduled_time': '2026-08-28T08:00:00.000Z',
      'snoozed_until': '2026-08-28T08:30:00.000Z',
      'status': 'pending',
      'recorded_at': '2026-08-28T08:35:00.000Z',
      'snooze_count': 2,
      'skip_reason': 'Felt nauseous',
    };

    final minimalJson = {
      'id': 'dose-2',
      'prescription_item_id': 'rx-item-2',
      'medication_name': 'Metformin',
      'dose': '850mg',
      'scheduled_time': '2026-08-28T12:00:00.000Z',
      'status': 'taken',
    };

    test('fromJson parses complete JSON correctly', () {
      final model = LocalDoseRecordModel.fromJson(fullJson);

      expect(model.id, 'dose-1');
      expect(model.prescriptionItemId, 'rx-item-1');
      expect(model.medicationName, 'Amoxicillin');
      expect(model.dose, '500mg');
      expect(model.scheduledTime, testDateTime);
      expect(model.snoozedUntil, snoozedDateTime);
      expect(model.status, DoseStatus.pending);
      expect(model.recordedAt, recordedDateTime);
      expect(model.snoozeCount, 2);
      expect(model.skipReason, 'Felt nauseous');
    });

    test('fromJson parses minimal JSON with default and nullable values', () {
      final model = LocalDoseRecordModel.fromJson(minimalJson);

      expect(model.id, 'dose-2');
      expect(model.prescriptionItemId, 'rx-item-2');
      expect(model.medicationName, 'Metformin');
      expect(model.dose, '850mg');
      expect(model.snoozedUntil, isNull);
      expect(model.status, DoseStatus.taken);
      expect(model.recordedAt, isNull);
      expect(model.snoozeCount, 0);
      expect(model.skipReason, isNull);
    });

    test('parses all DoseStatus values correctly', () {
      expect(
        LocalDoseRecordModel.fromJson({...minimalJson, 'status': 'pending'})
            .status,
        DoseStatus.pending,
      );
      expect(
        LocalDoseRecordModel.fromJson({...minimalJson, 'status': 'taken'})
            .status,
        DoseStatus.taken,
      );
      expect(
        LocalDoseRecordModel.fromJson({...minimalJson, 'status': 'missed'})
            .status,
        DoseStatus.missed,
      );
      expect(
        LocalDoseRecordModel.fromJson({...minimalJson, 'status': 'skipped'})
            .status,
        DoseStatus.skipped,
      );
    });

    test('throws FormatException on invalid status', () {
      expect(
        () => LocalDoseRecordModel.fromJson(
            {...minimalJson, 'status': 'unknown'}),
        throwsA(isA<FormatException>()),
      );
    });

    test('toJson serializes correctly and round-trips cleanly', () {
      final model = LocalDoseRecordModel.fromJson(fullJson);
      final json = model.toJson();

      expect(json['id'], 'dose-1');
      expect(json['prescription_item_id'], 'rx-item-1');
      expect(json['status'], 'pending');
      expect(json['snooze_count'], 2);
      expect(json['skip_reason'], 'Felt nauseous');

      final roundTrip = LocalDoseRecordModel.fromJson(json);
      expect(roundTrip.id, model.id);
      expect(roundTrip.status, model.status);
      expect(roundTrip.snoozeCount, model.snoozeCount);
      expect(roundTrip.skipReason, model.skipReason);
    });

    test('toEntity and fromEntity convert accurately', () {
      final model = LocalDoseRecordModel.fromJson(fullJson);
      final entity = model.toEntity();

      expect(entity.id, model.id);
      expect(entity.prescriptionItemId, model.prescriptionItemId);
      expect(entity.medicationName, model.medicationName);
      expect(entity.status, model.status);
      expect(entity.snoozeCount, model.snoozeCount);

      final convertedBack = LocalDoseRecordModel.fromEntity(entity);
      expect(convertedBack.id, entity.id);
      expect(convertedBack.status, entity.status);
      expect(convertedBack.snoozeCount, entity.snoozeCount);
    });
  });
}
