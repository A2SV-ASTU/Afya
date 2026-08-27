class ServerException implements Exception {
  final String message;
  final String? code;

  const ServerException(this.message, {this.code});
}

class CacheException implements Exception {
  final String message;

  const CacheException(this.message);
}

class ExpiredException implements Exception {
  final String message;

  const ExpiredException(this.message);
}
