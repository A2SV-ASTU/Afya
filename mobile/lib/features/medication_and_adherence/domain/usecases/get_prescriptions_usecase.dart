import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../clinical_history/domain/entities/encounter_detail_entity.dart';
import '../repositories/medication_repository.dart';
import 'generate_dose_schedule_usecase.dart';

@lazySingleton
class GetPrescriptionsUseCase {
  final MedicationRepository repository;
  final GenerateDoseScheduleUseCase generateScheduleUseCase;

  const GetPrescriptionsUseCase(
    this.repository,
    this.generateScheduleUseCase,
  );

  Future<Either<Failure, List<EncounterPrescriptionItemEntity>>> call({
    required String encounterId,
    bool forceRefresh = false,
    DateTime? now,
  }) async {
    final result = await repository.getPrescriptions(
      encounterId: encounterId,
      forceRefresh: forceRefresh,
    );

    switch (result) {
      case Left(:final value):
        return Left(value);
      case Right(:final value):
        for (final rx in value) {
          if (rx.status == EncounterPrescriptionStatus.active) {
            await generateScheduleUseCase(
              prescription: rx,
              now: now,
            );
          }
        }
        return Right(value);
    }
  }

  Future<Either<Failure, List<EncounterPrescriptionItemEntity>>> getCached() {
    return repository.getCachedPrescriptions();
  }
}
