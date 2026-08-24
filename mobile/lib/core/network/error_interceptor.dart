import 'package:dio/dio.dart';
import 'package:mobile/core/error/exceptions.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/core/network/auth_cookie_manager.dart';

class AuthInterceptor extends QueuedInterceptor {
  final Dio _dio;
  final AuthCookieManager _cookieManager;

  AuthInterceptor({
    required this._dio,
    required this._cookieManager,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final String cookies = _cookieManager.getCookieHeader();
    if (cookies.isNotEmpty) {
      options.headers['Cookie'] = cookies;
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    final List<String>? setCookieHeaders =
        response.headers['set-cookie'] ?? response.headers['Set-Cookie'];
    await _cookieManager.updateFromHeaders(setCookieHeaders);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final Response<dynamic>? response = err.response;

    // Handle 401 Unauthorized for endpoints that are not public or refresh itself
    final bool isAuthRoute = err.requestOptions.path.contains('/auth/');
    if (response?.statusCode == 401 && !isAuthRoute) {
      try {
        final bool refreshed = await _refreshToken();
        if (refreshed) {
          final RequestOptions requestOptions = err.requestOptions;
          requestOptions.headers['Cookie'] = _cookieManager.getCookieHeader();
          final Response<dynamic> cloneReq = await _dio.fetch(requestOptions);
          return handler.resolve(cloneReq);
        }
      } on DioException catch (refreshErr) {
        await _cookieManager.clearCookies();
        return handler.reject(refreshErr);
      }
    }

    // Convert standard AfyaMind JSON errors
    if (response?.data is Map<String, dynamic>) {
      final Map<String, dynamic> data = response!.data as Map<String, dynamic>;
      if (data.containsKey('error') && data['error'] is Map<String, dynamic>) {
        final Map<String, dynamic> errBody =
            data['error'] as Map<String, dynamic>;
        final String message =
            (errBody['message'] as String?) ?? 'An unexpected error occurred.';
        final String? code = errBody['code'] as String?;

        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            response: response,
            error: ServerException(
              message: message,
              code: code,
              statusCode: response.statusCode,
            ),
          ),
        );
      }
    }

    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    final Dio refreshDio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        headers: <String, dynamic>{
          'Cookie': _cookieManager.getCookieHeader(),
        },
      ),
    );

    final Response<dynamic> refreshResponse =
        await refreshDio.post(ApiEndpoints.refresh);

    final List<String>? setCookieHeaders =
        refreshResponse.headers['set-cookie'] ??
            refreshResponse.headers['Set-Cookie'];
    await _cookieManager.updateFromHeaders(setCookieHeaders);

    return refreshResponse.statusCode == 200;
  }
}
