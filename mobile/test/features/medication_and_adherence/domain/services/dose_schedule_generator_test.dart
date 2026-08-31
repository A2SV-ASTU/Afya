import 'package:flutter_test/flutter_test.dart';

import 'package:afyamind_mobile/features/clinical_history/domain/entities/encounter_detail_entity.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/entities/local_dose_record_entity.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/services/dose_schedule_generator.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/services/posology_parser.dart';

void main() {
  late DoseScheduleGenerator generator;

  setUp(() {
    generator = const DoseScheduleGenerator(parser: PosologyParser());
  });

  final testStartedAt = DateTime(2026, 8, 28, 0, 0);

  EncounterPrescriptionItemEntity createPrescription({
    String id = 'rx_item_101',
    String medicationName = 'Amoxicillin',
    String dose = '500mg',
    String route = 'oral',
    String frequency = 'Once daily (OD)',
    String duration = '3 days',
    EncounterPrescriptionStatus status = EncounterPrescriptionStatus.active,
    DateTime? startedAt,
  }) {
    return EncounterPrescriptionItemEntity(
      id: id,
      medicationName: medicationName,
      dose: dose,
      route: route,
      frequency: frequency,
      duration: duration,
      status: status,
      instructions: 'Take after meals',
      startedAt: startedAt ?? testStartedAt,
    );
  }

  group('DoseScheduleGenerator - Frequency & Duration Scheduling', () {
    test('OD + 3 days generates 3 records at 08:00 daily', () {
      final rx = createPrescription(
        frequency: 'Once daily (OD)',
        duration: '3 days',
      );

      final records = generator.generate(rx);

      expect(records.length, 3);
      expect(records[0].scheduledTime, DateTime(2026, 8, 28, 8, 0));
      expect(records[1].scheduledTime, DateTime(2026, 8, 29, 8, 0));
      expect(records[2].scheduledTime, DateTime(2026, 8, 30, 8, 0));
    });

    test('OD + 1 week generates 7 records', () {
      final rx = createPrescription(
        frequency: 'Once daily (OD)',
        duration: '1 week',
      );

      final records = generator.generate(rx);

      expect(records.length, 7);
      expect(records.first.scheduledTime, DateTime(2026, 8, 28, 8, 0));
      expect(records.last.scheduledTime, DateTime(2026, 9, 3, 8, 0));
    });

    test('OD + 1 month generates 30 records', () {
      final rx = createPrescription(
        frequency: 'Once daily (OD)',
        duration: '1 month',
      );

      final records = generator.generate(rx);

      expect(records.length, 30);
      expect(records.first.scheduledTime, DateTime(2026, 8, 28, 8, 0));
      expect(records.last.scheduledTime, DateTime(2026, 9, 26, 8, 0));
    });

    test('BID + 3 days generates 6 records at 08:00 and 20:00 daily', () {
      final rx = createPrescription(
        frequency: 'Twice daily (BD)',
        duration: '3 days',
      );

      final records = generator.generate(rx);

      expect(records.length, 6);
      expect(records[0].scheduledTime, DateTime(2026, 8, 28, 8, 0));
      expect(records[1].scheduledTime, DateTime(2026, 8, 28, 20, 0));
      expect(records[2].scheduledTime, DateTime(2026, 8, 29, 8, 0));
      expect(records[3].scheduledTime, DateTime(2026, 8, 29, 20, 0));
      expect(records[4].scheduledTime, DateTime(2026, 8, 30, 8, 0));
      expect(records[5].scheduledTime, DateTime(2026, 8, 30, 20, 0));
    });

    test('TID + 2 days generates 6 records at 08:00, 14:00, 20:00 daily', () {
      final rx = createPrescription(
        frequency: 'Three times daily (TDS)',
        duration: '2 days',
      );

      final records = generator.generate(rx);

      expect(records.length, 6);
      expect(records[0].scheduledTime, DateTime(2026, 8, 28, 8, 0));
      expect(records[1].scheduledTime, DateTime(2026, 8, 28, 14, 0));
      expect(records[2].scheduledTime, DateTime(2026, 8, 28, 20, 0));
      expect(records[3].scheduledTime, DateTime(2026, 8, 29, 8, 0));
      expect(records[4].scheduledTime, DateTime(2026, 8, 29, 14, 0));
      expect(records[5].scheduledTime, DateTime(2026, 8, 29, 20, 0));
    });

    test('QID + 2 days generates 8 records at 08:00, 12:00, 16:00, 20:00 daily',
        () {
      final rx = createPrescription(
        frequency: 'Four times daily (QDS)',
        duration: '2 days',
      );

      final records = generator.generate(rx);

      expect(records.length, 8);
      expect(records[0].scheduledTime, DateTime(2026, 8, 28, 8, 0));
      expect(records[1].scheduledTime, DateTime(2026, 8, 28, 12, 0));
      expect(records[2].scheduledTime, DateTime(2026, 8, 28, 16, 0));
      expect(records[3].scheduledTime, DateTime(2026, 8, 28, 20, 0));
      expect(records[4].scheduledTime, DateTime(2026, 8, 29, 8, 0));
      expect(records[5].scheduledTime, DateTime(2026, 8, 29, 12, 0));
      expect(records[6].scheduledTime, DateTime(2026, 8, 29, 16, 0));
      expect(records[7].scheduledTime, DateTime(2026, 8, 29, 20, 0));
    });

    test('PRN + 7 days generates 0 scheduled records (as needed)', () {
      final rx = createPrescription(
        frequency: 'As needed (PRN)',
        duration: '7 days',
      );

      final records = generator.generate(rx);

      expect(records, isEmpty);
    });
  });

  group('DoseScheduleGenerator - Inactive Prescriptions & Invalid Inputs', () {
    test('completed prescription returns 0 records', () {
      final rx = createPrescription(
        status: EncounterPrescriptionStatus.completed,
      );

      final records = generator.generate(rx);

      expect(records, isEmpty);
    });

    test('deactivated prescription returns 0 records', () {
      final rx = createPrescription(
        status: EncounterPrescriptionStatus.deactivated,
      );

      final records = generator.generate(rx);

      expect(records, isEmpty);
    });

    test('unknown frequency returns 0 records without creating fake schedule',
        () {
      final rx = createPrescription(
        frequency: 'unknown-frequency-xyz',
      );

      final records = generator.generate(rx);

      expect(records, isEmpty);
    });

    test('invalid duration returns 0 records without silently defaulting', () {
      final rx = createPrescription(
        duration: 'invalid-duration',
      );

      final records = generator.generate(rx);

      expect(records, isEmpty);
    });
  });

  group('DoseScheduleGenerator - Record Entities & Determinism', () {
    test('generated records contain correct initial entity values', () {
      final rx = createPrescription(
        id: 'rx_999',
        medicationName: 'Metformin',
        dose: '1000mg',
        frequency: 'Once daily (OD)',
        duration: '1 day',
      );

      final records = generator.generate(rx);

      expect(records.length, 1);
      final record = records.first;
      expect(record.prescriptionItemId, 'rx_999');
      expect(record.medicationName, 'Metformin');
      expect(record.dose, '1000mg');
      expect(record.status, DoseStatus.pending);
      expect(record.snoozeCount, 0);
      expect(record.snoozedUntil, isNull);
      expect(record.recordedAt, isNull);
      expect(record.skipReason, isNull);
    });

    test('produces deterministic dose IDs on multiple runs', () {
      final rx = createPrescription(
        id: 'rx_deterministic_42',
        frequency: 'Twice daily (BD)',
        duration: '2 days',
      );

      final runA = generator.generate(rx);
      final runB = generator.generate(rx);

      expect(runA.length, runB.length);
      for (var i = 0; i < runA.length; i++) {
        expect(runA[i].id, runB[i].id);
        expect(
          runA[i].id,
          'rx_deterministic_42_${runA[i].scheduledTime.millisecondsSinceEpoch}',
        );
      }
    });

    test('records are returned in chronological order', () {
      final rx = createPrescription(
        frequency: 'Three times daily (TDS)',
        duration: '3 days',
      );

      final records = generator.generate(rx);

      for (var i = 0; i < records.length - 1; i++) {
        expect(
          records[i].scheduledTime.isBefore(records[i + 1].scheduledTime),
          isTrue,
        );
      }
    });

    test(
        'uses calendar date of startedAt when startedAt has a non-midnight time',
        () {
      final afternoonStart = DateTime(2026, 8, 28, 15, 45);
      final rx = createPrescription(
        frequency: 'Once daily (OD)',
        duration: '2 days',
        startedAt: afternoonStart,
      );

      final records = generator.generate(rx);

      expect(records.length, 2);
      expect(records[0].scheduledTime, DateTime(2026, 8, 28, 8, 0));
      expect(records[1].scheduledTime, DateTime(2026, 8, 29, 8, 0));
    });
  });
}
