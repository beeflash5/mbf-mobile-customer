import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import 'package:fuodz/models/cart.dart';
import 'package:fuodz/models/checkout.dart';
import 'package:fuodz/models/delivery_address.dart';
import 'package:fuodz/models/payment_method.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/services/cart.service.dart';
import 'package:fuodz/services/checkout.request.dart';
import 'package:fuodz/services/checkout_shared.helper.dart';
import 'package:fuodz/services/toast.service.dart';
import 'package:fuodz/utils/app_routes.dart';

class MultipleCheckoutState {
  const MultipleCheckoutState({
    required this.checkout,
    this.vendor,
    this.vendors = const [],
    this.orderData = const [],
    this.totalTax = 0,
    this.totalDeliveryFee = 0,
    this.taxes = const [],
    this.vendorFees = const [],
    this.subtotals = const [],
    this.deliveryAddress,
    this.isPickup = false,
    this.isScheduled = false,
    this.deliveryAddressOutOfRange = false,
    this.paymentMethods = const [],
    this.selectedPaymentMethod,
    this.availableTimeSlots = const [],
    this.dateFull = const [],
    this.timeFull = const [],
    this.tables = const [],
    this.tableSelected,
    this.isBusy = false,
    this.loadingTime = false,
    this.loadingTables = false,
    this.canSelectPaymentOption = true,
  });

  final CheckOut checkout;
  final Vendor? vendor;
  final List<Vendor> vendors;
  final List<Map<String, dynamic>> orderData;
  final double totalTax;
  final double totalDeliveryFee;
  final List<double> taxes;
  final List<double> vendorFees;
  final List<double> subtotals;
  final DeliveryAddress? deliveryAddress;
  final bool isPickup;
  final bool isScheduled;
  final bool deliveryAddressOutOfRange;
  final List<PaymentMethod> paymentMethods;
  final PaymentMethod? selectedPaymentMethod;
  final List<String> availableTimeSlots;
  final List<String> dateFull;
  final List<String> timeFull;
  final List<Map<String, dynamic>> tables;
  final String? tableSelected;
  final bool isBusy;
  final bool loadingTime;
  final bool loadingTables;
  final bool canSelectPaymentOption;

  MultipleCheckoutState copyWith({
    CheckOut? checkout,
    Vendor? vendor,
    List<Vendor>? vendors,
    List<Map<String, dynamic>>? orderData,
    double? totalTax,
    double? totalDeliveryFee,
    List<double>? taxes,
    List<double>? vendorFees,
    List<double>? subtotals,
    Object? deliveryAddress = _sentinel,
    bool? isPickup,
    bool? isScheduled,
    bool? deliveryAddressOutOfRange,
    List<PaymentMethod>? paymentMethods,
    Object? selectedPaymentMethod = _sentinel,
    List<String>? availableTimeSlots,
    List<String>? dateFull,
    List<String>? timeFull,
    List<Map<String, dynamic>>? tables,
    Object? tableSelected = _sentinel,
    bool? isBusy,
    bool? loadingTime,
    bool? loadingTables,
    bool? canSelectPaymentOption,
  }) {
    return MultipleCheckoutState(
      checkout: checkout ?? this.checkout,
      vendor: vendor ?? this.vendor,
      vendors: vendors ?? this.vendors,
      orderData: orderData ?? this.orderData,
      totalTax: totalTax ?? this.totalTax,
      totalDeliveryFee: totalDeliveryFee ?? this.totalDeliveryFee,
      taxes: taxes ?? this.taxes,
      vendorFees: vendorFees ?? this.vendorFees,
      subtotals: subtotals ?? this.subtotals,
      deliveryAddress: identical(deliveryAddress, _sentinel)
          ? this.deliveryAddress
          : deliveryAddress as DeliveryAddress?,
      isPickup: isPickup ?? this.isPickup,
      isScheduled: isScheduled ?? this.isScheduled,
      deliveryAddressOutOfRange:
          deliveryAddressOutOfRange ?? this.deliveryAddressOutOfRange,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      selectedPaymentMethod: identical(selectedPaymentMethod, _sentinel)
          ? this.selectedPaymentMethod
          : selectedPaymentMethod as PaymentMethod?,
      availableTimeSlots: availableTimeSlots ?? this.availableTimeSlots,
      dateFull: dateFull ?? this.dateFull,
      timeFull: timeFull ?? this.timeFull,
      tables: tables ?? this.tables,
      tableSelected: identical(tableSelected, _sentinel)
          ? this.tableSelected
          : tableSelected as String?,
      isBusy: isBusy ?? this.isBusy,
      loadingTime: loadingTime ?? this.loadingTime,
      loadingTables: loadingTables ?? this.loadingTables,
      canSelectPaymentOption:
          canSelectPaymentOption ?? this.canSelectPaymentOption,
    );
  }

