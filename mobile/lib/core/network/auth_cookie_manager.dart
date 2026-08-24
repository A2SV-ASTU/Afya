import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthCookieManager {
  static const String _cookieStorageKey = 'afyamind_session_cookies';
  final FlutterSecureStorage _secureStorage;

  final Map<String, String> _cookieJar = <String, String>{};

  AuthCookieManager({required this._secureStorage});

  Future<void> init() async {
    final String? rawCookies = await _secureStorage.read(key: _cookieStorageKey);
    if (rawCookies != null && rawCookies.isNotEmpty) {
      final List<String> cookiePairs = rawCookies.split(';');
      for (final String pair in cookiePairs) {
        final List<String> parts = pair.trim().split('=');
        if (parts.length >= 2) {
          _cookieJar[parts[0]] = parts.sublist(1).join('=');
        }
      }
    }
  }

  String getCookieHeader() {
    if (_cookieJar.isEmpty) return '';
    return _cookieJar.entries
        .map((MapEntry<String, String> e) => '${e.key}=${e.value}')
        .join('; ');
  }

  Future<void> updateFromHeaders(List<String>? setCookieHeaders) async {
    if (setCookieHeaders == null || setCookieHeaders.isEmpty) return;

    for (final String header in setCookieHeaders) {
      final String cookiePart = header.split(';').first.trim();
      final List<String> parts = cookiePart.split('=');
      if (parts.length >= 2) {
        final String key = parts[0].trim();
        final String value = parts.sublist(1).join('=').trim();
        if (value.isEmpty) {
          _cookieJar.remove(key);
        } else {
          _cookieJar[key] = value;
        }
      }
    }
    await _persistCookies();
  }

  Future<void> clearCookies() async {
    _cookieJar.clear();
    await _secureStorage.delete(key: _cookieStorageKey);
  }

  Future<void> _persistCookies() async {
    final String serialized = getCookieHeader();
    await _secureStorage.write(key: _cookieStorageKey, value: serialized);
  }
}
