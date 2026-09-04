import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../../core/constants/app_keys.dart';

@module
abstract class VitalsModule {
  @lazySingleton
  Box get vitalsBox => Hive.box(AppKeys.vitalsOutboxBox);
}