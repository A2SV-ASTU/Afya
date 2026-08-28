import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../clinical_history/domain/entities/encounter_detail_entity.dart';
import '../repositories/medication_repository.dart';

@lazySingleton
class GetPrescriptionsUseCase {
  final MedicationRepository repository;

  const GetPrescriptionsUseCase(this.repository);

  Future<Either<Failure, List<EncounterPrescriptionItemEntity>>> call({
    required String encounterId,
    bool forceRefresh = false,
  }) {
    return repository.getPrescriptions(
      encounterId: encounterId,
      forceRefresh: forceRefresh,
    );
  }

  Future<Either<Failure, List<EncounterPrescriptionItemEntity>>> getCached() {
    return repository.getCachedPrescriptions();
  }
}
