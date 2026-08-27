import 'package:dio/dio.dart';
import '../errors/exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response != null) {
      final statusCode = err.response?.statusCode;
      final data = err.response?.data;

      String message = 'An unexpected server error occurred';
      String? code;

      if (data is Map<String, dynamic> && data['error'] != null) {
        final errorObj = data['error'];
        if (errorObj is Map<String, dynamic>) {
          message = errorObj['message'] as String? ?? message;
          code = errorObj['code'] as String?;
        }
      }

      if (statusCode == 410) {
        throw ExpiredException(message);
      } else {
        throw ServerException(message, code: code);
      }
    }
    handler.next(err);
  }
}
