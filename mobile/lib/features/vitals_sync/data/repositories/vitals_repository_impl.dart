import 'package:injectable/injectable.dart';

import '../../domain/entities/vital_sign_entity.dart';
import '../../domain/entities/vitals_sync_batch_result_entity.dart';
import '../../domain/repositories/vitals_repository.dart';

import '../datasources/vitals_local_data_source.dart';
import '../datasources/vitals_remote_data_source.dart';
import '../models/vital_sign_model.dart';
import 'package:flutter/foundation.dart';

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

    if (pending.isEmpty) {
      return const VitalsSyncBatchResultEntity(
        uploaded: 0,
        failed: 0,
        failedIds: [],
      );
    }

    return await remote.syncVitals(pending);
  }

  @override
Future<List<VitalSignEntity>> getHistory() async {
  final remoteHistory = await remote.getHistory();
  final pendingVitals = await local.getPendingVitals();

  debugPrint('========== VITAL HISTORY DEBUG ==========');
  debugPrint('Remote history count: ${remoteHistory.length}');
  debugPrint('Local pending count: ${pendingVitals.length}');

  for (final vital in remoteHistory) {
    debugPrint(
      'REMOTE -> '
      'id=${vital.clientId}, '
      'BP=${vital.systolicBp}/${vital.diastolicBp}, '
      'pulse=${vital.pulse}, '
      'temp=${vital.temperature}, '
      'weight=${vital.weight}, '
      'recordedAt=${vital.recordedAt}',
    );
  }

  for (final vital in pendingVitals) {
    debugPrint(
      'LOCAL -> '
      'id=${vital.clientId}, '
      'BP=${vital.systolicBp}/${vital.diastolicBp}, '
      'pulse=${vital.pulse}, '
      'temp=${vital.temperature}, '
      'weight=${vital.weight}, '
      'recordedAt=${vital.recordedAt}',
    );
  }

  final allVitals = <VitalSignEntity>[
    ...remoteHistory,
    ...pendingVitals,
  ];

  final uniqueVitals = <String, VitalSignEntity>{};

  for (final vital in allVitals) {
    uniqueVitals[vital.clientId] = vital;
  }

  final history = uniqueVitals.values.toList();

  history.sort(
    (a, b) => b.recordedAt.compareTo(a.recordedAt),
  );

  debugPrint('Final history count: ${history.length}');

  for (final vital in history) {
    debugPrint(
      'FINAL -> '
      'id=${vital.clientId}, '
      'BP=${vital.systolicBp}/${vital.diastolicBp}, '
      'pulse=${vital.pulse}, '
      'temp=${vital.temperature}, '
      'weight=${vital.weight}, '
      'recordedAt=${vital.recordedAt}',
    );
  }

  debugPrint('=========================================');

  return history;
}
}