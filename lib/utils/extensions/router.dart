import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Unambiguous go_router navigation helpers. `BuildContext.push` clashes
/// between go_router and velocity_x — use these names everywhere so callsites
/// stay consistent and never hit the extension-conflict analyzer error.
extension RouterContext on BuildContext {
  Future<T?> pushRoute<T extends Object?>(String location, {Object? extra}) =>
      GoRouter.of(this).push<T>(location, extra: extra);

  void goRoute(String location, {Object? extra}) =>
      GoRouter.of(this).go(location, extra: extra);

  void replaceRoute(String location, {Object? extra}) =>
      GoRouter.of(this).replace(location, extra: extra);

  void popRoute<T extends Object?>([T? result]) =>
      GoRouter.of(this).pop(result);

  /// Push a prebuilt widget through go_router's generic `/_w` route.
  /// Used to migrate legacy `Navigator.push(MaterialPageRoute(...))` callsites
  /// without inventing a typed route for every one-off page. For destinations
  /// that have a real route, prefer pushRoute('/specific-path', extra: ...).
  Future<T?> pushWidget<T extends Object?>(Widget widget) =>
      GoRouter.of(this).push<T>('/_w', extra: widget);
}
