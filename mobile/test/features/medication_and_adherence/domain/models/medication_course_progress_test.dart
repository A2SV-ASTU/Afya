import 'package:flutter_test/flutter_test.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/entities/encounter_detail_entity.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/entities/local_dose_record_entity.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/models/medication_course_progress.dart';

void main() {
  group('MedicationCourseProgress Unit Tests', () {
    final now = DateTime(2026, 9, 4, 12, 0);
    final twoDaysAgo = DateTime(2026, 9, 2, 8, 0);
    final yesterday = DateTime(2026, 9, 3, 8, 0);
    final today = DateTime(2026, 9, 4, 8, 0);
    final tomorrow = DateTime(2026, 9, 5, 8, 0);
    final inTwoDays = DateTime(2026, 9, 6, 8, 0);

    final tRxVitaminE = EncounterPrescriptionItemEntity(
      id: 'rx_vit_e',
      medicationName: 'Vitamin E',
      dose: '400 IU',
      route: 'Oral Capsule',
      frequency: '1 capsule once daily',
      duration: '5 days (5 capsules total)',
      status: EncounterPrescriptionStatus.active,
      instructions: 'Take 1 capsule daily with food',
      startedAt: twoDaysAgo,
      isTrackingActive: true,
    );

    test('calculates 3/5 taken, 2 remaining for Vitamin E started 2 days ago', () {
      final records = [
        LocalDoseRecordEntity(
          id: 'd1',
          prescriptionItemId: 'rx_vit_e',
          medicationName: 'Vitamin E',
          dose: '400 IU',
          scheduledTime: twoDaysAgo,
          status: DoseStatus.taken,
        ),
        LocalDoseRecordEntity(
          id: 'd2',
          prescriptionItemId: 'rx_vit_e',
          medicationName: 'Vitamin E',
          dose: '400 IU',
          scheduledTime: yesterday,
          status: DoseStatus.taken,
        ),
        LocalDoseRecordEntity(
          id: 'd3',
          prescriptionItemId: 'rx_vit_e',
          medicationName: 'Vitamin E',
          dose: '400 IU',
          scheduledTime: today,
          status: DoseStatus.taken,
        ),
        LocalDoseRecordEntity(
          id: 'd4',
          prescriptionItemId: 'rx_vit_e',
          medicationName: 'Vitamin E',
          dose: '400 IU',
          scheduledTime: tomorrow,
          status: DoseStatus.pending,
        ),
        LocalDoseRecordEntity(
          id: 'd5',
          prescriptionItemId: 'rx_vit_e',
          medicationName: 'Vitamin E',
          dose: '400 IU',
          scheduledTime: inTwoDays,
          status: DoseStatus.pending,
        ),
      ];

      final progress = MedicationCourseProgress.calculate(
        prescription: tRxVitaminE,
        doseRecords: records,
      );

      expect(progress.totalScheduled, 5);
      expect(progress.takenCount, 3);
      expect(progress.remainingCount, 2);
      expect(progress.pendingCount, 2);
      expect(progress.skippedCount, 0);
      expect(progress.missedCount, 0);
      expect(progress.startDate, twoDaysAgo);
      expect(progress.endDate, inTwoDays);
      expect(progress.unit, 'capsules');
      expect(progress.isComplete, false);
      expect(progress.isTrackingActive, true);
      expect(progress.completionRatio, closeTo(0.6, 0.001));
    });

    test('distinguishes skipped and missed doses without counting them as taken', () {
      final records = [
        LocalDoseRecordEntity(
          id: 'd1',
          prescriptionItemId: 'rx_vit_e',
          medicationName: 'Vitamin E',
          dose: '400 IU',
          scheduledTime: twoDaysAgo,
          status: DoseStatus.taken,
        ),
        LocalDoseRecordEntity(
          id: 'd2',
          prescriptionItemId: 'rx_vit_e',
          medicationName: 'Vitamin E',
          dose: '400 IU',
          scheduledTime: yesterday,
          status: DoseStatus.skipped,
          skipReason: 'Felt nauseous',
        ),
        LocalDoseRecordEntity(
          id: 'd3',
          prescriptionItemId: 'rx_vit_e',
          medicationName: 'Vitamin E',
          dose: '400 IU',
          scheduledTime: today,
          status: DoseStatus.missed,
        ),
        LocalDoseRecordEntity(
          id: 'd4',
          prescriptionItemId: 'rx_vit_e',
          medicationName: 'Vitamin E',
          dose: '400 IU',
          scheduledTime: tomorrow,
          status: DoseStatus.pending,
        ),
        LocalDoseRecordEntity(
          id: 'd5',
          prescriptionItemId: 'rx_vit_e',
          medicationName: 'Vitamin E',
          dose: '400 IU',
          scheduledTime: inTwoDays,
          status: DoseStatus.pending,
        ),
      ];

      final progress = MedicationCourseProgress.calculate(
        prescription: tRxVitaminE,
        doseRecords: records,
      );

      expect(progress.totalScheduled, 5);
      expect(progress.takenCount, 1);
      expect(progress.skippedCount, 1);
      expect(progress.missedCount, 1);
      expect(progress.pendingCount, 2);
      expect(progress.remainingCount, 2);
    });

    test('marks course complete when all scheduled doses are taken or closed', () {
      final records = [
        LocalDoseRecordEntity(
          id: 'd1',
          prescriptionItemId: 'rx_vit_e',
          medicationName: 'Vitamin E',
          dose: '400 IU',
          scheduledTime: twoDaysAgo,
          status: DoseStatus.taken,
        ),
        LocalDoseRecordEntity(
          id: 'd2',
          prescriptionItemId: 'rx_vit_e',
          medicationName: 'Vitamin E',
          dose: '400 IU',
          scheduledTime: yesterday,
          status: DoseStatus.taken,
        ),
        LocalDoseRecordEntity(
          id: 'd3',
          prescriptionItemId: 'rx_vit_e',
          medicationName: 'Vitamin E',
          dose: '400 IU',
          scheduledTime: today,
          status: DoseStatus.taken,
        ),
        LocalDoseRecordEntity(
          id: 'd4',
          prescriptionItemId: 'rx_vit_e',
          medicationName: 'Vitamin E',
          dose: '400 IU',
          scheduledTime: tomorrow,
          status: DoseStatus.taken,
        ),
        LocalDoseRecordEntity(
          id: 'd5',
          prescriptionItemId: 'rx_vit_e',
          medicationName: 'Vitamin E',
          dose: '400 IU',
          scheduledTime: inTwoDays,
          status: DoseStatus.taken,
        ),
      ];

      final progress = MedicationCourseProgress.calculate(
        prescription: tRxVitaminE,
        doseRecords: records,
      );

      expect(progress.totalScheduled, 5);
      expect(progress.takenCount, 5);
      expect(progress.remainingCount, 0);
      expect(progress.isComplete, true);
    });

    test('computes theoretical progress before dose generation', () {
      final untrackedRx = EncounterPrescriptionItemEntity(
        id: 'rx_untracked',
        medicationName: 'Amoxicillin',
        dose: '500mg',
        route: 'Oral Capsule',
        frequency: 'Take 1 capsule every 8 hours',
        duration: '7 Days (21 capsules total)',
        status: EncounterPrescriptionStatus.active,
        instructions: 'Take with food',
        startedAt: now,
        isTrackingActive: false,
      );

      final progress = MedicationCourseProgress.calculate(
        prescription: untrackedRx,
        doseRecords: const [],
      );

      expect(progress.totalScheduled, 21);
      expect(progress.takenCount, 0);
      expect(progress.remainingCount, 21);
      expect(progress.isTrackingActive, false);
      expect(progress.isComplete, false);
    });
  });
}
