import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../clinical_history/domain/entities/encounter_detail_entity.dart';
import '../../domain/entities/local_dose_record_entity.dart';
import '../../domain/repositories/medication_repository.dart';
import '../datasources/medication_local_data_source.dart';
import '../datasources/medication_remote_data_source.dart';
import '../models/local_dose_record_model.dart';

@LazySingleton(as: MedicationRepository)
class MedicationRepositoryImpl implements MedicationRepository {
  final MedicationRemoteDataSource remoteDataSource;
  final MedicationLocalDataSource localDataSource;

  MedicationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<EncounterPrescriptionItemEntity>>>
      getPrescriptions({
    required String encounterId,
    bool forceRefresh = false,
  }) async {
    try {
      final models = await remoteDataSource.getPrescriptionsByEncounter(
        encounterId: encounterId,
      );

      await localDataSource.cachePrescriptions(models);

      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on ServerException catch (serverError) {
      try {
        final cached = await localDataSource.getCachedPrescriptions();
        final entities = cached.map((model) => model.toEntity()).toList();
        return Right(entities);
      } on CacheException {
        return Left(
          ServerFailure(
            serverError.message,
            code: serverError.code,
          ),
        );
      }
    } on CacheException catch (error) {
      return Left(
        CacheFailure(error.message),
      );
    }
  }

  @override
  Future<Either<Failure, List<EncounterPrescriptionItemEntity>>>
      getCachedPrescriptions() async {
    try {
      final cached = await localDataSource.getCachedPrescriptions();
      final entities = cached.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on CacheException catch (error) {
      return Left(
        CacheFailure(error.message),
      );
    }
  }

  @override
  Future<Either<Failure, EncounterPrescriptionItemEntity>>
      completePrescriptionItem({
    required String prescriptionItemId,
  }) async {
    try {
      final updatedModel = await remoteDataSource.completePrescription(
        prescriptionItemId: prescriptionItemId,
      );

      await localDataSource.updatePrescriptionStatus(
        prescriptionItemId,
        EncounterPrescriptionStatus.completed,
      );

      return Right(updatedModel.toEntity());
    } on ServerException catch (serverError) {
      return Left(
        ServerFailure(
          serverError.message,
          code: serverError.code,
        ),
      );
    } on CacheException catch (error) {
      return Left(
        CacheFailure(error.message),
      );
    }
  }

  @override
  Future<Either<Failure, void>> recordDoseAdherence({
    required LocalDoseRecordEntity doseRecord,
  }) async {
    try {
      final model = LocalDoseRecordModel.fromEntity(doseRecord);
      await localDataSource.saveDoseRecord(model);
      return const Right(null);
    } on CacheException catch (error) {
      return Left(
        CacheFailure(error.message),
      );
    }
  }

  @override
  Future<Either<Failure, List<LocalDoseRecordEntity>>> getLocalDoseRecords({
    DateTime? forDate,
    String? prescriptionItemId,
  }) async {
    try {
      final models = await localDataSource.getDoseRecords(
        forDate: forDate,
        prescriptionItemId: prescriptionItemId,
      );
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } on CacheException catch (error) {
      return Left(
        CacheFailure(error.message),
      );
    }
  }

  @override
  Future<Either<Failure, LocalDoseRecordEntity?>> getLocalDoseRecordById({
    required String id,
  }) async {
    try {
      final model = await localDataSource.getDoseRecordById(id);
      return Right(model?.toEntity());
    } on CacheException catch (error) {
      return Left(
        CacheFailure(error.message),
      );
    }
  }
}
