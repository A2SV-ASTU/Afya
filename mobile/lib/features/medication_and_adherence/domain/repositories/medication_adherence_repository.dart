import 'package:afyamind_mobile/core/errors/failures.dart';
import 'package:fpdart/fpdart.dart';
import '../entities/local_dose_schedule_entity.dart';
import '../entities/prescription_item_entity.dart';

abstract class MedicationAdherenceRepository {
  /// Synchronizes prescriptions for an encounter from the remote backend and persists them locally.
  Future<Either<Failure, List<PrescriptionItemEntity>>>
      syncPrescriptionsForEncounter(String encounterId);

  /// Retrieves locally cached prescription items, optionally filtered by encounter ID.
  Future<Either<Failure, List<PrescriptionItemEntity>>>
      getLocalPrescriptionItems({String? encounterId});

  /// Retrieves locally stored dose schedules, optionally filtered by prescription item ID.
  Future<Either<Failure, List<LocalDoseScheduleEntity>>> getLocalDoseSchedules(
      {String? prescriptionItemId});

  /// Records a local dose outcome (taken, missed, skipped) and checks if the full prescription course has resolved.
  Future<Either<Failure, void>> updateDoseOutcome({
    required String doseId,
    required DoseOutcome outcome,
    DateTime? loggedAt,
  });

  /// Updates local snooze information for a scheduled dose.
  Future<Either<Failure, void>> snoozeDose({
    required String doseId,
    required DateTime snoozeUntil,
  });

  /// Synchronizes completion of a prescription with the backend when the course has fully concluded.
  Future<Either<Failure, void>> completePrescription(String prescriptionId);
}
