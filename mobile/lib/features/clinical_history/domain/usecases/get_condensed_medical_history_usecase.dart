import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/medical_history_summary_entity.dart';
import '../repositories/clinical_history_repository.dart';

class GetCondensedMedicalHistoryUseCase {
  final ClinicalHistoryRepository repository;

  const GetCondensedMedicalHistoryUseCase(this.repository);

  Future<Either<Failure, MedicalHistorySummaryEntity>> call({
    required String encounterId,
  }) {
    return repository.getCondensedMedicalHistory(
      encounterId: encounterId,
    );
  }
}
