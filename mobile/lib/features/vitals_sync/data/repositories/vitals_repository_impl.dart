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
    return await remote.getHistory();
  }
}