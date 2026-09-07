import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/vital_sign_entity.dart';
import '../../domain/entities/vitals_sync_batch_result_entity.dart';
import '../../domain/repositories/vitals_repository.dart';

import '../datasources/vitals_local_data_source.dart';
import '../datasources/vitals_remote_data_source.dart';
import '../models/vital_sign_model.dart';

@LazySingleton(as: VitalsRepository)
class VitalsRepositoryImpl implements VitalsRepository {
  final VitalsLocalDataSource local;
  final VitalsRemoteDataSource remote;

  VitalsRepositoryImpl({
    required this.local,
    required this.remote,
  });

  @override
  Future<void> saveVitalOffline(VitalSignEntity vital) {
    return local.saveVital(
      VitalSignModel(
        clientId: vital.clientId,
        systolicBp: vital.systolicBp,
        diastolicBp: vital.diastolicBp,
        pulse: vital.pulse,
        temperature: vital.temperature,
        spo2: vital.spo2,
        bloodSugar: vital.bloodSugar,
        weight: vital.weight,
        source: vital.source,
        recordedAt: vital.recordedAt,
        synced: vital.synced,
      ),
    );
  }

  @override
  Future<List<VitalSignEntity>> getPendingVitals() async {
    return await local.getPendingVitals();
  }

  @override
  Future<VitalsSyncBatchResultEntity> syncVitals() async {
    final pending = await local.getPendingVitals();

    debugPrint(
      '========== VITAL SYNC DEBUG ==========',
    );

    debugPrint(
      'Pending vitals: ${pending.length}',
    );

    if (pending.isEmpty) {
      debugPrint('Nothing to sync.');

      return const VitalsSyncBatchResultEntity(
        uploaded: 0,
        failed: 0,
        failedIds: [],
      );
    }

    try {
      // Send pending vitals to backend.
      final result = await remote.syncVitals(pending);

      debugPrint(
        'Backend uploaded: ${result.uploaded}',
      );

      debugPrint(
        'Backend failed: ${result.failed}',
      );

      debugPrint(
        'Failed IDs: ${result.failedIds}',
      );

      // IDs that were successfully uploaded.
      final failedIds = result.failedIds.toSet();

      final uploadedIds = pending
          .map((vital) => vital.clientId)
          .where((id) => !failedIds.contains(id))
          .toList();

      // Remove successfully uploaded records from the
      // local outbox.
      if (uploadedIds.isNotEmpty) {
        await local.deleteSyncedVitals(uploadedIds);

        debugPrint(
          'Removed ${uploadedIds.length} synced vitals from Hive.',
        );
      }

      debugPrint(
        '=====================================',
      );

      return result;
    } catch (e) {
      debugPrint(
        'Vital sync failed: $e',
      );

      debugPrint(
        '=====================================',
      );

      rethrow;
    }
  }

  @override
  Future<List<VitalSignEntity>> getHistory() async {
    // Always read local data first.
    List<VitalSignModel> localVitals = [];

    try {
      localVitals = await local.getPendingVitals();

      debugPrint(
        'Local pending vitals count: ${localVitals.length}',
      );
    } catch (e) {
      debugPrint(
        'Failed to read local vitals: $e',
      );
    }

    // Try remote history.
    List<VitalSignModel> remoteVitals = [];

    try {
      remoteVitals = await remote.getHistory();

      debugPrint(
        'Remote history count: ${remoteVitals.length}',
      );
    } catch (e) {
      // Offline is okay. We still return local data.
      debugPrint(
        'Remote history unavailable: $e',
      );
    }

    // Combine remote + local.
    final allVitals = <VitalSignEntity>[
      ...remoteVitals,
      ...localVitals,
    ];

    // Remove duplicates.
    final uniqueVitals = <String, VitalSignEntity>{};

    for (final vital in allVitals) {
      uniqueVitals[vital.clientId] = vital;
    }

    final history = uniqueVitals.values.toList();

    // Newest first.
    history.sort(
      (a, b) => b.recordedAt.compareTo(a.recordedAt),
    );

    debugPrint(
      'Final history count: ${history.length}',
    );

    return history;
  }
}