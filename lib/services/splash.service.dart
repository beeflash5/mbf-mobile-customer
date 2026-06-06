import 'dart:convert';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:fuodz/component/card/language_selector.view.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/app_currency_system.service.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/firebase.service.dart';
import 'package:fuodz/services/settings.request.dart';
import 'package:fuodz/services/websocket.service.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_routes.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/app_theme.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/utils/utils.dart';

class SplashService {
  static final SettingsRequest _settingsRequest = SettingsRequest();

  static Future<void> loadAppSettings(BuildContext context) async {
    final response = await _settingsRequest.appSettings();
    if (response.body['websocket'] != null) {
      await WebsocketService()
          .saveWebsocketDetails(response.body['websocket']);
    }
    final Map<String, dynamic> appGenSettings = response.body['strings'];
    final pkg = await PackageInfo.fromPlatform();
    appGenSettings['app_name'] = pkg.appName;
    await AppStrings.saveAppSettingsToLocalStorage(jsonEncode(appGenSettings));
    await AppColor.saveColorsToLocalStorage(
      jsonEncode(response.body['colors']),
    );
    if (context.mounted) {
      AdaptiveTheme.of(context).setTheme(
        light: AppTheme().lightTheme(),
        dark: AppTheme().darkTheme(),
        notify: true,
      );
      await AdaptiveTheme.of(context).persist();
    }
    await AppCurrencySystemService().init(response.body['exchange_rates']);
  }

  static Future<void> bootstrap(BuildContext context) async {
    try {
      await loadAppSettings(context);
      if (AuthServices.authenticated()) {
        await AuthServices.getCurrentUser(force: true);
      }
      if (!context.mounted) return;
      await loadNextPage(context);
    } catch (error) {
      if (!context.mounted) return;
      AlertService.error(
        title: 'An error occurred'.tr(),
        text: '$error',
        confirmBtnText: 'Retry'.tr(),
        onConfirm: () => bootstrap(context),
      );
    }
  }

  static Future<void> loadNextPage(BuildContext context) async {
    await Utils.setJiffyLocale();
    if (AuthServices.firstTimeOnApp() && context.mounted) {
      await context.pushWidget(AppLanguageSelector());
      AuthServices.firstTimeCompleted();
    }
    if (!context.mounted) return;
    context.goRoute(AppRoutes.homeRoute);
    final RemoteMessage? initialMessage =
        await FirebaseService().firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      FirebaseService().saveNewNotification(initialMessage);
      FirebaseService().notificationPayloadData = initialMessage.data;
      FirebaseService().selectNotification('');
    }
  }
}
