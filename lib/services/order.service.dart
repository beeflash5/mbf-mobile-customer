import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:fuodz/models/order.dart';
import 'package:fuodz/services/payment.helper.dart';

class OrderService {
  /// Opens the appropriate payment view for an order's pending payment link.
  /// Uses an external browser for offline-slug payment methods, otherwise
  /// shows the in-app webview.
  static Future<dynamic> openOrderPayment(
    Order order, {
    BuildContext? context,
  }) async {
    if ((order.paymentMethod?.slug ?? "offline") != "offline") {
      if (context == null) {
        throw StateError(
          "openOrderPayment needs a BuildContext for in-app webview",
        );
      }
      return PaymentHelper.openWebpageLink(context, order.paymentLink);
    }
    return PaymentHelper.openExternalWebpageLink(order.paymentLink);
  }
}
