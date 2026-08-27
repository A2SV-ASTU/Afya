import 'package:afyamind_mobile/features/medication_and_adherence/data/models/local_dose_schedule_model.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/entities/local_dose_schedule_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tDose = LocalDoseScheduleModel(
    id: 'dose-001',
    prescriptionItemId: 'rx-101',
    medicationName: 'Amoxicillin',
    dosage: '500mg',
    scheduledTime: DateTime.parse('2026-08-28T08:00:00.000Z'),
    outcome: DoseOutcome.pending,
    loggedAt: null,
    snoozeUntil: DateTime.parse('2026-08-28T08:30:00.000Z'),
    snoozeCount: 1,
  );

  group('LocalDoseScheduleModel', () {
    test('should be a subclass of LocalDoseScheduleEntity', () {
      expect(tDose, isA<LocalDoseScheduleEntity>());
    });

    test('should parse pending, taken, missed, and skipped outcomes correctly',
        () {
      final outcomes = ['pending', 'taken', 'missed', 'skipped'];
      final expectedEnums = [
        DoseOutcome.pending,
        DoseOutcome.taken,
        DoseOutcome.missed,
        DoseOutcome.skipped,
      ];

      for (int i = 0; i < outcomes.length; i++) {
        final jsonMap = {
          'id': 'dose-$i',
          'prescription_item_id': 'rx-101',
          'medication_name': 'Amoxicillin',
          'dosage': '500mg',
          'scheduled_time': '2026-08-28T08:00:00.000Z',
          'outcome': outcomes[i],
        };

        final parsed = LocalDoseScheduleModel.fromJson(jsonMap);
        expect(parsed.outcome, expectedEnums[i]);
      }
    });

    test('should throw FormatException when outcome is invalid or missing', () {
      final invalidJson = {
        'id': 'dose-1',
        'prescription_item_id': 'rx-1',
        'medication_name': 'Drug',
        'dosage': '10mg',
        'scheduled_time': '2026-08-28T08:00:00.000Z',
        'outcome': 'invalid_outcome',
      };

      expect(
        () => LocalDoseScheduleModel.fromJson(invalidJson),
        throwsA(isA<FormatException>()),
      );
    });

    test('should serialize to JSON map accurately for Hive storage', () {
      final jsonMap = tDose.toJson();

      expect(jsonMap['id'], 'dose-001');
      expect(jsonMap['prescription_item_id'], 'rx-101');
      expect(jsonMap['medication_name'], 'Amoxicillin');
      expect(jsonMap['dosage'], '500mg');
      expect(jsonMap['scheduled_time'], '2026-08-28T08:00:00.000Z');
      expect(jsonMap['outcome'], 'pending');
      expect(jsonMap['snooze_until'], '2026-08-28T08:30:00.000Z');
      expect(jsonMap['snooze_count'], 1);
    });

    test('should convert to and from LocalDoseScheduleEntity', () {
      final entity = tDose.toEntity();
      expect(entity, isA<LocalDoseScheduleEntity>());
      expect(entity.id, tDose.id);

      final fromEntity = LocalDoseScheduleModel.fromEntity(entity);
      expect(fromEntity, tDose);
    });
  });
}
