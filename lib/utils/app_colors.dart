import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/services/local_storage.service.dart';
import 'package:velocity_x/velocity_x.dart';

class AppColor {
  static Color get accentColor => Vx.hexToColor(colorEnv('accentColor'));
  static Color get primaryColor => Vx.hexToColor(colorEnv('primaryColor'));
  static Color get primaryColorDark =>
      Vx.hexToColor(colorEnv('primaryColorDark'));
  static Color get cursorColor => accentColor;

  //material color
  static MaterialColor get accentMaterialColor =>
      MaterialColor(Vx.getColorFromHex(colorEnv('accentColor')), <int, Color>{
        50: Vx.hexToColor(colorEnv('accentColor')),
        100: Vx.hexToColor(colorEnv('accentColor')),
        200: Vx.hexToColor(colorEnv('accentColor')),
        300: Vx.hexToColor(colorEnv('accentColor')),
        400: Vx.hexToColor(colorEnv('accentColor')),
        500: Vx.hexToColor(colorEnv('accentColor')),
        600: Vx.hexToColor(colorEnv('accentColor')),
        700: Vx.hexToColor(colorEnv('accentColor')),
        800: Vx.hexToColor(colorEnv('accentColor')),
        900: Vx.hexToColor(colorEnv('accentColor')),
      });
  static MaterialColor get primaryMaterialColor =>
      MaterialColor(Vx.getColorFromHex(colorEnv('primaryColor')), <int, Color>{
        50: Vx.hexToColor(colorEnv('primaryColor')),
        100: Vx.hexToColor(colorEnv('primaryColor')),
        200: Vx.hexToColor(colorEnv('primaryColor')),
        300: Vx.hexToColor(colorEnv('primaryColor')),
        400: Vx.hexToColor(colorEnv('primaryColor')),
        500: Vx.hexToColor(colorEnv('primaryColor')),
        600: Vx.hexToColor(colorEnv('primaryColor')),
        700: Vx.hexToColor(colorEnv('primaryColor')),
        800: Vx.hexToColor(colorEnv('primaryColor')),
        900: Vx.hexToColor(colorEnv('primaryColor')),
      });
  static Color get primaryMaterialColorDark =>
      Vx.hexToColor(colorEnv('primaryColorDark'));
  static Color get cursorMaterialColor => accentColor;

  //onboarding colors
  static Color get onboarding1Color =>
      Vx.hexToColor(colorEnv('onboarding1Color'));
  static Color get onboarding2Color =>
      Vx.hexToColor(colorEnv('onboarding2Color'));
  static Color get onboarding3Color =>
      Vx.hexToColor(colorEnv('onboarding3Color'));

  static Color get onboardingIndicatorDotColor =>
      Vx.hexToColor(colorEnv('onboardingIndicatorDotColor'));
  static Color get onboardingIndicatorActiveDotColor =>
      Vx.hexToColor(colorEnv('onboardingIndicatorActiveDotColor'));

  //Shimmer Colors
  static Color shimmerBaseColor = Colors.grey.shade300;
  static Color shimmerHighlightColor = Colors.grey.shade200;

  //inputs
  static Color get inputFillColor => Colors.grey[200]!;
  static Color get iconHintColor => Colors.grey[500]!;

  static Color get openColor => Vx.hexToColor(colorEnv('openColor'));
  static Color get closeColor => Vx.hexToColor(colorEnv('closeColor'));
  static Color get deliveryColor => Vx.hexToColor(colorEnv('deliveryColor'));
  static Color get pickupColor => Vx.hexToColor(colorEnv('pickupColor'));
  static Color get ratingColor => Vx.hexToColor(colorEnv('ratingColor'));

  //
  static Color get faintBgColor {
    try {
      final isLightMode =
          AppService().navigatorKey.currentContext?.brightness ==
          Brightness.light;
      return isLightMode ? Vx.hexToColor("#FFFFFF") : Vx.hexToColor("#212121");
    } catch (error) {
      return Colors.white;
    }
  }

  static Color getStausColor(String status) {
    //'pending','preparing','enroute','failed','cancelled','delivered'
    String lookupStatus = status;
    if (status == "completed") {
      lookupStatus = "delivered";
    }
    final statusColorName = "${lookupStatus}Color";
    try {
      return Vx.hexToColor(colorEnv(statusColorName));
    } catch (error) {
      return Vx.hexToColor(colorEnv('pendingColor'));
    }
  }

  //saving
  static Future<bool> saveColorsToLocalStorage(String colorsMap) async {
    return await LocalStorageService.prefs!.setString(
      AppStrings.appColors,
      colorsMap,
    );
  }

  static dynamic appColorsObject;
  static Future<void> getColorsFromLocalStorage() async {
    appColorsObject = LocalStorageService.prefs!.getString(
      AppStrings.appColors,
    );
    if (appColorsObject != null) {
      appColorsObject = jsonDecode(appColorsObject);
    }
  }

  static String colorEnv(String colorRef) {
    //
    getColorsFromLocalStorage();
    //
    // appColorsObject can be a Map (real theme), a List (backend sent "[]" for
    // an unconfigured theme) or null. Only a Map is safe to index with a string
    // key — anything else would throw, so fall back to the brand defaults.
    String? selectedColor;
    if (appColorsObject is Map) {
      final value = (appColorsObject as Map)[colorRef];
      if (value is String && value.isNotEmpty) {
        selectedColor = value;
      }
    }
    return selectedColor ?? _defaultColor(colorRef);
  }

  /// Brand palette used when the remote theme is missing/blank so the app never
  /// renders all-black (and never crashes reading a non-map theme).
  static String _defaultColor(String colorRef) {
    const defaults = {
      'primaryColor': '#045d78',
      'primaryColorDark': '#03495e',
      'accentColor': '#449db8',
      'openColor': '#42A5F5',
      'closeColor': '#EF5350',
      'deliveryColor': '#66BB6A',
      'pickupColor': '#FFA726',
      'pendingColor': '#FFA726',
      'ratingColor': '#FFC107',
      'onboarding1Color': '#045d78',
      'onboarding2Color': '#166480',
      'onboarding3Color': '#449db8',
      'onboardingIndicatorActiveDotColor': '#045d78',
      'onboardingIndicatorDotColor': '#CBD5E1',
    };
    return defaults[colorRef] ?? '#045d78';
  }
}