  static const _sentinel = Object();
}

class MultipleCheckoutController
    extends AutoDisposeFamilyNotifier<MultipleCheckoutState, CheckOut> {
  final CheckoutRequest _checkoutRequest = CheckoutRequest();
  final TextEditingController noteTEC = TextEditingController();
  final TextEditingController driverTipTEC = TextEditingController();

  @override
  MultipleCheckoutState build(CheckOut arg) {
    ref.onDispose(() {
      noteTEC.dispose();
      driverTipTEC.dispose();
    });
    Vendor? primaryVendor;
    if (CartServices.productsInCart.isNotEmpty) {
      primaryVendor = CartServices.productsInCart[0].product?.vendor;
    }
    return MultipleCheckoutState(checkout: arg, vendor: primaryVendor);
  }

  Future<void> initialise() async {
    await _fetchVendorsDetails();
    await Future.wait([
      _prefetchDeliveryAddress(),
      _fetchPaymentOptions(),
    ]);
    await _updateTotalOrderSummary();
    if (state.vendor != null && state.vendor!.can_dinein == false) {
      await _fetchDateUse();
    }
  }

  Future<void> _fetchVendorsDetails() async {
    var vendors = CartServices.productsInCart
        .map((e) => e.product!.vendor)
        .toList()
        .toSet()
        .toList();
    vendors = vendors.distinctBy((v) => v.id).toList();
    state = state.copyWith(vendors: vendors, isBusy: true);
    try {
      for (var i = 0; i < vendors.length; i++) {
        vendors[i] =
            await CheckoutSharedHelpers.fetchVendorDetails(vendors[i]);
      }
      Vendor? primary;
      if (vendors.isNotEmpty) primary = vendors.first;
      state = state.copyWith(vendors: vendors, vendor: primary);
    } catch (e) {
      // ignore: avoid_print
      print("MultipleCheckout fetchVendorsDetails error: $e");
    }
    state = state.copyWith(isBusy: false);
  }

  Future<void> _prefetchDeliveryAddress() async {
    try {
      final preselected =
          await CheckoutSharedHelpers.preselectedDeliveryAddress(
        vendorId: state.vendor?.id,
      );
      if (preselected == null) return;
      final co = state.checkout;
      co.deliveryAddress = preselected;
      var out = false;
      if (state.vendor != null) {
        out = CheckoutSharedHelpers.isAddressOutOfRange(
          vendor: state.vendor!,
          deliveryAddress: preselected,
        );
      }
      state = state.copyWith(
        deliveryAddress: preselected,
        checkout: co,
        deliveryAddressOutOfRange: out,
      );
    } catch (e) {
      // ignore: avoid_print
      print("MultipleCheckout prefetchDeliveryAddress error: $e");
    }
  }

  Future<void> _fetchPaymentOptions() async {
    try {
      final methods = await CheckoutSharedHelpers.getPaymentOptions(
        vendorId: state.vendor?.id,
        isPickup: state.isPickup,
      );
      state = state.copyWith(paymentMethods: methods);
      _updatePaymentOptionSelection();
    } catch (e) {
      // ignore: avoid_print
      print("MultipleCheckout fetchPaymentOptions error: $e");
    }
  }

  void _updatePaymentOptionSelection() {
    final canSelect = !(state.checkout.total <= 0.00);
    state = state.copyWith(canSelectPaymentOption: canSelect);
    if (!canSelect) {
      final cash = CheckoutSharedHelpers.autoSelectCashIfFree(
        checkout: state.checkout,
        paymentMethods: state.paymentMethods,
      );
      if (cash != null) {
        changeSelectedPaymentMethod(cash);
      }
    }
  }

  Future<void> _fetchDateUse() async {
    if (state.vendor == null) return;
    try {
      final dates =
          await CheckoutSharedHelpers.fetchDateUse(state.vendor!.id);
      state = state.copyWith(dateFull: dates);
    } catch (e) {
      // ignore: avoid_print
      print("MultipleCheckout fetchDateUse error: $e");
    }
  }

  Future<void> _fetchTableAvailability() async {
    if (state.vendor == null) return;
    state = state.copyWith(loadingTables: true);
    try {
      final tables = await CheckoutSharedHelpers.fetchTableAvailability(
        vendorId: state.vendor!.id,
        deliverySlotDate: state.checkout.deliverySlotDate,
        qtyTables: state.vendor!.qty_tables ?? 0,
      );
      state = state.copyWith(tables: tables);
    } catch (e) {
      // ignore: avoid_print
      print("MultipleCheckout fetchTableAvailability error: $e");
    }
    state = state.copyWith(loadingTables: false);
  }

  Future<void> _updateTotalOrderSummary() async {
    final co = state.checkout;
    co.tax = 0;
    co.deliveryFee = 0;
    final orderData = <Map<String, dynamic>>[];
    var totalTax = 0.0;
    var totalDeliveryFee = 0.0;
    final taxes = <double>[];
    final vendorFees = <double>[];
    final subtotals = <double>[];

    state = state.copyWith(isBusy: true);
    try {
      for (var index = 0; index < state.vendors.length; index++) {
        final mVendor = state.vendors[index];
        final vendorCartItems = CartServices.productsInCart
            .where((e) => e.product!.vendor.id == mVendor.id)
            .toList();
        final vendorProducts =
            vendorCartItems.map((Cart e) => e.toCheckout()).toList();
        final payload = {
          "pickup": state.isPickup ? 1 : 0,
          "delievryAddressOutOfRange":
              state.deliveryAddressOutOfRange ? 1 : 0,
          "tip": driverTipTEC.text,
          "delivery_address_id": state.deliveryAddress?.id,
          "coupon_code": co.coupon?.code ?? "",
          "vendor_id": mVendor.id,
          "products": vendorProducts,
        };
        final mCheckout = await _checkoutRequest.orderSummary(payload);
        final calTax = mCheckout.tax;
        final vendorSubtotal = mCheckout.subTotal;
        co.tax += calTax;
        totalTax += double.tryParse(mVendor.tax) ?? 0;
        totalDeliveryFee += mCheckout.deliveryFee;

        if (taxes.indices.contains(index)) {
          taxes[index] = calTax;
        } else {
          taxes.add(calTax);
        }
        if (subtotals.indices.contains(index)) {
          subtotals[index] = vendorSubtotal;
        } else {
          subtotals.add(vendorSubtotal);
        }

        final vendorDiscount = mCheckout.discount;
        var vendorTotal = (vendorSubtotal - vendorDiscount) +
            mCheckout.deliveryFee +
            calTax;
        final feesObjects = mCheckout.fees.map((e) => e.toJson()).toList();
        final totalVendorFees = mCheckout.totalFee;
        vendorTotal += totalVendorFees;
        if (vendorFees.indices.contains(index)) {
          vendorFees[index] = totalVendorFees;
        } else {
          vendorFees.add(totalVendorFees);
        }
        final orderObject = {
          "vendor_id": mVendor.id,
          "delivery_fee": mCheckout.deliveryFee,
          "tax": calTax,
          "sub_total": vendorSubtotal,
          "discount": vendorDiscount,
          "tip": 0,
          "total": vendorTotal,
          "fees": feesObjects,
          "token": mCheckout.token,
          "products": vendorProducts,
        };
        final idx = orderData.indexWhere(
          (e) => e.containsKey("vendor_id") && e["vendor_id"] == mVendor.id,
        );
        if (idx >= 0) {
          orderData[idx] = orderObject;
        } else {
          orderData.add(orderObject);
        }
      }
      co.tax = taxes.sum();
      co.subTotal = subtotals.sum();
      co.total = (co.subTotal - co.discount) + totalDeliveryFee + co.tax;
      co.total += vendorFees.sum();
      state = state.copyWith(
        checkout: co,
        orderData: orderData,
        totalTax: totalTax,
        totalDeliveryFee: totalDeliveryFee,
        taxes: taxes,
        vendorFees: vendorFees,
        subtotals: subtotals,
      );
    } catch (e) {
      // ignore: avoid_print
      print("MultipleCheckout updateTotalOrderSummary error: $e");
      ToastService.toastError("$e");
    }
    state = state.copyWith(isBusy: false);
    _updatePaymentOptionSelection();
  }

  void togglePickupStatus(bool? value) {
    final isPickup = value ?? false;
    final isScheduled = value == true ? false : true;
    final co = state.checkout;
    co.deliveryAddress = isPickup ? null : state.deliveryAddress;
    state = state.copyWith(
      isPickup: isPickup,
      isScheduled: isScheduled,
      checkout: co,
    );
    _updateTotalOrderSummary();
    _fetchPaymentOptions();
  }

  void toggleScheduledOrder(bool? value) {
    final isScheduled = value ?? false;
    final co = state.checkout;
    co.isScheduled = isScheduled;
    co.pickupDate = null;
    co.deliverySlotDate = "";
    co.pickupTime = null;
    co.deliverySlotTime = "";
    state = state.copyWith(
      isScheduled: isScheduled,
      isPickup: value == true ? false : true,
      checkout: co,
    );
    _updateTotalOrderSummary();
  }

  void changeSelectedDeliveryDate(String dateStr, int index) {
    final co = state.checkout;
    co.deliverySlotDate = dateStr;
    co.deliverySlotTime = "";
    final times = state.vendor?.deliverySlots[index].times ?? [];
    state = state.copyWith(checkout: co, availableTimeSlots: times);
    _fetchTableAvailability();
  }

  void changeSelectedDeliveryTime(String time) {
    final co = state.checkout;
    co.deliverySlotTime = time;
    state = state.copyWith(checkout: co);
  }

  void selectTableSelecte(String selected) {
    state = state.copyWith(tableSelected: selected);
  }

  Future<DeliveryAddress?> pickDeliveryAddress(BuildContext context) async {
    return CheckoutSharedHelpers.pickDeliveryAddress(
      context: context,
      onPicked: (addr) {
        final co = state.checkout;
        co.deliveryAddress = addr;
        var out = false;
        if (state.vendor != null) {
          out = CheckoutSharedHelpers.isAddressOutOfRange(
            vendor: state.vendor!,
            deliveryAddress: addr,
          );
        }
        state = state.copyWith(
          deliveryAddress: addr,
          checkout: co,
          deliveryAddressOutOfRange: out,
        );
        _updateTotalOrderSummary();
      },
    );
  }

  void changeSelectedPaymentMethod(PaymentMethod? pm) {
    final co = state.checkout;
    co.paymentMethod = pm;
    state = state.copyWith(
      selectedPaymentMethod: pm,
      checkout: co,
    );
  }

  Future<void> placeOrder(BuildContext context) async {
    if (state.selectedPaymentMethod == null) {
      AlertService.error(
        title: "Payment Methods".tr(),
        text: "Please select a payment method".tr(),
      );
      return;
    }
    state = state.copyWith(isBusy: true);
    try {
      final vendorsOrderData = <Map<String, dynamic>>[];
      for (final e in state.orderData) {
        vendorsOrderData.add({...e});
      }
      final co = state.checkout;
      co.total = co.totalWithTip;
      final apiResponse = await _checkoutRequest.newMultipleVendorOrder(
        co,
        tip: driverTipTEC.text,
        note: noteTEC.text,
        payload: {"data": vendorsOrderData},
      );
      if (apiResponse.allGood) {
        await AlertService.success(
          title: "Checkout".tr(),
          text: apiResponse.message,
        );
        await CartServices.clearCart();
        AppService().changeHomePageIndex(index: 2);
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).popUntil(
            (route) =>
                route.settings.name == AppRoutes.homeRoute || route.isFirst,
          );
        }
      } else {
        await AlertService.error(
          title: "Checkout".tr(),
          text: apiResponse.message,
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print("MultipleCheckout placeOrder error: $e");
      ToastService.toastError("$e");
    }
    state = state.copyWith(isBusy: false);
  }
}

final multipleCheckoutControllerProvider = NotifierProvider.autoDispose
    .family<MultipleCheckoutController, MultipleCheckoutState, CheckOut>(
  MultipleCheckoutController.new,
);
