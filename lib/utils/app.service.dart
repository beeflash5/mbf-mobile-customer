import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:singleton/singleton.dart';

/// Akses global tanpa BuildContext: navigator key, stream index home, dll.
/// Mirror dari mbf-mobile/utils/app.service.dart.
class AppService {
  factory AppService() => Singleton.lazy(() => AppService._());
  AppService._();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final BehaviorSubject<int> homePageIndex = BehaviorSubject<int>();
  final BehaviorSubject<bool> notifVerification = BehaviorSubject<bool>();

  void changeHomePageIndex({int index = 2}) {
    homePageIndex.add(index);
  }
}
