import 'package:afyamind_mobile/core/errors/exceptions.dart';
import 'package:afyamind_mobile/core/errors/failures.dart';
import 'package:afyamind_mobile/core/network/network_info.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/local_dose_schedule_entity.dart';
import '../../domain/entities/prescription_item_entity.dart';
import '../../domain/repositories/medication_adherence_repository.dart';
import '../datasources/adherence_local_data_source.dart';
import '../datasources/prescription_remote_data_source.dart';

@LazySingleton(as: MedicationAdherenceRepository)
class MedicationAdherenceRepositoryImpl
    implements MedicationAdherenceRepository {
  final PrescriptionRemoteDataSource _remoteDataSource;
  final AdherenceLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  MedicationAdherenceRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  @override
  Future<Either<Failure, List<PrescriptionItemEntity>>>
      syncPrescriptionsForEncounter(
    String encounterId,
  ) async {
    final isConnected = await _networkInfo.isConnected;

    if (isConnected) {
      try {
        final remoteItems =
            await _remoteDataSource.getPrescriptionsForEncounter(encounterId);
        await _localDataSource.savePrescriptionItems(remoteItems);

        return Right(remoteItems.map((e) => e.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, code: e.code));
      } on ExpiredException catch (e) {
        return Left(ExpiredFailure(e.message));
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      try {
        final localItems = await _localDataSource.getPrescriptionItems(
            encounterId: encounterId);
        if (localItems.isNotEmpty) {
          return Right(localItems.map((e) => e.toEntity()).toList());
        }
        return const Left(NetworkFailure(
            'No internet connection and no cached prescription data'));
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }

  @override
  Future<Either<Failure, List<PrescriptionItemEntity>>>
      getLocalPrescriptionItems({
    String? encounterId,
  }) async {
    try {
      final localItems =
          await _localDataSource.getPrescriptionItems(encounterId: encounterId);
      return Right(localItems.map((e) => e.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LocalDoseScheduleEntity>>> getLocalDoseSchedules({
    String? prescriptionItemId,
  }) async {
    try {
      final doses = await _localDataSource.getDoseSchedules(
        prescriptionItemId: prescriptionItemId,
      );
      return Right(doses.map((e) => e.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateDoseOutcome({
    required String doseId,
    required DoseOutcome outcome,
    DateTime? loggedAt,
  }) async {
    try {
      // 1. Update local dose outcome (device-local adherence tracking)
      await _localDataSource.updateDoseOutcome(
        doseId,
        outcome,
        loggedAt: loggedAt ?? DateTime.now(),
      );

      // 2. Inspect parent prescription item
      final dose = await _localDataSource.getDoseScheduleById(doseId);
      if (dose != null) {
        final prescription = await _localDataSource.getPrescriptionItemById(
          dose.prescriptionItemId,
        );

        if (prescription != null &&
            prescription.status == PrescriptionItemStatus.active) {
          final allDoses = await _localDataSource.getDoseSchedules(
            prescriptionItemId: prescription.id,
          );

          // Check if all scheduled doses for the prescription have been resolved
          final isFullCourseCompleted = allDoses.isNotEmpty &&
              allDoses.every((d) => d.outcome != DoseOutcome.pending);

          if (isFullCourseCompleted) {
            // Trigger backend completion and update local status
            await _handlePrescriptionCompletion(prescription.id);
          }
        }
      }

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> snoozeDose({
    required String doseId,
    required DateTime snoozeUntil,
  }) async {
    try {
      await _localDataSource.updateDoseSnooze(doseId, snoozeUntil);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> completePrescription(
      String prescriptionId) async {
    try {
      final prescription =
          await _localDataSource.getPrescriptionItemById(prescriptionId);
      if (prescription != null &&
          prescription.status == PrescriptionItemStatus.deactivated) {
        // Prescriptions marked deactivated must not trigger remote completion
        return const Right(null);
      }

      await _handlePrescriptionCompletion(prescriptionId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<void> _handlePrescriptionCompletion(String prescriptionId) async {
    final isConnected = await _networkInfo.isConnected;

    if (isConnected) {
      await _remoteDataSource.completePrescription(prescriptionId);
    }

    await _localDataSource.updatePrescriptionStatus(
      prescriptionId,
      PrescriptionItemStatus.completed,
    );
  }
}
