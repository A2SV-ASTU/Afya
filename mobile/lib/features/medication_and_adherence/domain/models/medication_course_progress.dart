import '../../../clinical_history/domain/entities/encounter_detail_entity.dart';
import '../entities/local_dose_record_entity.dart';
import '../services/posology_parser.dart';

/// Encapsulates dynamically calculated progress and adherence statistics
/// for a medication prescription based on its actual dose records.
class MedicationCourseProgress {
  final int totalScheduled;
  final int takenCount;
  final int skippedCount;
  final int missedCount;
  final int pendingCount;
  final int remainingCount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isComplete;
  final bool isTrackingActive;
  final double completionRatio;
  final String unit;

  const MedicationCourseProgress({
    required this.totalScheduled,
    required this.takenCount,
    required this.skippedCount,
    required this.missedCount,
    required this.pendingCount,
    required this.remainingCount,
    required this.startDate,
    required this.endDate,
    required this.isComplete,
    required this.isTrackingActive,
    required this.completionRatio,
    required this.unit,
  });

  factory MedicationCourseProgress.calculate({
    required EncounterPrescriptionItemEntity prescription,
    required List<LocalDoseRecordEntity> doseRecords,
    PosologyParser parser = const PosologyParser(),
  }) {
    final hasRecords = doseRecords.isNotEmpty;

    // 1. Calculate dose counts
    int total;
    int taken = 0;
    int skipped = 0;
    int missed = 0;
    int pending = 0;
    DateTime start;
    DateTime end;

    if (hasRecords) {
      final sorted = List<LocalDoseRecordEntity>.from(doseRecords)
        ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

      total = sorted.length;
      taken = sorted.where((d) => d.status == DoseStatus.taken).length;
      skipped = sorted.where((d) => d.status == DoseStatus.skipped).length;
      missed = sorted.where((d) => d.status == DoseStatus.missed).length;
      pending = sorted.where((d) => d.status == DoseStatus.pending).length;

      start = sorted.first.scheduledTime;
      end = sorted.last.scheduledTime;
    } else {
      // Theoretical calculation before schedule generation
      final slots = parser.parseFrequency(prescription.frequency);
      final days = parser.parseDurationInDays(prescription.duration) ?? 1;
      final dailyCount = (slots != null && slots.isNotEmpty) ? slots.length : 1;

      total = dailyCount * days;
      pending = total;
      start = prescription.startedAt;
      end = prescription.startedAt.add(Duration(days: days > 0 ? days - 1 : 0));
    }

    final remaining = pending;
    final isComplete = total > 0 && remaining == 0 && hasRecords;
    final isTrackingActive = prescription.isTrackingActive || hasRecords;
    final ratio = total > 0 ? (taken / total).clamp(0.0, 1.0) : 0.0;

    // Determine unit name: capsule, tablet, or dose
    final textForUnit = '${prescription.route} ${prescription.instructions ?? ''} ${prescription.dose} ${prescription.frequency}'.toLowerCase();
    String unitName;
    if (textForUnit.contains('capsule')) {
      unitName = total == 1 ? 'capsule' : 'capsules';
    } else if (textForUnit.contains('tablet') || textForUnit.contains('tab')) {
      unitName = total == 1 ? 'tablet' : 'tablets';
    } else {
      unitName = total == 1 ? 'dose' : 'doses';
    }

    return MedicationCourseProgress(
      totalScheduled: total,
      takenCount: taken,
      skippedCount: skipped,
      missedCount: missed,
      pendingCount: pending,
      remainingCount: remaining,
      startDate: start,
      endDate: end,
      isComplete: isComplete,
      isTrackingActive: isTrackingActive,
      completionRatio: ratio,
      unit: unitName,
    );
  }
}
