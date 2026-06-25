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
import 'package:fuodz/services/vendor_type.request.dart';
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
    final v = await _vendorRequest.vendorDetails(
      vendor.id,
      params: params ?? const {"type": "brief"},
    );

    // Preserve essential original data only if the API dropped it
    if (v.vendorType.id == 0 || v.vendorType.slug.isEmpty) {
      v.vendorType = vendor.vendorType;
    }

    if (v.vendorTypeId == 0) {
      v.vendorTypeId = vendor.vendorTypeId;
    }

    // If both the API and original vendor lacked a full vendorType, fetch types
    if ((v.vendorType.id == 0 || v.vendorType.slug.isEmpty) &&
        v.vendorTypeId != 0) {
      try {
        final types = await VendorTypeRequest().index();
        final match = types.where((t) => t.id == v.vendorTypeId).toList();
        if (match.isNotEmpty) {
          v.vendorType = match.first;
        }
      } catch (_) {}
    }

    // Resolve missing vendor type slug from global list, mimicking Next.js
    if (v.vendorType.slug.isEmpty && v.vendorTypeId > 0) {
      try {
        final types = await VendorTypeRequest().index();
        final matched = types.firstWhere(
          (t) => t.id == v.vendorTypeId,
          orElse: () => v.vendorType,
        );
        if (matched.slug.isNotEmpty) {
          v.vendorType = matched;
        }
      } catch (e) {
        // ignore
      }
    }
    // deliverySlots are never returned by /api/vendors/{id}, so always copy them from the original object.
    v.deliverySlots = vendor.deliverySlots;
    if (v.can_dinein == null || v.can_dinein == false) {
      v.can_dinein = vendor.can_dinein;
    }
    if (v.qty_tables == null || v.qty_tables == 0) {
      v.qty_tables = vendor.qty_tables;
    }

    return v;
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
    final List<int> taken =
        (response.body as List)
            .map((e) => int.tryParse(e.toString()) ?? 0)
            .toList();
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
      "delivery_address_id": deliveryAddress?.id,
      "latlng": "${deliveryAddress?.latitude},${deliveryAddress?.longitude}",
      "coupon_code": current.coupon?.code ?? "",
      "vendor_id": vendor.id,
      "products":
          (current.cartItems ?? CartServices.productsInCart)
              .map((Cart e) => e.toCheckout())
              .toList(),
      "is_scheduled": current.isScheduled == true ? 1 : 0,
      "pickup_date": current.deliverySlotDate,
      "pickup_time": current.deliverySlotTime,
      "schedule_date": current.deliverySlotDate,
      "schedule_time": current.deliverySlotTime,
      "type": isPickup ? "pickup" : "delivery",
      "guest_count": current.reser_guest,
      "table": current.reser_table,
      "dp": current.dp,
      "sisa": current.sisa,
    };
    final mCheckout = await _checkoutRequest.orderSummary(payload);

    // If the backend returns total=0 but the local cart already has a
    // positive total (e.g. F&B dine-in without a delivery address), trust
    // the local cart calculation for price fields and only take fees/token
    // from the API response.
    final bool apiReturnedZero =
        mCheckout.subTotal == 0 && mCheckout.total == 0;
    final bool localHasValue = current.subTotal > 0 || current.total > 0;

    print(
      '[CHECKOUT] apiReturnedZero=$apiReturnedZero, localHasValue=$localHasValue, api.subTotal=${mCheckout.subTotal}, api.total=${mCheckout.total}',
    );

    final fresh =
        CheckOut(
            // If API returned 0 but local has value, fall back to local prices
            subTotal:
                apiReturnedZero && localHasValue
                    ? current.subTotal
                    : mCheckout.subTotal,
            discount:
                apiReturnedZero && localHasValue
                    ? current.discount
                    : mCheckout.discount,
            deliveryDiscount: mCheckout.deliveryDiscount,
            deliveryFee: mCheckout.deliveryFee,
            tax: mCheckout.tax,
            tax_rate: mCheckout.tax_rate,
            total:
                apiReturnedZero && localHasValue
                    ? current.total
                    : mCheckout.total,
            totalWithTip:
                apiReturnedZero && localHasValue
                    ? current.totalWithTip
                    : mCheckout.totalWithTip,
            token: mCheckout.token,
            fees: mCheckout.fees,
            // Preserve checkout session data from current
            cartItems: current.cartItems,
            coupon: current.coupon,
            deliveryAddress: current.deliveryAddress,
            paymentMethod: current.paymentMethod,
            isPickup: current.isPickup,
            isScheduled: current.isScheduled,
            deliverySlotDate: current.deliverySlotDate,
            deliverySlotTime: current.deliverySlotTime,
            pickupDate: current.pickupDate,
            pickupTime: current.pickupTime,
            dp: current.dp,
            sisa: current.sisa,
          )
          ..reser_guest = current.reser_guest
          ..reser_table = current.reser_table;
    return fresh;
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
