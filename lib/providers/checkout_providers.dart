import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/constants/api.dart';
import 'package:fuodz/models/checkout.dart';
import 'package:fuodz/models/delivery_address.dart';
import 'package:fuodz/models/payment_method.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/services/cart.service.dart';
import 'package:fuodz/services/checkout.request.dart';
import 'package:fuodz/services/checkout_shared.helper.dart';
import 'package:fuodz/services/payment.helper.dart';
import 'package:fuodz/services/toast.service.dart';
import 'package:fuodz/utils/app_routes.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/utils/extensions/string.dart';
import 'package:jiffy/jiffy.dart';

class CheckoutState {
  const CheckoutState({
    required this.checkout,
    this.vendor,
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
    this.paymentTermsAgreed = false,
    this.isBusy = false,
    this.loadingTime = false,
    this.loadingTables = false,
    this.canSelectPaymentOption = true,
  });

  final CheckOut checkout;
  final Vendor? vendor;
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
  final bool paymentTermsAgreed;
  final bool isBusy;
  final bool loadingTime;
  final bool loadingTables;
  final bool canSelectPaymentOption;

  CheckoutState copyWith({
    CheckOut? checkout,
    Vendor? vendor,
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
    bool? paymentTermsAgreed,
    bool? isBusy,
    bool? loadingTime,
    bool? loadingTables,
    bool? canSelectPaymentOption,
  }) {
    return CheckoutState(
      checkout: checkout ?? this.checkout,
      vendor: vendor ?? this.vendor,
      deliveryAddress:
          identical(deliveryAddress, _sentinel)
              ? this.deliveryAddress
              : deliveryAddress as DeliveryAddress?,
      isPickup: isPickup ?? this.isPickup,
      isScheduled: isScheduled ?? this.isScheduled,
      deliveryAddressOutOfRange:
          deliveryAddressOutOfRange ?? this.deliveryAddressOutOfRange,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      selectedPaymentMethod:
          identical(selectedPaymentMethod, _sentinel)
              ? this.selectedPaymentMethod
              : selectedPaymentMethod as PaymentMethod?,
      availableTimeSlots: availableTimeSlots ?? this.availableTimeSlots,
      dateFull: dateFull ?? this.dateFull,
      timeFull: timeFull ?? this.timeFull,
      tables: tables ?? this.tables,
      tableSelected:
          identical(tableSelected, _sentinel)
              ? this.tableSelected
              : tableSelected as String?,
      paymentTermsAgreed: paymentTermsAgreed ?? this.paymentTermsAgreed,
      isBusy: isBusy ?? this.isBusy,
      loadingTime: loadingTime ?? this.loadingTime,
      loadingTables: loadingTables ?? this.loadingTables,
      canSelectPaymentOption:
          canSelectPaymentOption ?? this.canSelectPaymentOption,
    );
  }

  static const _sentinel = Object();
}

