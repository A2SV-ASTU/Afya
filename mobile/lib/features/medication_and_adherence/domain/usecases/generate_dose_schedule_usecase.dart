import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/notifications/local_alarm_scheduler.dart';
import '../../../clinical_history/domain/entities/encounter_detail_entity.dart';
import '../../data/datasources/medication_local_data_source.dart';
import '../../data/models/local_dose_record_model.dart';
import '../entities/local_dose_record_entity.dart';
import '../services/dose_schedule_generator.dart';

@lazySingleton
class GenerateDoseScheduleUseCase {
  final DoseScheduleGenerator _generator;
  final MedicationLocalDataSource _localDataSource;
  final LocalAlarmScheduler _alarmScheduler;

  const GenerateDoseScheduleUseCase(
    this._localDataSource,
    this._alarmScheduler,
  ) : _generator = const DoseScheduleGenerator();

  const GenerateDoseScheduleUseCase.withGenerator(
    this._localDataSource,
    this._alarmScheduler, {
    required DoseScheduleGenerator generator,
  }) : _generator = generator;

  Future<Either<Failure, List<LocalDoseRecordEntity>>> call({
    required EncounterPrescriptionItemEntity prescription,
    DateTime? now,
  }) async {
    try {
      if (prescription.status != EncounterPrescriptionStatus.active) {
        return const Right([]);
      }

      final generatedDoses = _generator.generate(prescription);
      if (generatedDoses.isEmpty) {
        return const Right([]);
      }

      final currentTime = now ?? DateTime.now();
      final persistedRecords = <LocalDoseRecordEntity>[];

      for (final dose in generatedDoses) {
        final existing = await _localDataSource.getDoseRecordById(dose.id);
        if (existing == null) {
          await _localDataSource.saveDoseRecord(
            LocalDoseRecordModel.fromEntity(dose),
          );
          persistedRecords.add(dose);

          if (dose.scheduledTime.isAfter(currentTime)) {
            final reminderId = dose.id.hashCode & 0x7FFFFFFF;
            await _alarmScheduler.scheduleMedicationReminder(
              reminderId: reminderId,
              medicationName: dose.medicationName,
              dosage: dose.dose,
              scheduledTime: dose.scheduledTime,
              doseId: dose.id,
              prescriptionItemId: dose.prescriptionItemId,
              includeSnooze: true,
            );
          }
        } else {
          persistedRecords.add(existing.toEntity());
        }
      }

      return Right(persistedRecords);
    } catch (e) {
      return Left(
        CacheFailure('Failed to generate and persist dose schedule: $e'),
      );
    }
  }
}
