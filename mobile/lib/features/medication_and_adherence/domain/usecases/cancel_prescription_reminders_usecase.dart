import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/notifications/local_alarm_scheduler.dart';
import '../../data/datasources/medication_local_data_source.dart';
import '../entities/local_dose_record_entity.dart';

@lazySingleton
class CancelPrescriptionRemindersUseCase {
  final MedicationLocalDataSource _localDataSource;
  final LocalAlarmScheduler _alarmScheduler;

  const CancelPrescriptionRemindersUseCase(
    this._localDataSource,
    this._alarmScheduler,
  );

  Future<Either<Failure, int>> call({
    required String prescriptionItemId,
  }) async {
    try {
      final doseModels = await _localDataSource.getDoseRecords(
        prescriptionItemId: prescriptionItemId,
      );

      var cancelledCount = 0;

      for (final model in doseModels) {
        if (model.status == DoseStatus.pending) {
          final reminderId = model.id.hashCode & 0x7FFFFFFF;
          await _alarmScheduler.cancelReminder(reminderId);
          cancelledCount++;
        }
      }

      return Right(cancelledCount);
    } catch (e) {
      return Left(
        CacheFailure('Failed to cancel prescription reminders: $e'),
      );
    }
  }
}
