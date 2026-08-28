import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/entities/encounter_detail_entity.dart';
import '../../domain/entities/encounter_entity.dart';
import '../../domain/entities/medical_history_summary_entity.dart';
import '../../domain/repositories/clinical_history_repository.dart';
import '../datasources/clinical_history_local_data_source.dart';
import '../datasources/clinical_history_remote_data_source.dart';

@LazySingleton(as: ClinicalHistoryRepository)
class ClinicalHistoryRepositoryImpl implements ClinicalHistoryRepository {
  final ClinicalHistoryRemoteDataSource remoteDataSource;
  final ClinicalHistoryLocalDataSource localDataSource;

  ClinicalHistoryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<EncounterEntity>>> getEncountersTimeline({
    required String patientId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final models = await remoteDataSource.getEncountersTimeline(
        patientId: patientId,
        page: page,
        limit: limit,
      );

      await localDataSource.cacheEncounters(
        patientId,
        models,
      );

      final entities = models.map((model) => model.toEntity()).toList()
        ..sort(
          (a, b) => b.startedAt.compareTo(a.startedAt),
        );

      return Right(entities);
    } on ServerException catch (serverError) {
      try {
        final cached = await localDataSource.getCachedEncounters(
          patientId,
        );

        final entities = cached.map((model) => model.toEntity()).toList()
          ..sort(
            (a, b) => b.startedAt.compareTo(a.startedAt),
          );

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
  Future<Either<Failure, MedicalHistorySummaryEntity>>
      getCondensedMedicalHistory({
    required String encounterId,
  }) async {
    try {
      final model = await remoteDataSource.getCondensedMedicalHistory(
        encounterId: encounterId,
      );

      await localDataSource.cacheMedicalHistory(model);

      return Right(model.toEntity());
    } on ServerException catch (serverError) {
      try {
        final cached = await localDataSource.getCachedMedicalHistory(
          encounterId,
        );

        return Right(cached.toEntity());
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
  Future<Either<Failure, EncounterDetailEntity>> getEncounterDetail({
    required String encounterId,
  }) async {
    try {
      final detail = await remoteDataSource.getEncounterDetail(
        encounterId: encounterId,
      );

      final evaluation = await remoteDataSource.getClinicalEvaluation(
        encounterId: encounterId,
      );

      await localDataSource.cacheEncounterDetail(
        encounterId,
        detail,
        evaluation,
      );

      return Right(
        detail.toEntity(
          clinicalEvaluation: evaluation?.toEntity(),
        ),
      );
    } on ServerException catch (serverError) {
      try {
        final cached = await localDataSource.getCachedEncounterDetail(
          encounterId,
        );

        return Right(
          cached.detail.toEntity(
            clinicalEvaluation: cached.clinicalEvaluation?.toEntity(),
          ),
        );
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
  Future<Either<Failure, List<AppointmentEntity>>> getAppointments({
    required String patientId,
    String? status,
  }) async {
    try {
      final models = await remoteDataSource.getAppointments(
        patientId: patientId,
        status: status,
      );

      await localDataSource.cacheAppointments(
        patientId,
        models,
      );

      final entities = models.map((model) => model.toEntity()).toList()
        ..sort(
          (a, b) => a.scheduledAt.compareTo(b.scheduledAt),
        );

      return Right(entities);
    } on ServerException catch (serverError) {
      try {
        final cached = await localDataSource.getCachedAppointments(
          patientId,
        );

        final entities = cached.map((model) => model.toEntity()).toList()
          ..sort(
            (a, b) => a.scheduledAt.compareTo(b.scheduledAt),
          );

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
}
