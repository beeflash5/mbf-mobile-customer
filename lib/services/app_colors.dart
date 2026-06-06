import 'package:flutter/material.dart';
import 'package:fuodz/utils/local_storage.service.dart';

/// Cache Color hasil parse. `primaryColor`, `accentColor`, status colors,
/// dll. dipanggil banyak kali per build — memoize supaya parse hex tidak
/// diulang. Invalidate lewat [AppColor.invalidateCache] saat warna baru
/// disimpan.
final Map<String, Color> _colorCache = {};

Color _resolveColor(String key) {
  final cached = _colorCache[key];
  if (cached != null) return cached;
  final hex = colorEnv(key).toString();
  final c = _parseHex(hex);
  _colorCache[key] = c;
  return c;
}

Color _parseHex(String input) {
  var hex = input.replaceFirst('#', '').trim();
  if (hex.isEmpty) hex = '000000';
  if (hex.length == 6) hex = 'FF$hex';
  if (hex.length != 8) return const Color(0xFF000000);
  return Color(int.tryParse(hex, radix: 16) ?? 0xFF000000);
}

class AppColor {
  AppColor._();

  static Color get accentColor => _resolveColor('accentColor');
  static Color get primaryColor => _resolveColor('primaryColor');
  static Color get primaryColorDark => _resolveColor('primaryColorDark');
  static Color get cursorColor => accentColor;

  static MaterialColor get primaryMaterialColor =>
      _materialFor('primaryColor', primaryColor);

  static Color get onboarding1Color => _resolveColor('onboarding1Color');
  static Color get onboarding2Color => _resolveColor('onboarding2Color');
  static Color get onboarding3Color => _resolveColor('onboarding3Color');
  static Color get onboardingIndicatorDotColor =>
      _resolveColor('onboardingIndicatorDotColor');
  static Color get onboardingIndicatorActiveDotColor =>
      _resolveColor('onboardingIndicatorActiveDotColor');

  static final Color shimmerBaseColor = Colors.grey.shade300;
  static final Color shimmerHighlightColor = Colors.grey.shade200;

  // Hardcode terang — DIBYPASS oleh InputDecorationTheme di tema (auto dark).
  static final Color inputFillColor = Colors.grey.shade200;
  static final Color iconHintColor = Colors.grey.shade500;

  static Color get openColor => _resolveColor('openColor');
  static Color get closeColor => _resolveColor('closeColor');
  static Color get deliveryColor => _resolveColor('deliveryColor');
  static Color get pickupColor => _resolveColor('pickupColor');
  static Color get ratingColor => _resolveColor('ratingColor');

  static const _statusKeyMap = <String, String>{
    'pending': 'pendingColor',
    'preparing': 'preparingColor',
    'enroute': 'enrouteColor',
    'failed': 'failedColor',
    'cancelled': 'cancelledColor',
    'delivered': 'deliveredColor',
    'successful': 'successfulColor',
  };

  static Color getStatusColor(String status) =>
      _resolveColor(_statusKeyMap[status] ?? 'pendingColor');

  /// Simpan blob warna baru + invalidate cache.
  static Future<bool> saveColorsToLocalStorage(String colorsMap) async {
    _colorCache.clear();
    return saveColorEnv(colorsMap);
  }

  static void invalidateCache() => _colorCache.clear();

  static MaterialColor _materialFor(String key, Color base) {
    final v = base.toARGB32();
    return MaterialColor(v, <int, Color>{
      50: base,
      100: base,
      200: base,
      300: base,
      400: base,
      500: base,
      600: base,
      700: base,
      800: base,
      900: base,
    });
  }
}
