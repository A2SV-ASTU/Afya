import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_keys.dart';

import '../../../../core/storage/local_database_service.dart';
import '../models/patient_user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUserSession(PatientUserModel user);
  Future<PatientUserModel?> getUserSession();
  Future<void> clearUserSession();

  Future<void> savePin(String pin);
  Future<bool> verifyPin(String pin);
  Future<bool> hasPin();
}

// Hive box key constants (used within the auth_box)
const _kHivePinKey = 'pin';
const _kHiveSessionKey = 'user_session';

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _secureStorage;
  final LocalDatabaseService _localDb;

  AuthLocalDataSourceImpl(this._secureStorage, this._localDb);

  // ── PIN ──────────────────────────────────────────────────────────────────

  @override
  Future<void> savePin(String pin) async {
    final trimmed = pin.trim();
    // Primary: Hive (always works on all Android devices)
    _localDb.getBox(AppKeys.authBox).put(_kHivePinKey, trimmed);
    // Secondary: Secure Storage (best-effort)
    try {
      await _secureStorage.write(key: '${AppKeys.authBox}_pin', value: trimmed);
    } catch (_) {}
  }

  @override
  Future<bool> hasPin() async {
    // 1. Hive is the authoritative source
    final hivePin = _localDb.getBox(AppKeys.authBox).get(_kHivePinKey) as String?;
    if (hivePin != null && hivePin.isNotEmpty) return true;

    // 2. Fallback: SecureStorage
    try {
      final securePin = await _secureStorage.read(key: '${AppKeys.authBox}_pin');
      if (securePin != null && securePin.isNotEmpty) {
        // Migrate to Hive so future reads work
        _localDb.getBox(AppKeys.authBox).put(_kHivePinKey, securePin.trim());
        return true;
      }
    } catch (_) {}

    // 3. Fallback: check session's has_pin flag
    final session = await _getSessionFromHive();
    if (session != null && session.hasPin) return true;

    return false;
  }

  @override
  Future<bool> verifyPin(String pin) async {
    final trimmedInput = pin.trim();

    // 1. Hive first
    final hivePin = _localDb.getBox(AppKeys.authBox).get(_kHivePinKey) as String?;
    if (hivePin != null && hivePin.isNotEmpty) {
      return hivePin == trimmedInput;
    }

    // 2. SecureStorage fallback
    try {
      final securePin = await _secureStorage.read(key: '${AppKeys.authBox}_pin');
      if (securePin != null && securePin.isNotEmpty) {
        // Migrate to Hive
        _localDb.getBox(AppKeys.authBox).put(_kHivePinKey, securePin.trim());
        return securePin.trim() == trimmedInput;
      }
    } catch (_) {}

    return false;
  }

  // ── USER SESSION ─────────────────────────────────────────────────────────

  @override
  Future<void> saveUserSession(PatientUserModel user) async {
    final json = jsonEncode(user.toJson());

    // Primary: Hive
    _localDb.getBox(AppKeys.authBox).put(_kHiveSessionKey, json);

    // Secondary: SecureStorage
    try {
      await _secureStorage.write(key: AppKeys.userSessionKey, value: json);
      await _secureStorage.write(key: AppKeys.userIdKey, value: user.id);
    } catch (_) {}
  }

  @override
  Future<PatientUserModel?> getUserSession() async {
    // 1. Hive first
    final fromHive = await _getSessionFromHive();
    if (fromHive != null) return fromHive;

    // 2. SecureStorage fallback
    try {
      final jsonStr = await _secureStorage.read(key: AppKeys.userSessionKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final data = jsonDecode(jsonStr) as Map<String, dynamic>;
        final pinSet = await hasPin();
        data['has_pin'] = pinSet || (data['has_pin'] == true) || (data['hasPin'] == true);
        final model = PatientUserModel.fromJson(data);
        // Migrate to Hive
        _localDb.getBox(AppKeys.authBox).put(_kHiveSessionKey, jsonStr);
        return model;
      }
    } catch (_) {}

    return null;
  }

  @override
  Future<void> clearUserSession() async {
    // Clear Hive
    await _localDb.getBox(AppKeys.authBox).delete(_kHiveSessionKey);
    await _localDb.getBox(AppKeys.authBox).delete(_kHivePinKey);

    // Clear SecureStorage
    try {
      await _secureStorage.delete(key: AppKeys.userSessionKey);
      await _secureStorage.delete(key: AppKeys.userIdKey);
      await _secureStorage.delete(key: AppKeys.refreshTokenKey);
      await _secureStorage.delete(key: '${AppKeys.authBox}_pin');
    } catch (_) {}
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<PatientUserModel?> _getSessionFromHive() async {
    try {
      final jsonStr = _localDb.getBox(AppKeys.authBox).get(_kHiveSessionKey) as String?;
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final data = jsonDecode(jsonStr) as Map<String, dynamic>;
        // Sync has_pin from Hive pin key
        final hivePin = _localDb.getBox(AppKeys.authBox).get(_kHivePinKey) as String?;
        final pinSet = (hivePin != null && hivePin.isNotEmpty) ||
            (data['has_pin'] == true) ||
            (data['hasPin'] == true);
        data['has_pin'] = pinSet;
        return PatientUserModel.fromJson(data);
      }
    } catch (_) {}
    return null;
  }
}
