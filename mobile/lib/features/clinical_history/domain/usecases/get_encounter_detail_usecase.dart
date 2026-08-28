import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/encounter_detail_entity.dart';
import '../repositories/clinical_history_repository.dart';

class GetEncounterDetailUseCase {
  final ClinicalHistoryRepository repository;

  const GetEncounterDetailUseCase(this.repository);

  Future<Either<Failure, EncounterDetailEntity>> call({
    required String encounterId,
  }) {
    return repository.getEncounterDetail(
      encounterId: encounterId,
    );
  }
}
