import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/auth_cookie_manager.dart';

final GetIt sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // Storage
  const FlutterSecureStorage secureStorage = FlutterSecureStorage();
  sl.registerLazySingleton<FlutterSecureStorage>(() => secureStorage);

  // Auth Cookie Manager
  final AuthCookieManager cookieManager =
      AuthCookieManager(secureStorage: sl<FlutterSecureStorage>());
  await cookieManager.init();
  sl.registerLazySingleton<AuthCookieManager>(() => cookieManager);

  // Dio & API Client
  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      dio: sl<Dio>(),
      cookieManager: sl<AuthCookieManager>(),
    ),
  );
}
