import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/appointment_entity.dart';
import '../entities/encounter_detail_entity.dart';
import '../entities/encounter_entity.dart';
import '../entities/medical_history_summary_entity.dart';

abstract class ClinicalHistoryRepository {
  Future<Either<Failure, List<EncounterEntity>>> getEncountersTimeline({
    required String patientId,
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, MedicalHistorySummaryEntity>>
      getCondensedMedicalHistory({
    required String encounterId,
  });

  Future<Either<Failure, EncounterDetailEntity>> getEncounterDetail({
    required String encounterId,
  });

  Future<Either<Failure, List<AppointmentEntity>>> getAppointments({
    required String patientId,
    String? status,
  });
}
