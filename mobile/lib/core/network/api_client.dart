import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../constants/api_endpoints.dart';
import '../storage/cookie_storage_service.dart';
import 'auth_cookie_interceptor.dart';
import 'error_interceptor.dart';

class AppCookieInterceptor extends Interceptor {
  final CookieStorageService cookieService;

  AppCookieInterceptor(this.cookieService);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final jar = await cookieService.cookieJar;
    final cookies = await jar.loadForRequest(options.uri);
    final cookieHeader = cookies
        .where((cookie) => cookie.expires == null || cookie.expires!.isAfter(DateTime.now()))
        .map((cookie) => '${cookie.name}=${cookie.value}')
        .join('; ');
    if (cookieHeader.isNotEmpty) {
      options.headers['cookie'] = cookieHeader;
    }
    handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    await _saveCookies(response);
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response != null) {
      await _saveCookies(err.response!);
    }
    handler.next(err);
  }

  Future<void> _saveCookies(Response response) async {
    final setCookieHeaders = response.headers['set-cookie'];
    if (setCookieHeaders != null && setCookieHeaders.isNotEmpty) {
      final jar = await cookieService.cookieJar;
      final cookies = setCookieHeaders
          .map((str) => Cookie.fromSetCookieValue(str))
          .toList();
      await jar.saveFromResponse(response.requestOptions.uri, cookies);
    }
  }
}

@lazySingleton
class ApiClient {
  final Dio dio;
  final CookieStorageService cookieStorageService;

  ApiClient(this.cookieStorageService)
      : dio = Dio(
          BaseOptions(
            baseUrl: ApiEndpoints.baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    dio.interceptors.add(AppCookieInterceptor(cookieStorageService));
    dio.interceptors.add(AuthCookieInterceptor(dio: dio, cookieService: cookieStorageService));
    dio.interceptors.add(ErrorInterceptor());
  }
}
