import '../../../clinical_history/domain/entities/encounter_detail_entity.dart';
import '../entities/local_dose_record_entity.dart';
import 'posology_parser.dart';

class DoseScheduleGenerator {
  final PosologyParser parser;

  const DoseScheduleGenerator({
    this.parser = const PosologyParser(),
  });

  List<LocalDoseRecordEntity> generate(
    EncounterPrescriptionItemEntity prescription,
  ) {
    if (prescription.status != EncounterPrescriptionStatus.active) {
      return const [];
    }

    final dailySlots = parser.parseFrequency(prescription.frequency);
    if (dailySlots == null || dailySlots.isEmpty) {
      return const [];
    }

    final totalDays = parser.parseDurationInDays(prescription.duration);
    if (totalDays == null || totalDays <= 0) {
      return const [];
    }

    final startedAt = prescription.startedAt;
    final records = <LocalDoseRecordEntity>[];

    for (var dayOffset = 0; dayOffset < totalDays; dayOffset++) {
      final calendarDate = DateTime(
        startedAt.year,
        startedAt.month,
        startedAt.day + dayOffset,
      );

      for (final slot in dailySlots) {
        final scheduledTime = DateTime(
          calendarDate.year,
          calendarDate.month,
          calendarDate.day,
          slot.hour,
          slot.minute,
        );

        final id = '${prescription.id}_${scheduledTime.millisecondsSinceEpoch}';

        records.add(
          LocalDoseRecordEntity(
            id: id,
            prescriptionItemId: prescription.id,
            medicationName: prescription.medicationName,
            dose: prescription.dose,
            scheduledTime: scheduledTime,
            status: DoseStatus.pending,
            snoozeCount: 0,
          ),
        );
      }
    }

    records.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    return records;
  }
}