class CheckoutController
    extends AutoDisposeFamilyNotifier<CheckoutState, CheckOut> {
  final CheckoutRequest _checkoutRequest = CheckoutRequest();
  final TextEditingController noteTEC = TextEditingController();
  final TextEditingController driverTipTEC = TextEditingController();
  final TextEditingController guestCountTEC = TextEditingController();

  @override
  CheckoutState build(CheckOut arg) {
    ref.onDispose(() {
      noteTEC.dispose();
      driverTipTEC.dispose();
      guestCountTEC.dispose();
    });
    Vendor? primary;
    if (CartServices.productsInCart.isNotEmpty) {
      primary = CartServices.productsInCart[0].product?.vendor;
    }
    return CheckoutState(checkout: arg, vendor: primary);
  }

  Future<void> initialise() async {
    await _fetchVendorDetails();
    _setVendorRequirement();
    await Future.wait([_prefetchDeliveryAddress(), _fetchPaymentOptions()]);
    await _updateTotalOrderSummary();
    if (state.vendor != null && state.vendor!.can_dinein == false) {
      await _fetchDateUse();
    }
  }

  Future<void> _fetchVendorDetails() async {
    if (state.vendor == null) return;
    state = state.copyWith(isBusy: true);
    try {
      final v = await CheckoutSharedHelpers.fetchVendorDetails(state.vendor!);
      state = state.copyWith(vendor: v);
    } catch (e) {
      // ignore: avoid_print
      print("Checkout fetchVendorDetails error: $e");
    }
    state = state.copyWith(isBusy: false);
  }

  void _setVendorRequirement() {
    final v = state.vendor;
    if (v == null) return;
    if (v.allowOnlyDelivery) {
      state = state.copyWith(isPickup: false);
    } else if (v.allowOnlyPickup) {
      state = state.copyWith(isPickup: true);
    }

    // Auto-schedule F&B if not pickup
    if (v.isFoodOrBeverage && !state.isPickup) {
      state = state.copyWith(isScheduled: true);
      state.checkout.isScheduled = true;
    }
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
      print("Checkout prefetchDeliveryAddress error: $e");
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
      print("Checkout fetchPaymentOptions error: $e");
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
        changeSelectedPaymentMethod(cash, callTotal: false);
      }
    }
  }

  Future<void> _fetchDateUse() async {
    if (state.vendor == null) return;
    try {
      final dates = await CheckoutSharedHelpers.fetchDateUse(state.vendor!.id);
      state = state.copyWith(dateFull: dates);
    } catch (e) {
      // ignore: avoid_print
      print("Checkout fetchDateUse error: $e");
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
      print("Checkout fetchTableAvailability error: $e");
    }
    state = state.copyWith(loadingTables: false);
  }

  Future<void> updateTotalOrderSummary() => _updateTotalOrderSummary();

  Future<void> _updateTotalOrderSummary() async {
    if (state.vendor == null) return;
    state = state.copyWith(isBusy: true);
    try {
      final updated = await CheckoutSharedHelpers.recalcOrderSummary(
        current: state.checkout,
        vendor: state.vendor!,
        isPickup: state.isPickup,
        deliveryAddressOutOfRange: state.deliveryAddressOutOfRange,
        tip: driverTipTEC.text,
        deliveryAddress: state.deliveryAddress,
      );
      if (state.vendor?.isFoodOrBeverage == true && state.isScheduled) {
        final total = updated.total;
        final dp =
            (double.tryParse(AppStrings.down_payment.toString())! / 100) *
            total;
        updated.dp = dp;
        updated.sisa = total - dp;
      }
      state = state.copyWith(checkout: updated);
    } catch (e) {
      // ignore: avoid_print
      print("Checkout updateTotalOrderSummary error: $e");
      ToastService.toastError("$e");
    }
    state = state.copyWith(isBusy: false);
    _updatePaymentOptionSelection();
  }

  void togglePickupStatus(bool? value) {
    final isPickup = value ?? false;
    final bool allowSchedule =
        state.vendor?.allowScheduleOrder == true ||
        state.vendor?.isFoodOrBeverage == true;
    final isScheduled = value == true ? false : allowSchedule;
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

  Future<void> toggleScheduledOrder(bool? value) async {
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
    await Jiffy.setLocale(translator.activeLocale.languageCode);
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

  void changeSelectedPaymentMethod(PaymentMethod? pm, {bool callTotal = true}) {
    final co = state.checkout;
    co.paymentMethod = pm;
    state = state.copyWith(selectedPaymentMethod: pm, checkout: co);
    if (callTotal) _updateTotalOrderSummary();
  }

  void setPaymentTermsAgreed(bool value) {
    state = state.copyWith(paymentTermsAgreed: value);
  }

  void openPaymentTerms(BuildContext context) {
    PaymentHelper.openWebpageLink(context, Api.paymentTerms);
  }

  bool _pickupOnlyProduct() {
    for (final c in CartServices.productsInCart) {
      if (!(c.product?.canBeDelivered ?? false)) return true;
    }
    return false;
  }

  bool _verifyVendorOrderAmountCheck() {
    final orderVendor =
        state.checkout.cartItems?.first.product?.vendor ?? state.vendor;
    if (orderVendor?.minOrder != null &&
        orderVendor!.minOrder! > state.checkout.subTotal) {
      AlertService.error(
        title: "Minimum Order Value".tr(),
        text:
            "Order value/amount is less than vendor accepted minimum order"
                .tr() +
            "${AppStrings.currencySymbol} ${orderVendor.minOrder}"
                .currencyFormat(),
      );
      return false;
    } else if (orderVendor?.maxOrder != null &&
        orderVendor!.maxOrder! < state.checkout.subTotal) {
      AlertService.error(
        title: "Maximum Order Value".tr(),
        text:
            "Order value/amount is more than vendor accepted maximum order"
                .tr() +
            "${AppStrings.currencySymbol} ${orderVendor.maxOrder}"
                .currencyFormat(),
      );
      return false;
    }
    return true;
  }

  Future<void> placeOrder(BuildContext context, {bool ignore = false}) async {
    if (state.isScheduled && state.checkout.deliverySlotDate.isEmptyOrNull) {
      AlertService.error(
        title: "Delivery Date".tr(),
        text: "Please select your desire order date".tr(),
      );
      return;
    } else if (state.isScheduled &&
        state.checkout.deliverySlotTime.isEmptyOrNull) {
      AlertService.error(
        title: "Delivery Time".tr(),
        text: "Please select your desire order time".tr(),
      );
      return;
    } else if (!state.isPickup && _pickupOnlyProduct()) {
      AlertService.error(
        title: "Product".tr(),
        text:
            "There seems to be products that can not be delivered in your cart"
                .tr(),
      );
      return;
    } else if (state.selectedPaymentMethod == null) {
      AlertService.error(
        title: "Payment Methods".tr(),
        text: "Please select a payment method".tr(),
      );
      return;
    } else if (!ignore && !_verifyVendorOrderAmountCheck()) {
      return;
    } else if (state.vendor?.isFoodOrBeverage == true &&
        !state.isPickup &&
        (guestCountTEC.text.isEmpty ||
            (int.tryParse(guestCountTEC.text) ?? 0) <
                (state.vendor?.can_dinein == true ? 3 : 1))) {
      AlertService.error(
        title: "Reservation".tr(),
        text:
            "Minimum ${state.vendor?.can_dinein == true ? 3 : 1} guests required"
                .tr(),
      );
      return;
    } else if (state.vendor?.isFoodOrBeverage == true &&
        !state.isPickup &&
        state.tableSelected == null &&
        state.vendor?.can_dinein == true) {
      AlertService.error(
        title: "Dine-in".tr(),
        text: "The selected table id field is required.".tr(),
      );
      return;
    }
    await _processOrderPlacement(context);
  }

  Future<void> _processOrderPlacement(BuildContext context) async {
    state = state.copyWith(isBusy: true);
    try {
      final co = state.checkout;
      double tipAmount = double.tryParse(driverTipTEC.text) ?? 0.0;
      // Calculate total with tip only if totalWithTip hasn't already included it (totalWithTip == total means backend didn't calculate it)
      if (co.totalWithTip == co.total) {
        co.total = co.total + tipAmount;
      } else {
        co.total = co.totalWithTip;
      }

      co.reser_guest =
          guestCountTEC.text.isEmptyOrNull
              ? null
              : int.tryParse(guestCountTEC.text);
      co.reser_table =
          state.tableSelected != null
              ? int.tryParse(state.tableSelected!)
              : null;
      final apiResponse = await _checkoutRequest.newOrder(
        co,
        tip: driverTipTEC.text,
        note: noteTEC.text,
      );
      AppService().refreshWalletBalance.add(true);

      if (apiResponse.allGood) {
        await CartServices.clearCart();
        final paymentLink = apiResponse.body["link"].toString();
        if (!paymentLink.isEmptyOrNull) {
          context.goRoute(AppRoutes.homeRoute);
          _showOrdersTab(context: context);
          if (["offline"].contains(co.paymentMethod?.slug ?? "offline")) {
            await PaymentHelper.openExternalWebpageLink(paymentLink);
          } else {
            await PaymentHelper.openWebpageLink(context, paymentLink);
          }
        } else {
          await AlertService.success(
            title: "Checkout".tr(),
            text: apiResponse.message,
            confirmBtnText: "Ok".tr(),
            barrierDismissible: false,
            onConfirm: () async {
              context.goRoute(AppRoutes.homeRoute);
              _showOrdersTab(context: context);
            },
          );
        }
      } else {
        AlertService.error(title: "Checkout".tr(), text: apiResponse.message);
      }
    } catch (e) {
      // ignore: avoid_print
      print("Checkout placeOrder error: $e");
      ToastService.toastError("$e");
    }
    state = state.copyWith(isBusy: false);
    CartServices.refreshState();
  }

  void _showOrdersTab({required BuildContext context}) {
    CartServices.clearCart();
    AppService().changeHomePageIndex(index: 2);
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).popUntil(
        (route) => route.settings.name == AppRoutes.homeRoute || route.isFirst,
      );
    }
  }
}

final checkoutControllerProvider = NotifierProvider.autoDispose
    .family<CheckoutController, CheckoutState, CheckOut>(
      CheckoutController.new,
    );
