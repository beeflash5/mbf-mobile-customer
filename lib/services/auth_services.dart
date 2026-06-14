import 'dart:convert';

import 'package:fuodz/models/user.dart';
import 'package:fuodz/utils/local_storage.service.dart';

/// Static helper untuk session/auth (token, currentUser, login state).
/// Mirror dari mbf-mobile/services/auth_services.dart, disederhanakan untuk
/// customer (tidak ada Vendor — hanya User).
class AuthServices {
  AuthServices._();

  static const _firstTimeKey = 'firstTimeOnApp';
  static const _authKey = 'authenticated';
  static const _tokenKey = 'auth_token';
  static const _userKey = 'current_user';
  static const _localeKey = 'app_locale';

  // ---- First time ----
  static bool firstTimeOnApp() =>
      LocalStorageService.prefs?.getBool(_firstTimeKey) ?? true;

  static Future<void> firstTimeCompleted() async {
    await LocalStorageService.prefs!.setBool(_firstTimeKey, false);
  }

  // ---- Authenticated flag ----
  static bool authenticated() =>
      LocalStorageService.prefs?.getBool(_authKey) ?? false;

  static Future<bool> isAuthenticated() async {
    final token = await getAuthBearerToken();
    final flag = token.isNotEmpty;
    await LocalStorageService.prefs!.setBool(_authKey, flag);
    return flag;
  }

  // ---- Bearer token ----
  static Future<String> getAuthBearerToken() async {
    return LocalStorageService.prefs?.getString(_tokenKey) ?? '';
  }

  static Future<bool> setAuthBearerToken(String token) =>
      LocalStorageService.prefs!.setString(_tokenKey, token);

  // ---- Locale ----
  static String getLocale() =>
      LocalStorageService.prefs?.getString(_localeKey) ?? 'en';

  static Future<bool> setLocale(String language) =>
      LocalStorageService.prefs!.setString(_localeKey, language);

  // ---- Current user ----
  static User? currentUser;

  static Future<User?> getCurrentUser({bool force = false}) async {
    if (currentUser == null || force) {
      final raw = LocalStorageService.prefs?.getString(_userKey);
      if (raw == null || raw.isEmpty) return null;
      try {
        currentUser = User.fromJson(jsonDecode(raw));
      } catch (_) {
        currentUser = null;
      }
    }
    return currentUser;
  }

  static Future<User?> saveUser(dynamic jsonObject) async {
    if (jsonObject == null) return null;
    await LocalStorageService.prefs!.setString(
      _userKey,
      jsonEncode(jsonObject),
    );
    currentUser = User.fromJson(Map<String, dynamic>.from(jsonObject as Map));
    return currentUser;
  }

  // ---- Logout ----
  static Future<void> logout() async {
    currentUser = null;
    await LocalStorageService.prefs!.remove(_tokenKey);
    await LocalStorageService.prefs!.remove(_userKey);
    await LocalStorageService.prefs!.setBool(_authKey, false);
  }
}
