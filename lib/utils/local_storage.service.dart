import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Storage kunci-nilai berbasis SharedPreferences (mirror mbf-mobile, tapi
/// pakai SharedPreferences karena customer belum punya flutter_secure_storage).
///
/// API sinkron via cache yang diisi sekali dari prefs saat startup
/// (`getPrefs`). Hot path seperti `env()` / `colorEnv()` di-cache hasilnya.
class LocalStorageService {
  LocalStorageService._();

  static SharedPreferences? _prefs;
  static bool _initialized = false;

  // Decoded-JSON caches.
  static Map<String, dynamic>? _appEnvCache;
  static Map<String, dynamic>? _colorEnvCache;

  static SharedPreferences? get prefs => _prefs;

  /// Init sekali di startup sebelum sync access.
  static Future<SharedPreferences> getPrefs() async {
    if (_initialized) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
    return _prefs!;
  }

  static void invalidateEnvCache(String key) {
    if (key == 'appRemoteSettings') _appEnvCache = null;
    if (key == 'colors') _colorEnvCache = null;
  }
}

/// Baca nilai dari blob remote settings server. Map yang sudah di-decode
/// di-cache dan hanya di-parse ulang saat `appRemoteSettings` ditulis.
dynamic env(String key) {
  var map = LocalStorageService._appEnvCache;
  if (map == null) {
    final raw = LocalStorageService._prefs?.getString('appRemoteSettings');
    if (raw == null || raw.isEmpty) return null;
    try {
      map = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      LocalStorageService._appEnvCache = map;
    } catch (_) {
      return null;
    }
  }
  return map[key];
}

Future<bool> saveAppEnv(String jsonString) async {
  LocalStorageService._appEnvCache = null;
  return LocalStorageService._prefs!.setString('appRemoteSettings', jsonString);
}

/// Baca blob warna per-tenant. Di-cache seperti [env].
dynamic colorEnv(String key) {
  var map = LocalStorageService._colorEnvCache;
  if (map == null) {
    final raw = LocalStorageService._prefs?.getString('colors');
    if (raw == null || raw.isEmpty) return '#000000';
    try {
      map = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      LocalStorageService._colorEnvCache = map;
    } catch (_) {
      return '#000000';
    }
  }
  return map[key] ?? '#000000';
}

Future<bool> saveColorEnv(String jsonString) async {
  LocalStorageService._colorEnvCache = null;
  return LocalStorageService._prefs!.setString('colors', jsonString);
}
