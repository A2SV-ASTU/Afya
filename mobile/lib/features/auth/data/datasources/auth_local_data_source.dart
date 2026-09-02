import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_keys.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/patient_user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUserSession(PatientUserModel user);
  Future<PatientUserModel?> getUserSession();
  Future<void> clearUserSession();

  Future<void> savePin(String pin);
  Future<bool> verifyPin(String pin);
  Future<bool> hasPin();
}

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _secureStorage;

  static const String _pinKey = 'afya_user_pin';

  AuthLocalDataSourceImpl(this._secureStorage);

  @override
  Future<void> saveUserSession(PatientUserModel user) async {
    try {
      final userJsonStr = jsonEncode(user.toJson());
      await _secureStorage.write(key: AppKeys.userSessionKey, value: userJsonStr);
      await _secureStorage.write(key: AppKeys.userIdKey, value: user.id);
    } catch (e) {
      throw CacheException('Failed to cache user session: $e');
    }
  }

  @override
  Future<PatientUserModel?> getUserSession() async {
    try {
      final jsonStr = await _secureStorage.read(key: AppKeys.userSessionKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(jsonStr);
        final pinSet = await hasPin();
        data['has_pin'] = pinSet;
        return PatientUserModel.fromJson(data);
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to retrieve cached user session: $e');
    }
  }

  @override
  Future<void> clearUserSession() async {
    try {
      await _secureStorage.delete(key: AppKeys.userSessionKey);
      await _secureStorage.delete(key: AppKeys.userIdKey);
      await _secureStorage.delete(key: AppKeys.refreshTokenKey);
      await _secureStorage.delete(key: _pinKey);
    } catch (e) {
      throw CacheException('Failed to clear cached user session: $e');
    }
  }

  @override
  Future<void> savePin(String pin) async {
    try {
      await _secureStorage.write(key: _pinKey, value: pin);
    } catch (e) {
      throw CacheException('Failed to save PIN: $e');
    }
  }

  @override
  Future<bool> verifyPin(String pin) async {
    try {
      final storedPin = await _secureStorage.read(key: _pinKey);
      return storedPin != null && storedPin == pin;
    } catch (e) {
      throw CacheException('Failed to verify PIN: $e');
    }
  }

  @override
  Future<bool> hasPin() async {
    try {
      final pin = await _secureStorage.read(key: _pinKey);
      return pin != null && pin.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
