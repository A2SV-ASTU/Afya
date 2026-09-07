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
    return local.getPendingVitals();
  }

  @override
  Future<VitalsSyncBatchResultEntity> syncVitals() async {
    final pending = await local.getPendingVitals();

    debugPrint('========== VITAL SYNC DEBUG ==========');
    debugPrint('Pending vitals: ${pending.length}');

    if (pending.isEmpty) {
      debugPrint('Nothing to sync.');

      return const VitalsSyncBatchResultEntity(
        uploaded: 0,
        failed: 0,
        failedIds: [],
      );
    }

    try {
      final result = await remote.syncVitals(pending);

      debugPrint('Backend uploaded: ${result.uploaded}');
      debugPrint('Backend failed: ${result.failed}');
      debugPrint('Failed IDs: ${result.failedIds}');

      final failedIds = result.failedIds.toSet();

      final uploadedIds = pending
          .map((vital) => vital.clientId)
          .where((id) => !failedIds.contains(id))
          .toList();

      if (uploadedIds.isNotEmpty) {
        await local.deleteSyncedVitals(uploadedIds);

        debugPrint(
          'Removed ${uploadedIds.length} synced vitals from Hive.',
        );
      }

      debugPrint('=====================================');

      return result;
    } catch (e) {
      debugPrint('Vital sync failed: $e');
      debugPrint('=====================================');
      rethrow;
    }
  }

  @override
  Future<List<VitalSignEntity>> getHistory() async {
    // Always try to read local data first.
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

    // Try to get the latest history from the backend.
    List<VitalSignModel> remoteVitals = [];

    try {
      remoteVitals = await remote.getHistory();

      debugPrint(
        'Remote history count: ${remoteVitals.length}',
      );
    } catch (e) {
      // Offline is okay. Return the local data.
      debugPrint(
        'Remote history unavailable: $e',
      );
    }

    // Combine remote and local records.
    final allVitals = <VitalSignEntity>[
      ...remoteVitals,
      ...localVitals,
    ];

    // Remove duplicates using clientId.
    final uniqueVitals = <String, VitalSignEntity>{};

    for (final vital in allVitals) {
      uniqueVitals[vital.clientId] = vital;
    }

    final history = uniqueVitals.values.toList();

    // Newest records first.
    history.sort(
      (a, b) => b.recordedAt.compareTo(a.recordedAt),
    );

    debugPrint(
      'Final history count: ${history.length}',
    );

    return history;
  }
}