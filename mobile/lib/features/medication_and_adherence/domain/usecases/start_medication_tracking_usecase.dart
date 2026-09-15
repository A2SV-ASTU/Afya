import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/notifications/local_alarm_scheduler.dart';
import '../../../clinical_history/domain/entities/encounter_detail_entity.dart';
import '../../data/datasources/medication_local_data_source.dart';
import '../../data/models/local_dose_record_model.dart';
import '../entities/local_dose_record_entity.dart';
import 'generate_dose_schedule_usecase.dart';

@lazySingleton
class StartMedicationTrackingUseCase {
  final MedicationLocalDataSource _localDataSource;
  final GenerateDoseScheduleUseCase _generateDoseScheduleUseCase;
  final LocalAlarmScheduler _alarmScheduler;

  const StartMedicationTrackingUseCase(
    this._localDataSource,
    this._generateDoseScheduleUseCase,
    this._alarmScheduler,
  );

  Future<Either<Failure, EncounterPrescriptionItemEntity>> call({
    required EncounterPrescriptionItemEntity prescription,
  }) async {
    try {
      await _localDataSource.updatePrescriptionTracking(prescription.id, true);

      final scheduleResult = await _generateDoseScheduleUseCase(
        prescription: prescription,
      );

      return await scheduleResult.fold(
        (failure) async => Left(failure),
        (doses) async {
          // If in debug mode, adjust the first upcoming pending dose to fire in 20 seconds
          // so real physical notifications can be tested immediately on the device.
          if (kDebugMode && doses.isNotEmpty) {
            final pendingDose =
                doses.where((d) => d.status == DoseStatus.pending).firstOrNull;
            if (pendingDose != null) {
              final testScheduledTime =
                  DateTime.now().add(const Duration(seconds: 20));
              final updatedPendingDose = pendingDose.copyWith(
                scheduledTime: testScheduledTime,
              );
              await _localDataSource.saveDoseRecord(
                LocalDoseRecordModel.fromEntity(updatedPendingDose),
              );

              final reminderId = updatedPendingDose.id.hashCode & 0x7FFFFFFF;
              await _alarmScheduler.scheduleMedicationReminder(
                reminderId: reminderId,
                medicationName: updatedPendingDose.medicationName,
                dosage: updatedPendingDose.dose,
                scheduledTime: testScheduledTime,
                doseId: updatedPendingDose.id,
                prescriptionItemId: updatedPendingDose.prescriptionItemId,
                includeSnooze: true,
              );
            }
          }

          return Right(prescription.copyWith(isTrackingActive: true));
        },
      );
    } catch (e) {
      return Left(
        CacheFailure('Failed to start medication tracking: $e'),
      );
    }
  }
}
