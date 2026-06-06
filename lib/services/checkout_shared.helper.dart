import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';

import 'package:fuodz/component/bottom_sheet/delivery_address_picker.bottomsheet.dart';
import 'package:fuodz/models/cart.dart';
import 'package:fuodz/models/checkout.dart';
import 'package:fuodz/models/delivery_address.dart';
import 'package:fuodz/models/payment_method.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/services/cart.service.dart';
import 'package:fuodz/services/checkout.request.dart';
import 'package:fuodz/services/delivery_address.request.dart';
import 'package:fuodz/services/payment_method.request.dart';
import 'package:fuodz/services/vendor.request.dart';
import 'package:fuodz/utils/extensions/context.dart';

/// Stateless helpers extracted from the old CheckoutBaseViewModel so Riverpod
/// controllers can compose them without inheritance.
class CheckoutSharedHelpers {
  static final _vendorRequest = VendorRequest();
  static final _checkoutRequest = CheckoutRequest();
  static final _deliveryAddressRequest = DeliveryAddressRequest();
  static final _paymentOptionRequest = PaymentMethodRequest();

  /// Fetches vendor details (with brief flag). Caller passes the vendor whose
  /// id to use; returns the enriched Vendor (or rethrows).
  static Future<Vendor> fetchVendorDetails(
    Vendor vendor, {
    Map<String, String>? params,
  }) async {
    return _vendorRequest.vendorDetails(
      vendor.id,
      params: params ?? const {"type": "brief"},
    );
  }

  static Future<DeliveryAddress?> preselectedDeliveryAddress({
    required int? vendorId,
  }) {
    return _deliveryAddressRequest.preselectedDeliveryAddress(
      vendorId: vendorId,
    );
  }

  static Future<List<PaymentMethod>> getPaymentOptions({
    required int? vendorId,
    required bool isPickup,
  }) {
    return _paymentOptionRequest.getPaymentOptions(
      vendorId: vendorId,
      params: {"is_pickup": isPickup ? 1 : 0},
    );
  }

  static Future<List<PaymentMethod>> getTaxiPaymentOptions() {
    return _paymentOptionRequest.getTaxiPaymentOptions();
  }

  static Future<List<String>> fetchDateUse(int vendorId) async {
    final response = await _vendorRequest.vendorGetDateUse(vendorId);
    return List<String>.from(response.body);
  }

  static Future<List<String>> fetchTimeUse(
    int vendorId,
    String deliverySlotDate,
  ) async {
    final response = await _vendorRequest.vendorGetTimeUse(
      vendorId,
      deliverySlotDate,
    );
    return List<String>.from(response.body);
  }

  /// Returns rows of {name: "1", available: bool} for each table.
  static Future<List<Map<String, dynamic>>> fetchTableAvailability({
    required int vendorId,
    required String deliverySlotDate,
    required int qtyTables,
  }) async {
    final response = await _vendorRequest.vendorGetTableUse(
      vendorId,
      deliverySlotDate,
      null,
    );
    final List<int> taken = List<int>.from(response.body);
    return [
      for (int i = 1; i <= qtyTables; i++)
        {"name": "$i", "available": !taken.contains(i)},
    ];
  }

  /// Whether the address falls outside the vendor's delivery range. Mirrors
  /// the old checkDeliveryRange logic exactly.
  static bool isAddressOutOfRange({
    required Vendor vendor,
    required DeliveryAddress deliveryAddress,
  }) {
    var out = vendor.deliveryRange < (deliveryAddress.distance ?? 0);
    if (deliveryAddress.can_deliver != null) {
      out = (deliveryAddress.can_deliver ?? false) == false;
    }
    return out;
  }

  /// Recomputes the live order summary (subtotal/discount/delivery/tax/total).
  static Future<CheckOut> recalcOrderSummary({
    required CheckOut current,
    required Vendor vendor,
    required bool isPickup,
    required bool deliveryAddressOutOfRange,
    required String tip,
    required DeliveryAddress? deliveryAddress,
  }) async {
    final payload = <String, dynamic>{
      "pickup": isPickup ? 1 : 0,
      "delievryAddressOutOfRange": deliveryAddressOutOfRange ? 1 : 0,
      "tip": tip,
      "delivery_address_id": deliveryAddress?.id ?? "null",
      "latlng": "${deliveryAddress?.latitude},${deliveryAddress?.longitude}",
      "coupon_code": current.coupon?.code ?? "",
      "vendor_id": vendor.id,
      "products": CartServices.productsInCart
          .map((Cart e) => e.toCheckout())
          .toList(),
    };
    final mCheckout = await _checkoutRequest.orderSummary(payload);
    current.copyWith(
      subTotal: mCheckout.subTotal,
      discount: mCheckout.discount,
      deliveryFee: mCheckout.deliveryFee,
      tax: mCheckout.tax,
      tax_rate: mCheckout.tax_rate,
      total: mCheckout.total,
      totalWithTip: mCheckout.totalWithTip,
      token: mCheckout.token,
      fees: mCheckout.fees,
    );
    return current;
  }

  /// Picks the cash payment method if the checkout total is zero — used when
  /// canSelectPaymentOption is false.
  static PaymentMethod? autoSelectCashIfFree({
    required CheckOut? checkout,
    required List<PaymentMethod> paymentMethods,
  }) {
    if (checkout == null || checkout.total > 0.00) return null;
    return paymentMethods.firstOrNullWhere((e) => e.isCash == 1);
  }

  /// Whether the cart contains products that can't be delivered (pickup only).
  static bool cartHasPickupOnlyProduct() {
    final product = CartServices.productsInCart.firstOrNullWhere(
      (e) => !e.product?.canBeDelivered,
    );
    return product != null;
  }

  /// Opens the delivery-address picker bottom sheet. Caller awaits the
  /// returned DeliveryAddress and can also rely on the picker calling the
  /// callback before pop.
  static Future<DeliveryAddress?> pickDeliveryAddress({
    required BuildContext context,
    required ValueChanged<DeliveryAddress> onPicked,
  }) {
    return showModalBottomSheet<DeliveryAddress>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return DeliveryAddressPicker(
          onSelectDeliveryAddress: (deliveryAddress) {
            onPicked(deliveryAddress);
            sheetCtx.pop(deliveryAddress);
          },
        );
      },
    );
  }
}
