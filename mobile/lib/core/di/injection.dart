import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // -------------------------------------------------------------
  // Core Infrastructure (Dio, CookieManager, SecureStorage, Hive)
  // Registered in AFYA-CORE-02
  // -------------------------------------------------------------

  // -------------------------------------------------------------
  // Feature Slices will be registered by their respective owners
  // sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(...));
  // -------------------------------------------------------------
}
