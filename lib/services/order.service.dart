import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:fuodz/models/order.dart';
import 'package:fuodz/services/payment.helper.dart';
import 'package:fuodz/services/checkout.request.dart';
import 'package:fuodz/services/toast.service.dart';

class OrderService {
  /// Opens the appropriate payment view for an order's pending payment link.
  /// Uses an external browser for offline-slug payment methods, otherwise
  /// shows the in-app webview.
  static Future<dynamic> openOrderPayment(
    Order order, {
    BuildContext? context,
  }) async {
    // ── Remaining balance (sisa) flow ───────────────────────────────────────
    if ((order.dp ?? 0) > 0 &&
        order.dp_status == 1 &&
        order.sisa_status == 0) {
      final slug = order.paymentMethod?.slug ?? 'offline';
      if (slug == 'offline' || slug == 'cash' || slug == 'wallet') {
        return;
      }
      try {
        final checkoutReq = CheckoutRequest();
        final sisaUrl = await checkoutReq.getSisaPaymentLink(order.id);
        if (context == null) {
          throw StateError("openOrderPayment needs a BuildContext for in-app webview");
        }
        return PaymentHelper.openWebpageLink(context, sisaUrl);
      } catch (e) {
        ToastService.toastError('$e');
        return;
      }
    }

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
