import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

@lazySingleton
class CookieStorageService {
  final FlutterSecureStorage secureStorage;
  PersistCookieJar? _cookieJar;

  CookieStorageService(this.secureStorage);

  Future<PersistCookieJar> get cookieJar async {
    if (_cookieJar != null) return _cookieJar!;
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String path = '${appDocDir.path}/.cookies/';
    _cookieJar = PersistCookieJar(
      storage: FileStorage(path),
      ignoreExpires: false,
    );
    return _cookieJar!;
  }

  Future<void> clearCookies() async {
    final jar = await cookieJar;
    await jar.deleteAll();
    await secureStorage.deleteAll();
  }

  Future<void> saveRefreshToken(String token) async {
    await secureStorage.write(key: 'refresh_token', value: token);
  }

  Future<String?> getRefreshToken() async {
    return await secureStorage.read(key: 'refresh_token');
  }
}
