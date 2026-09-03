import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/encounter_entity.dart';
import '../repositories/clinical_history_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetEncountersTimelineUseCase {
  final ClinicalHistoryRepository repository;

  const GetEncountersTimelineUseCase(this.repository);

  Future<Either<Failure, List<EncounterEntity>>> call({
    required String patientId,
    int page = 1,
    int limit = 20,
  }) {
    return repository.getEncountersTimeline(
      patientId: patientId,
      page: page,
      limit: limit,
    );
  }
}
