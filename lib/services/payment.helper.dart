import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:fuodz/pages/payment/custom_webview.page.dart';
import 'package:fuodz/services/toast.service.dart';
import 'package:fuodz/utils/extensions/context.dart';

class _MyChromeSafariBrowser extends ChromeSafariBrowser {}

/// Replaces the navigation/URL-launching helpers that used to live on
/// `PaymentViewModel`. Kept as plain static methods so any widget can call it
/// without having to hold a VM instance.
class PaymentHelper {
  static Future<dynamic> openWebpageLink(
    BuildContext context,
    String url, {
    bool external = false,
    bool embeded = false,
  }) async {
    if (embeded) {
      return openEmbededWebpageLink(url);
    }
    if (!embeded && (Platform.isIOS || external)) {
      await launchUrlString(
        url,
        webViewConfiguration: const WebViewConfiguration(),
      );
      return;
    }
    return context.push(
      (context) => CustomWebviewPage(selectedUrl: url),
    );
  }

  static Future<dynamic> openExternalWebpageLink(String url) async {
    try {
      return await launchUrlString(
        url,
        mode: LaunchMode.externalApplication,
      );
    } catch (error) {
      ToastService.toastError('$error');
    }
    return null;
  }

  static Future<void> openEmbededWebpageLink(String url) async {
    try {
      final browser = _MyChromeSafariBrowser();
      await browser.open(
        url: WebUri.uri(Uri.parse(url)),
        settings: ChromeSafariBrowserSettings(
          enableUrlBarHiding: false,
          barCollapsingEnabled: true,
          shareState: CustomTabsShareState.SHARE_STATE_OFF,
        ),
      );
    } catch (_) {
      await launchUrlString(url);
    }
  }

  /// Open the appropriate payment surface for the given [paymentLink].
  /// `offline` payment methods are launched in an external app; anything
  /// else is opened in the embedded webview.
  static Future<dynamic> openOrderPayment(
    BuildContext context,
    String paymentLink, {
    bool offline = true,
  }) async {
    if (!offline) {
      return openWebpageLink(context, paymentLink);
    }
    return openExternalWebpageLink(paymentLink);
  }
}
