import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/notifications/local_alarm_scheduler.dart';
import '../../data/datasources/medication_local_data_source.dart';
import '../../data/models/local_dose_record_model.dart';
import '../entities/local_dose_record_entity.dart';

@lazySingleton
class HandleSnoozeUseCase {
  final MedicationLocalDataSource _localDataSource;
  final LocalAlarmScheduler _alarmScheduler;

  const HandleSnoozeUseCase(
    this._localDataSource,
    this._alarmScheduler,
  );

  Future<Either<Failure, LocalDoseRecordEntity>> call({
    required String doseId,
  }) async {
    try {
      final model = await _localDataSource.getDoseRecordById(doseId);
      if (model == null) {
        return Left(CacheFailure('Dose record not found: $doseId'));
      }

      final dose = model.toEntity();

      if (dose.status != DoseStatus.pending) {
        return Left(
          CacheFailure('Cannot snooze dose with status: ${dose.status.name}'),
        );
      }

      if (dose.snoozeCount >= 2) {
        return const Left(
          CacheFailure('Maximum snooze limit reached (2 snoozes maximum)'),
        );
      }

      final int newSnoozeCount = dose.snoozeCount + 1;
      final int offsetMinutes = newSnoozeCount == 1 ? 10 : 20;
      final DateTime newSnoozedUntil =
          dose.scheduledTime.add(Duration(minutes: offsetMinutes));
      final bool canSnoozeAgain = newSnoozeCount < 2;

      final updatedDose = dose.copyWith(
        snoozeCount: newSnoozeCount,
        snoozedUntil: newSnoozedUntil,
      );

      await _localDataSource.saveDoseRecord(
        LocalDoseRecordModel.fromEntity(updatedDose),
      );

      final reminderId = dose.id.hashCode & 0x7FFFFFFF;
      await _alarmScheduler.scheduleSnoozeReminder(
        reminderId: reminderId,
        medicationName: dose.medicationName,
        snoozeTime: newSnoozedUntil,
        doseId: dose.id,
        prescriptionItemId: dose.prescriptionItemId,
        includeSnooze: canSnoozeAgain,
      );

      return Right(updatedDose);
    } catch (e) {
      return Left(CacheFailure('Failed to handle snooze: $e'));
    }
  }
}
