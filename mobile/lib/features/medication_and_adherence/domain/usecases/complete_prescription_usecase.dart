import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../clinical_history/domain/entities/encounter_detail_entity.dart';
import '../repositories/medication_repository.dart';

@lazySingleton
class CompletePrescriptionUseCase {
  final MedicationRepository repository;

  const CompletePrescriptionUseCase(this.repository);

  Future<Either<Failure, EncounterPrescriptionItemEntity>> call({
    required String prescriptionItemId,
  }) {
    return repository.completePrescriptionItem(
      prescriptionItemId: prescriptionItemId,
    );
  }
}
