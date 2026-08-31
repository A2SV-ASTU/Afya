import 'package:injectable/injectable.dart';

import '../../../clinical_history/domain/entities/encounter_detail_entity.dart';
import '../../data/datasources/medication_local_data_source.dart';
import '../usecases/generate_dose_schedule_usecase.dart';
import '../usecases/process_missed_doses_usecase.dart';

@lazySingleton
class MedicationReconciliationService {
  final ProcessMissedDosesUseCase _processMissedDosesUseCase;
  final GenerateDoseScheduleUseCase _generateDoseScheduleUseCase;
  final MedicationLocalDataSource _localDataSource;

  const MedicationReconciliationService(
    this._processMissedDosesUseCase,
    this._generateDoseScheduleUseCase,
    this._localDataSource,
  );

  /// Performs startup reconciliation:
  /// Step A: Transitions any pending doses past T+30 to missed and cancels their active reminders.
  /// Step B: Reconciles future dose records and alarms for active cached prescriptions.
  Future<void> reconcile({DateTime? now}) async {
    try {
      final currentTime = now ?? DateTime.now();

      // Step A: Process expired pending doses
      await _processMissedDosesUseCase(now: currentTime);

      // Step B: Re-generate and restore alarms for active cached prescriptions
      final cachedModels = await _localDataSource.getCachedPrescriptions();
      for (final model in cachedModels) {
        if (model.status == EncounterPrescriptionStatus.active) {
          final entity = model.toEntity();
          await _generateDoseScheduleUseCase(
            prescription: entity,
            now: currentTime,
          );
        }
      }
    } catch (_) {
      // Safely ignore or log without crashing app bootstrap
    }
  }
}
