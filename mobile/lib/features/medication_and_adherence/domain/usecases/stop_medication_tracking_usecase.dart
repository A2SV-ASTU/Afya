import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../clinical_history/domain/entities/encounter_detail_entity.dart';
import '../../data/datasources/medication_local_data_source.dart';
import 'cancel_prescription_reminders_usecase.dart';

@lazySingleton
class StopMedicationTrackingUseCase {
  final MedicationLocalDataSource _localDataSource;
  final CancelPrescriptionRemindersUseCase _cancelPrescriptionRemindersUseCase;

  const StopMedicationTrackingUseCase(
    this._localDataSource,
    this._cancelPrescriptionRemindersUseCase,
  );

  Future<Either<Failure, EncounterPrescriptionItemEntity>> call({
    required EncounterPrescriptionItemEntity prescription,
  }) async {
    try {
      await _localDataSource.updatePrescriptionTracking(prescription.id, false);
      await _cancelPrescriptionRemindersUseCase(
        prescriptionItemId: prescription.id,
      );

      return Right(prescription.copyWith(isTrackingActive: false));
    } catch (e) {
      return Left(
        CacheFailure('Failed to stop medication tracking: $e'),
      );
    }
  }
}
