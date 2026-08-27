import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:injectable/injectable.dart';
import '../constants/api_endpoints.dart';
import '../storage/cookie_storage_service.dart';
import 'auth_cookie_interceptor.dart';
import 'error_interceptor.dart';

@lazySingleton
class ApiClient {
  final Dio dio;
  final CookieStorageService cookieStorageService;

  ApiClient._({
    required this.dio,
    required this.cookieStorageService,
  });

  @factoryMethod
  static Future<ApiClient> create(CookieStorageService cookieStorageService) async {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    final cookieJar = await cookieStorageService.cookieJar;
    dio.interceptors.add(CookieManager(cookieJar));
    dio.interceptors.add(AuthCookieInterceptor(dio: dio, cookieService: cookieStorageService));
    dio.interceptors.add(ErrorInterceptor());

    return ApiClient._(dio: dio, cookieStorageService: cookieStorageService);
  }
}
