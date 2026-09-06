import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../clinical_history/domain/entities/encounter_detail_entity.dart';
import '../entities/local_dose_record_entity.dart';

abstract class MedicationRepository {
  Future<Either<Failure, List<EncounterPrescriptionItemEntity>>>
      getPrescriptions({
    required String encounterId,
    bool forceRefresh = false,
  });

  Future<Either<Failure, List<EncounterPrescriptionItemEntity>>>
      getCachedPrescriptions();

  Future<Either<Failure, EncounterPrescriptionItemEntity>>
      completePrescriptionItem({
    required String prescriptionItemId,
    String? prescriptionId,
  });

  Future<Either<Failure, void>> recordDoseAdherence({
    required LocalDoseRecordEntity doseRecord,
  });

  Future<Either<Failure, List<LocalDoseRecordEntity>>> getLocalDoseRecords({
    DateTime? forDate,
    String? prescriptionItemId,
  });

  Future<Either<Failure, LocalDoseRecordEntity?>> getLocalDoseRecordById({
    required String id,
  });
}
