import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import '../constants/app_keys.dart';

@lazySingleton
class LocalDatabaseService {
  Future<void> initialize() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox(AppKeys.vitalsOutboxBox),
      Hive.openBox(AppKeys.doctorVitalsCacheBox),
      Hive.openBox(AppKeys.medicationScheduleBox),
      Hive.openBox(AppKeys.adherenceHistoryBox),
      Hive.openBox(AppKeys.clinicalHistoryCacheBox),
    ]);
  }

  Box getBox(String boxName) => Hive.box(boxName);

  Future<void> clearAllBoxes() async {
    await Future.wait([
      Hive.box(AppKeys.vitalsOutboxBox).clear(),
      Hive.box(AppKeys.doctorVitalsCacheBox).clear(),
      Hive.box(AppKeys.medicationScheduleBox).clear(),
      Hive.box(AppKeys.adherenceHistoryBox).clear(),
      Hive.box(AppKeys.clinicalHistoryCacheBox).clear(),
    ]);
  }
}
