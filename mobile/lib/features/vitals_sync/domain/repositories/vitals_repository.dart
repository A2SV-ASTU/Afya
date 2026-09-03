import '../entities/vital_sign_entity.dart';
import '../entities/vitals_sync_batch_result_entity.dart';

abstract class VitalsRepository {
  Future<void> saveVitalOffline(VitalSignEntity vital);

  Future<List<VitalSignEntity>> getPendingVitals();

  Future<VitalsSyncBatchResultEntity> syncVitals();

  Future<List<VitalSignEntity>> getHistory();
}