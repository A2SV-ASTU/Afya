import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import '../constants/app_keys.dart';

@lazySingleton
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: AppKeys.refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppKeys.refreshTokenKey);
  }

  Future<void> saveUserId(String userId) async {
    await _storage.write(key: AppKeys.userIdKey, value: userId);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: AppKeys.userIdKey);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
