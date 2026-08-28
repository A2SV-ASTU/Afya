import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/local_dose_record_entity.dart';
import '../repositories/medication_repository.dart';

@lazySingleton
class GetLocalDoseRecordsUseCase {
  final MedicationRepository repository;

  const GetLocalDoseRecordsUseCase(this.repository);

  Future<Either<Failure, List<LocalDoseRecordEntity>>> call({
    DateTime? forDate,
    String? prescriptionItemId,
  }) {
    return repository.getLocalDoseRecords(
      forDate: forDate,
      prescriptionItemId: prescriptionItemId,
    );
  }

  Future<Either<Failure, LocalDoseRecordEntity?>> getById({
    required String id,
  }) {
    return repository.getLocalDoseRecordById(id: id);
  }
}
