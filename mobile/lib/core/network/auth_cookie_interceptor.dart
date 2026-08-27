import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../storage/cookie_storage_service.dart';

class AuthCookieInterceptor extends QueuedInterceptor {
  final Dio dio;
  final CookieStorageService cookieService;

  AuthCookieInterceptor({
    required this.dio,
    required this.cookieService,
  });

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !err.requestOptions.path.contains('/auth/')) {
      final refreshToken = await cookieService.getRefreshToken();

      if (refreshToken == null) {
        await cookieService.clearCookies();
        return handler.next(err);
      }

      try {
        // Dedicated refresh client to prevent interceptor loop
        final refreshDio = Dio(BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          headers: {'Content-Type': 'application/json'},
        ));

        final response = await refreshDio.post(
          ApiEndpoints.refresh,
          data: {'refresh_token': refreshToken},
        );

        if (response.statusCode == 200) {
          // Retry the queued original request
          final retryResponse = await dio.fetch(err.requestOptions);
          return handler.resolve(retryResponse);
        }
      } catch (_) {
        await cookieService.clearCookies();
      }
    }
    handler.next(err);
  }
}
