import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/notifications/local_alarm_scheduler.dart';
import '../../data/datasources/medication_local_data_source.dart';
import '../../data/models/local_dose_record_model.dart';
import '../entities/local_dose_record_entity.dart';

@lazySingleton
class ProcessMissedDosesUseCase {
  final MedicationLocalDataSource _localDataSource;
  final LocalAlarmScheduler _alarmScheduler;
  final Duration missedThreshold;
  static const defaultMissedThreshold = Duration(minutes: 30);

  const ProcessMissedDosesUseCase(
    this._localDataSource,
    this._alarmScheduler, {
    this.missedThreshold = defaultMissedThreshold,
  });

  @factoryMethod
  factory ProcessMissedDosesUseCase.create(
    MedicationLocalDataSource localDataSource,
    LocalAlarmScheduler alarmScheduler,
  ) =>
      ProcessMissedDosesUseCase(
        localDataSource,
        alarmScheduler,
      );

  Future<Either<Failure, List<LocalDoseRecordEntity>>> call({
    DateTime? now,
    String? prescriptionItemId,
  }) async {
    try {
      final currentTime = now ?? DateTime.now();
      final allDoseModels = await _localDataSource.getDoseRecords(
        prescriptionItemId: prescriptionItemId,
      );

      final transitionedDoses = <LocalDoseRecordEntity>[];

      for (final model in allDoseModels) {
        final dose = model.toEntity();
        if (dose.status != DoseStatus.pending) {
          continue;
        }

        final deadline = dose.snoozedUntil != null
            ? (dose.snoozedUntil!
                    .isAfter(dose.scheduledTime.add(missedThreshold))
                ? dose.snoozedUntil!.add(const Duration(minutes: 10))
                : dose.scheduledTime.add(missedThreshold))
            : dose.scheduledTime.add(missedThreshold);

        if (currentTime.isAfter(deadline)) {
          final missedDose = dose.copyWith(
            status: DoseStatus.missed,
            recordedAt: currentTime,
          );

          await _localDataSource.saveDoseRecord(
            LocalDoseRecordModel.fromEntity(missedDose),
          );

          final reminderId = dose.id.hashCode & 0x7FFFFFFF;
          await _alarmScheduler.cancelReminder(reminderId);

          transitionedDoses.add(missedDose);
        }
      }

      return Right(transitionedDoses);
    } catch (e) {
      return Left(CacheFailure('Failed to process missed doses: $e'));
    }
  }
}
