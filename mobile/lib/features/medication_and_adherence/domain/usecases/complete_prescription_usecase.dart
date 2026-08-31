import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../clinical_history/domain/entities/encounter_detail_entity.dart';
import '../repositories/medication_repository.dart';
import 'cancel_prescription_reminders_usecase.dart';

@lazySingleton
class CompletePrescriptionUseCase {
  final MedicationRepository repository;
  final CancelPrescriptionRemindersUseCase cancelRemindersUseCase;

  const CompletePrescriptionUseCase(
    this.repository,
    this.cancelRemindersUseCase,
  );

  Future<Either<Failure, EncounterPrescriptionItemEntity>> call({
    required String prescriptionItemId,
  }) async {
    final result = await repository.completePrescriptionItem(
      prescriptionItemId: prescriptionItemId,
    );

    return result.fold(
      (failure) => Left(failure),
      (entity) async {
        await cancelRemindersUseCase(
          prescriptionItemId: prescriptionItemId,
        );
        return Right(entity);
      },
    );
  }
}
