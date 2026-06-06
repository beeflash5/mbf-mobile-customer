import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/models/apple_login_data.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/pages/deep_link_loading.page.dart';
import 'package:singleton/singleton.dart';

class DeepLinkService {
  // Deep link constants
  static const String _customScheme = 'glover';
  static const String _httpsHost = 'glover.edentech.online';

  /// Factory method that reuse same instance automatically
  factory DeepLinkService() => Singleton.lazy(() => DeepLinkService._());

  /// Private constructor
  DeepLinkService._();

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  /// Initialize deep link handling
  void initialize() {
    _appLinks = AppLinks();
    _listenToIncomingLinks();
  }

  /// Handle initial deep link when app is launched from terminated state
  Future<void> handleInitialLink() async {
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        final deepLinkInfo = _parseDeepLink(initialLink);
        if (deepLinkInfo != null) {
          // Store the pending deep link for later navigation
          AppService().setPendingDeepLink(
            '${deepLinkInfo['type']}/${deepLinkInfo['id']}',
          );
        }
      }
    } catch (e) {
      print('Failed to get initial link: $e');
    }
  }

  /// Listen to incoming deep links when app is already running
  void _listenToIncomingLinks() {
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleRuntimeDeepLink(uri);
    });
  }

  /// Handle deep links when app is already running
  void _handleRuntimeDeepLink(Uri uri) {
    if (uri.scheme == 'mybalifriendz') {
      final code = uri.queryParameters['code'];
      final idToken = uri.queryParameters['id_token'];

      print('apple SUCCESS: $code');

      // ✅ kirim ke stream
      if (code != null && idToken != null) {
        AppService().iosLogin.add(AppleLoginData(code: code, idToken: idToken));
      } else {
        print("apple ERROR: code/idToken NULL");
      }
    }
    final navigatorKey = AppService().navigatorKey;
    if (navigatorKey.currentContext != null) {
      final deepLinkInfo = _parseDeepLink(uri);
      if (deepLinkInfo != null) {
        // Navigate to loading screen while preserving navigation stack
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder:
                (context) => DeepLinkLoadingPage(
                  type: deepLinkInfo['type']!,
                  id: deepLinkInfo['id']!,
                ),
          ),
        );
      }
    }
  }

  /// Parse deep link and extract type and ID
  Map<String, String>? _parseDeepLink(Uri uri) {
    // Handle both custom scheme and HTTPS URLs
    if (uri.scheme == _customScheme) {
      return _parseCustomScheme(uri);
    } else if (uri.scheme == 'https' && uri.host == _httpsHost) {
      return _parseHttpsUrl(uri);
    }
    return null;
  }

  /// Handle custom scheme URLs: ${_customScheme}://vendor/123
  Map<String, String>? _parseCustomScheme(Uri uri) {
    switch (uri.host) {
      case 'vendor':
        final vendorId =
            uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
        return vendorId != null ? {'type': 'vendor', 'id': vendorId} : null;
      case 'product':
        final productId =
            uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
        return productId != null ? {'type': 'product', 'id': productId} : null;
      case 'service':
        final serviceId =
            uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
        return serviceId != null ? {'type': 'service', 'id': serviceId} : null;
      case 'order':
        final orderId =
            uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
        return orderId != null ? {'type': 'order', 'id': orderId} : null;
      default:
        return null;
    }
  }

  /// Handle HTTPS URLs: https://${_httpsHost}/vendor/123
  Map<String, String>? _parseHttpsUrl(Uri uri) {
    if (uri.pathSegments.isNotEmpty) {
      final pathType = uri.pathSegments[0];
      switch (pathType) {
        case 'vendor':
          final vendorId =
              uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
          return vendorId != null ? {'type': 'vendor', 'id': vendorId} : null;
        case 'product':
          final productId =
              uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
          return productId != null
              ? {'type': 'product', 'id': productId}
              : null;
        case 'service':
          final serviceId =
              uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
          return serviceId != null
              ? {'type': 'service', 'id': serviceId}
              : null;
        case 'order':
          final orderId =
              uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
          return orderId != null ? {'type': 'order', 'id': orderId} : null;
        default:
          return null;
      }
    }
    return null;
  }

  /// Dispose resources
  void dispose() {
    _linkSubscription?.cancel();
  }
}
