import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

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
import 'package:fuodz/utils/app_file_limit.dart';
import 'package:fuodz/utils/app_routes.dart';
import 'package:fuodz/utils/extensions/dynamic.dart';

class PharmacyUploadState {
  const PharmacyUploadState({
    this.vendor,
    this.checkout,
    this.prescriptionPhotos = const [],
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

  final Vendor? vendor;
  final CheckOut? checkout;
  final List<File> prescriptionPhotos;
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

  PharmacyUploadState copyWith({
    Vendor? vendor,
    CheckOut? checkout,
    List<File>? prescriptionPhotos,
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
    return PharmacyUploadState(
      vendor: vendor ?? this.vendor,
      checkout: checkout ?? this.checkout,
      prescriptionPhotos: prescriptionPhotos ?? this.prescriptionPhotos,
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
      isBusy: isBusy ?? this.isBusy,
      loadingTime: loadingTime ?? this.loadingTime,
      loadingTables: loadingTables ?? this.loadingTables,
      canSelectPaymentOption:
          canSelectPaymentOption ?? this.canSelectPaymentOption,
    );
  }

  static const _sentinel = Object();
}

class PharmacyUploadController
    extends AutoDisposeFamilyNotifier<PharmacyUploadState, Vendor> {
  final ImagePicker _picker = ImagePicker();
  final CheckoutRequest _checkoutRequest = CheckoutRequest();

  @override
  PharmacyUploadState build(Vendor arg) {
    return PharmacyUploadState(
      vendor: arg,
      checkout: CheckOut(subTotal: 0.00),
      isPickup: arg.allowOnlyPickup,
    );
  }

  Future<void> initialise() async {
    await _fetchVendorDetails();
    _setVendorRequirement();
    await Future.wait([_prefetchDeliveryAddress(), _fetchPaymentOptions()]);
    if (state.vendor != null && state.vendor!.can_dinein == false) {
      await _fetchDateUse();
    }
  }

  Future<void> _fetchVendorDetails() async {
    state = state.copyWith(isBusy: true);
    try {
      final v = await CheckoutSharedHelpers.fetchVendorDetails(state.vendor!);
      state = state.copyWith(vendor: v);
    } catch (e) {
      // ignore: avoid_print
      print("Pharmacy fetchVendorDetails error: $e");
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
  }

  Future<void> _prefetchDeliveryAddress() async {
    try {
      final preselected =
          await CheckoutSharedHelpers.preselectedDeliveryAddress(
            vendorId: state.vendor?.id,
          );
      if (preselected == null) return;
      final co = state.checkout;
      co?.deliveryAddress = preselected;
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
      print("Pharmacy prefetchDeliveryAddress error: $e");
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
      print("Pharmacy fetchPaymentOptions error: $e");
    }
  }

  void _updatePaymentOptionSelection() {
    final canSelect =
        !(state.checkout != null && state.checkout!.total <= 0.00);
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
    if (state.vendor == null || state.checkout == null) return;
    try {
      final dates = await CheckoutSharedHelpers.fetchDateUse(state.vendor!.id);
      state = state.copyWith(dateFull: dates);
    } catch (e) {
      // ignore: avoid_print
      print("Pharmacy fetchDateUse error: $e");
    }
  }

  Future<void> _fetchTableAvailability() async {
    if (state.vendor == null || state.checkout == null) return;
    state = state.copyWith(loadingTables: true);
    try {
      final tables = await CheckoutSharedHelpers.fetchTableAvailability(
        vendorId: state.vendor!.id,
        deliverySlotDate: state.checkout!.deliverySlotDate,
        qtyTables: state.vendor!.qty_tables ?? 0,
      );
      state = state.copyWith(tables: tables);
    } catch (e) {
      // ignore: avoid_print
      print("Pharmacy fetchTableAvailability error: $e");
    }
    state = state.copyWith(loadingTables: false);
  }

  Future<void> changePhoto() async {
    final pickedFiles = await _picker.pickMultiImage();
    final newFiles = pickedFiles.map((e) => File(e.path)).toList();
    var combined = [...state.prescriptionPhotos, ...newFiles];
    if (combined.length > AppFileLimit.prescriptionFileLimit) {
      combined = combined.sublist(0, AppFileLimit.prescriptionFileLimit);
      AlertService.warning(
        title: "Prescription".tr(),
        text: "You can only upload %s prescription at a time".tr().fill([
          AppFileLimit.prescriptionFileLimit,
        ]),
      );
    }
    state = state.copyWith(prescriptionPhotos: combined);
  }

  void removePhoto(int index) {
    final next = [...state.prescriptionPhotos]..removeAt(index);
    state = state.copyWith(prescriptionPhotos: next);
  }

  void togglePickupStatus(bool? value) {
    final isPickup = value ?? false;
    final isScheduled = value == true ? false : true;
    final co = state.checkout;
    if (co != null) {
      co.deliveryAddress = isPickup ? null : state.deliveryAddress;
    }
    state = state.copyWith(
      isPickup: isPickup,
      isScheduled: isScheduled,
      checkout: co,
    );
    _fetchPaymentOptions();
  }

  void toggleScheduledOrder(bool? value) {
    final isScheduled = value ?? false;
    final co = state.checkout;
    if (co != null) {
      co.isScheduled = isScheduled;
      co.pickupDate = null;
      co.deliverySlotDate = "";
      co.pickupTime = null;
      co.deliverySlotTime = "";
    }
    state = state.copyWith(
      isScheduled: isScheduled,
      isPickup: value == true ? false : true,
      checkout: co,
    );
  }

  void changeSelectedDeliveryDate(String dateStr, int index) {
    final co = state.checkout;
    co?.deliverySlotDate = dateStr;
    co?.deliverySlotTime = "";
    final times = state.vendor?.deliverySlots[index].times ?? [];
    state = state.copyWith(checkout: co, availableTimeSlots: times);
    _fetchTableAvailability();
  }

  void changeSelectedDeliveryTime(String time) {
    final co = state.checkout;
    co?.deliverySlotTime = time;
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
        co?.deliveryAddress = addr;
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
      },
    );
  }

  void changeSelectedPaymentMethod(PaymentMethod? pm) {
    final co = state.checkout;
    co?.paymentMethod = pm;
    state = state.copyWith(selectedPaymentMethod: pm, checkout: co);
  }

  Future<void> placeOrder({
    required BuildContext context,
    required String note,
  }) async {
    if (!state.isPickup && state.deliveryAddress == null) {
      AlertService.error(
        title: "Delivery address".tr(),
        text: "Please select delivery address".tr(),
      );
      return;
    }
    if (state.deliveryAddressOutOfRange && !state.isPickup) {
      AlertService.error(
        title: "Delivery address".tr(),
        text: "Delivery address is out of vendor delivery range".tr(),
      );
      return;
    }
    if (state.prescriptionPhotos.isEmpty) {
      AlertService.error(
        title: "Prescription".tr(),
        text: "Please upload prescription".tr(),
      );
      return;
    }
    await _processOrderPlacement(context: context, note: note);
  }

  Future<void> _processOrderPlacement({
    required BuildContext context,
    required String note,
  }) async {
    state = state.copyWith(isBusy: true);
    try {
      final co = state.checkout!;
      co.total = co.totalWithTip;
      final apiResponse = await _checkoutRequest.newPrescriptionOrder(
        co,
        state.vendor!,
        photos: state.prescriptionPhotos,
        note: note,
      );
      if (apiResponse.allGood) {
        const paymentLink = "";
        if (paymentLink.isNotEmpty) {
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
          _showOrdersTab(context: context);
          PaymentHelper.openWebpageLink(context, paymentLink);
        } else {
          await AlertService.success(
            title: "Checkout".tr(),
            text: apiResponse.message,
            barrierDismissible: false,
          );
          _showOrdersTab(context: context);
        }
      } else {
        AlertService.error(title: "Checkout".tr(), text: apiResponse.message);
      }
    } catch (error) {
      ToastService.toastError("$error");
    }
    state = state.copyWith(isBusy: false);
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

final pharmacyUploadControllerProvider = NotifierProvider.autoDispose
    .family<PharmacyUploadController, PharmacyUploadState, Vendor>(
      PharmacyUploadController.new,
    );
