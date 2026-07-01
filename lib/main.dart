import 'dart:async';
import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import 'package:fuodz/routes/app_router.dart';
import 'package:fuodz/services/app_colors.dart';
import 'package:fuodz/utils/app_languages.dart';
import 'package:fuodz/utils/local_storage.service.dart';
import 'package:fuodz/services/local_storage.service.dart' as old_ls;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// SSL handshake override (allow self-signed certs).
class _MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

void main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      const env = String.fromEnvironment("ENV", defaultValue: "dev");

      await dotenv.load(fileName: ".env.$env");

      print("Current ENV: $env");
      print("API URL: ${dotenv.env["API_BASE_URL"]}");
      print("WEB URL: ${dotenv.env["WEB_BASE_URL"]}");

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      await Firebase.initializeApp();
      await translator.init(
        localeType: LocalizationDefaultType.asDefined,
        languagesList: AppLanguages.codes,
        assetsDirectory: 'assets/lang/',
      );

      await LocalStorageService.getPrefs();
      await old_ls.LocalStorageService.getPrefs();

      HttpOverrides.global = _MyHttpOverrides();
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

      runApp(ProviderScope(child: LocalizedApp(child: const _MyApp())));
    },
    (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    },
  );
}

class _MyApp extends StatelessWidget {
  const _MyApp();

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: _appLightTheme(),
      dark: _appDarkTheme(),
      initial: AdaptiveThemeMode.system,
      builder: (theme, darkTheme) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: (env('app_name') ?? 'MBF Customer').toString(),
          routerConfig: AppRouter.router,
          localizationsDelegates: translator.delegates,
          locale: translator.activeLocale,
          supportedLocales: translator.locals(),
          theme: theme,
          darkTheme: darkTheme,
        );
      },
    );
  }
}

// =============================================================================
// THEME — light/dark dengan ColorScheme + Scaffold/AppBar/Input/Card/Dialog
// LENGKAP supaya tidak tabrakan di mode gelap. Warna brand (primary, accent,
// primaryColorDark) tetap dari ENV via AppColor.
// =============================================================================
ThemeData _appLightTheme() {
  final brand = AppColor.primaryColor;
  final accent = AppColor.accentColor;
  final inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide.none,
  );
  return ThemeData(
    brightness: Brightness.light,
    useMaterial3: false,
    fontFamily: GoogleFonts.roboto().fontFamily,
    primaryColor: brand,
    primaryColorDark: AppColor.primaryColorDark,
    scaffoldBackgroundColor: Colors.white,
    canvasColor: Colors.white,
    cardColor: Colors.white,
    dividerColor: Colors.black12,
    highlightColor: Colors.grey[200],
    iconTheme: const IconThemeData(color: Color(0xFF424242)),
    textTheme: _blackTextTheme,
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: Colors.grey.shade400,
      cursorColor: AppColor.cursorColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.white),
    dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
    cardTheme: const CardThemeData(color: Colors.white, elevation: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade200,
      labelStyle: TextStyle(color: Colors.grey.shade700),
      hintStyle: TextStyle(color: Colors.grey.shade500),
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: inputBorder.copyWith(
        borderSide: BorderSide(color: accent, width: 1.2),
      ),
    ),
    colorScheme: ColorScheme.light(
      primary: brand,
      secondary: accent,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black,
    ),
  );
}

ThemeData _appDarkTheme() {
  final brand = AppColor.primaryColor;
  final accent = AppColor.accentColor;
  const scaffoldBg = Color(0xFF121212);
  const surface = Color(0xFF1E1E1E);
  const fieldFill = Color(0xFF2A2A2A);
  final inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide.none,
  );
  return ThemeData(
    brightness: Brightness.dark,
    useMaterial3: false,
    fontFamily: GoogleFonts.roboto().fontFamily,
    primaryColor: brand,
    primaryColorDark: AppColor.primaryColorDark,
    scaffoldBackgroundColor: scaffoldBg,
    canvasColor: scaffoldBg,
    cardColor: surface,
    dividerColor: Colors.white12,
    highlightColor: Colors.white12,
    iconTheme: const IconThemeData(color: Colors.white70),
    textTheme: _whiteTextTheme,
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: brand.withValues(alpha: 0.4),
      cursorColor: AppColor.cursorColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      foregroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: surface),
    dialogTheme: const DialogThemeData(backgroundColor: surface),
    cardTheme: const CardThemeData(color: surface, elevation: 0),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: fieldFill,
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white54),
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: inputBorder.copyWith(
        borderSide: BorderSide(color: accent, width: 1.2),
      ),
    ),
    colorScheme: ColorScheme.dark(
      primary: brand,
      secondary: accent,
      surface: surface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
    ),
  );
}

const TextTheme _blackTextTheme = TextTheme(
  bodyLarge: TextStyle(color: Colors.black),
  bodyMedium: TextStyle(color: Colors.black),
  bodySmall: TextStyle(color: Colors.black),
  titleLarge: TextStyle(color: Colors.black),
  titleMedium: TextStyle(color: Colors.black),
  titleSmall: TextStyle(color: Colors.black),
);

const TextTheme _whiteTextTheme = TextTheme(
  bodyLarge: TextStyle(color: Colors.white),
  bodyMedium: TextStyle(color: Colors.white),
  bodySmall: TextStyle(color: Colors.white),
  titleLarge: TextStyle(color: Colors.white),
  titleMedium: TextStyle(color: Colors.white),
  titleSmall: TextStyle(color: Colors.white),
);
