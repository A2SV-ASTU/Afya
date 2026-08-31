import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/local_dose_record_entity.dart';
import '../repositories/medication_repository.dart';

@lazySingleton
class RecordDoseAdherenceUseCase {
  final MedicationRepository repository;

  const RecordDoseAdherenceUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required LocalDoseRecordEntity doseRecord,
  }) {
    return repository.recordDoseAdherence(
      doseRecord: doseRecord,
    );
  }
}
