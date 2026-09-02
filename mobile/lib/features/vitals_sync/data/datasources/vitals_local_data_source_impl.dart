import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_keys.dart';
import '../models/vital_sign_model.dart';
import 'vitals_local_data_source.dart';

@LazySingleton(as: VitalsLocalDataSource)
class VitalsLocalDataSourceImpl implements VitalsLocalDataSource {
  final Box box;

  VitalsLocalDataSourceImpl([Box? box])
    : box = box ?? Hive.box(AppKeys.vitalsOutboxBox);

  @override
  Future<void> saveVital(VitalSignModel vital) async {
    await box.put(
      vital.clientId,
      vital.toJson(),
    );
    print('Hive saved vital ${vital.clientId}');
  }

  @override
  Future<List<VitalSignModel>> getPendingVitals() async {
    final values = box.values.toList();

    return values
        .map(
          (item) => VitalSignModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .where((vital) => !vital.synced)
        .toList();
  }

  @override
  Future<void> deleteSyncedVitals(List<String> ids) async {
    for (final id in ids) {
      await box.delete(id);
    }
  }

  @override
  Future<int> getPendingCount() async {
    return box.values.where((item) {
      final map = Map<String, dynamic>.from(item as Map);
      return map['synced'] != true;
    }).length;
  }
}