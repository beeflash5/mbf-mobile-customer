import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/models/banner.dart' as ban;
import 'package:fuodz/models/checkout.dart';
import 'package:fuodz/models/coupon.dart';
import 'package:fuodz/models/delivery_address.dart';
import 'package:fuodz/models/guest_model.dart';
import 'package:fuodz/models/payment_method.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/services/cart.request.dart';
import 'package:fuodz/services/checkout.request.dart';
import 'package:fuodz/services/checkout_shared.helper.dart';
import 'package:fuodz/services/payment.helper.dart';
import 'package:fuodz/services/toast.service.dart';
import 'package:fuodz/utils/app_routes.dart';

class ServiceBookingSummaryState {
  const ServiceBookingSummaryState({
    required this.service,
    required this.checkout,
    this.vendor,
    this.vendorTypeId,
    this.banner,
    this.coupon,
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
    this.canApplyCoupon = false,
    this.couponError,
    this.couponBusy = false,
    this.durationQty = 1,
    this.guests = const [],
    this.selectTattoType = 'Black / Grey',
    this.guidSelected,
    this.newPhoto,
    this.ageConfirmed = false,
  });

  final Service service;
  final CheckOut checkout;
  final Vendor? vendor;
  final int? vendorTypeId;
  final ban.Banner? banner;
  final Coupon? coupon;
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
  final bool canApplyCoupon;
  final Object? couponError;
  final bool couponBusy;
  final int durationQty;
  final List<GuestModel> guests;
  final String selectTattoType;
  final String? guidSelected;
  final File? newPhoto;
  final bool ageConfirmed;

  ServiceBookingSummaryState copyWith({
    Service? service,
    CheckOut? checkout,
    Vendor? vendor,
    Object? vendorTypeId = _sentinel,
    Object? banner = _sentinel,
    Object? coupon = _sentinel,
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
    bool? canApplyCoupon,
    Object? couponError = _sentinel,
    bool? couponBusy,
    int? durationQty,
    List<GuestModel>? guests,
    String? selectTattoType,
    Object? guidSelected = _sentinel,
    Object? newPhoto = _sentinel,
    bool? ageConfirmed,
  }) {
    return ServiceBookingSummaryState(
      service: service ?? this.service,
      checkout: checkout ?? this.checkout,
      vendor: vendor ?? this.vendor,
      vendorTypeId:
          identical(vendorTypeId, _sentinel)
              ? this.vendorTypeId
              : vendorTypeId as int?,
      banner:
          identical(banner, _sentinel) ? this.banner : banner as ban.Banner?,
      coupon: identical(coupon, _sentinel) ? this.coupon : coupon as Coupon?,
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
      canApplyCoupon: canApplyCoupon ?? this.canApplyCoupon,
      couponError:
          identical(couponError, _sentinel) ? this.couponError : couponError,
      couponBusy: couponBusy ?? this.couponBusy,
      durationQty: durationQty ?? this.durationQty,
      guests: guests ?? this.guests,
      selectTattoType: selectTattoType ?? this.selectTattoType,
      guidSelected:
          identical(guidSelected, _sentinel)
              ? this.guidSelected
              : guidSelected as String?,
      newPhoto:
          identical(newPhoto, _sentinel) ? this.newPhoto : newPhoto as File?,
      ageConfirmed: ageConfirmed ?? this.ageConfirmed,
    );
  }

  static const _sentinel = Object();
}

class ServiceBookingSummaryController
    extends AutoDisposeFamilyNotifier<ServiceBookingSummaryState, Service> {
  final CheckoutRequest _checkoutRequest = CheckoutRequest();
  final CartRequest _cartRequest = CartRequest();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController noteTEC = TextEditingController();
  final TextEditingController tattooPlacementTEC = TextEditingController();
  final TextEditingController tattooSizeTEC = TextEditingController();
  final TextEditingController couponTEC = TextEditingController();
  final TextEditingController guestCountTEC = TextEditingController();

  @override
  ServiceBookingSummaryState build(Service arg) {
    ref.onDispose(() {
      noteTEC.dispose();
      tattooPlacementTEC.dispose();
      tattooSizeTEC.dispose();
      couponTEC.dispose();
      guestCountTEC.dispose();
    });
    final co = CheckOut();
    final subTotal = double.parse(
      ((arg.showDiscount ? arg.discountPrice : arg.price) *
              (!(arg.isFixed) ? (arg.selectedQty ?? 1) : 1))
          .toString(),
    );
    co.subTotal = subTotal;
    for (final option in arg.selectedOptions) {
      co.subTotal += option.price;
    }
    AppService().vendorId = arg.vendor.id;

    final bool isFoodOrBeverage = arg.vendor.isFoodOrBeverage;
    if (isFoodOrBeverage) {
      co.isScheduled = true;
    }

    return ServiceBookingSummaryState(
      service: arg,
      checkout: co,
      vendor: arg.vendor,
      isScheduled: isFoodOrBeverage,
    );
  }

  Future<void> initialise() async {
    final prefs = await SharedPreferences.getInstance();
    final campaignData = prefs.getString('campaign_data');
    ban.Banner? banner;
    if (campaignData != null) {
      banner = ban.Banner.fromJSON(jsonDecode(campaignData));
      await prefs.remove('campaign_data');
    }
    final guests =
        (state.service.agebasePrice ?? []).asMap().entries.map((entry) {
          try {
            final guest = entry.value;
            return GuestModel(
              id: guest.id,
              name: guest.name,
              description: guest.description,
              qty: entry.key == 0 ? 1 : 0,
              price: double.tryParse(guest.price.toString()) ?? 0,
            );
          } catch (e) {
            debugPrint("Guest Parse Error ==> $e");
            return GuestModel(
              id: 0,
              name: '',
              description: '',
              qty: 0,
              price: 0,
            );
          }
        }).toList();
    String? guidSelected;
    if (state.service.guide?.isNotEmpty ?? false) {
      guidSelected = state.service.guide!.first.lang;
    }
    final vendorTypeId =
        state.service.vendor_type_id ?? state.service.vendor.vendorTypeId;
    state = state.copyWith(
      banner: banner,
      guests: guests,
      guidSelected: guidSelected,
      vendorTypeId: vendorTypeId,
    );
    await Future.wait([
      _fetchVendorDetails(),
      _fetchPaymentOptions(),
      _fetchDateUse(),
    ]);
    await _updateTotalOrderSummary();
  }

  Future<void> _fetchVendorDetails() async {
    if (state.vendor == null) return;
    try {
      final originalSlots = state.vendor!.deliverySlots;
      final fullVendor = await CheckoutSharedHelpers.fetchVendorDetails(
        state.vendor!,
        params: {"type": "full"}, // Ask for full details
      );

      state = state.copyWith(vendor: fullVendor);
    } catch (e) {
      debugPrint("ServiceBooking fetchVendorDetails error: $e");
    }
  }

  Future<void> _fetchPaymentOptions() async {
    try {
      final methods = await CheckoutSharedHelpers.getPaymentOptions(
        vendorId: state.vendor?.id,
        isPickup: state.isPickup,
      );
      state = state.copyWith(paymentMethods: methods);
    } catch (e) {
      // ignore: avoid_print
      print("ServiceBooking fetchPaymentOptions error: $e");
    }
  }

  Future<void> _fetchDateUse() async {
    if (state.vendor == null) return;
    try {
      final dates = await CheckoutSharedHelpers.fetchDateUse(state.vendor!.id);
      state = state.copyWith(dateFull: dates);
    } catch (e) {
      // ignore: avoid_print
      print("ServiceBooking fetchDateUse error: $e");
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
      print("ServiceBooking fetchTableAvailability error: $e");
    }
    state = state.copyWith(loadingTables: false);
  }

  Future<void> _updateTotalOrderSummary() async {
    if (state.vendor == null) return;
    final guestTotal = state.guests.fold<double>(
      0,
      (sum, item) => sum + (item.qty * item.price),
    );
    final payload = {
      "delivery_address_id": state.deliveryAddress?.id,
      "coupon_code": state.checkout.coupon?.code ?? "",
      "vendor_id": state.vendor!.id,
      "service_id": state.service.id,
      "options_ids": state.service.selectedOptions.map((e) => e.id).toList(),
      "qty": state.durationQty,
    };
    if (guestTotal > 0) {
      payload["guest_total"] = guestTotal;
    }
    state = state.copyWith(isBusy: true);
    try {
      final mCheckout = await _checkoutRequest.serviceOrderSummary(payload);
      final co = state.checkout;

      final bool hasGuests = state.guests.isNotEmpty;
      final bool isTattoo = state.vendorTypeId == 13;
      final double taxRate =
          mCheckout.tax_rate ??
          (double.tryParse(state.vendor!.tax ?? "") ?? 0.0);

      final double optionsTotal = state.service.selectedOptions.fold<double>(
        0,
        (sum, item) => sum + item.price,
      );
      final double optionsPrice = isTattoo ? 0 : optionsTotal;

      double subTotalOut;
      double taxOut;
      double totalOut;

      if (hasGuests && guestTotal > 0) {
        subTotalOut = guestTotal * state.durationQty;
        taxOut = subTotalOut * taxRate / 100;
        double feesTotal = 0.0;
        for (var f in state.vendor!.fees) {
          feesTotal += f.isPercentage ? (subTotalOut * f.value / 100) : f.value;
        }
        totalOut = subTotalOut + optionsPrice + taxOut + feesTotal;
      } else if (isTattoo) {
        subTotalOut = state.service.sellPrice;
        taxOut = subTotalOut * taxRate / 100;
        double feesTotal = 0.0;
        for (var f in state.vendor!.fees) {
          feesTotal += f.isPercentage ? (subTotalOut * f.value / 100) : f.value;
        }
        totalOut = subTotalOut + taxOut + feesTotal;
      } else {
        subTotalOut =
            mCheckout.subTotal ?? state.service.sellPrice * state.durationQty;
        taxOut = mCheckout.tax ?? (subTotalOut * taxRate / 100);
        totalOut = mCheckout.total ?? (subTotalOut + optionsPrice + taxOut);
      }

      co.copyWith(
        subTotal: subTotalOut,
        discount: mCheckout.discount,
        deliveryFee: mCheckout.deliveryFee,
        tax: taxOut,
        tax_rate: taxRate,
        total: totalOut,
        totalWithTip: totalOut,
        token: mCheckout.token,
        fees: mCheckout.fees,
      );
      state = state.copyWith(checkout: co);
    } catch (e) {
      // ignore: avoid_print
      print("ServiceBooking updateTotalOrderSummary error: $e");
      ToastService.toastError("$e");
    }
    state = state.copyWith(isBusy: false);
  }

  // -- Duration / guests / tattoo / banner --
  void incrementDuration() {
    state = state.copyWith(durationQty: state.durationQty + 1);
    _updateTotalOrderSummary();
  }

  void decrementDuration() {
    if (state.durationQty > 1) {
      state = state.copyWith(durationQty: state.durationQty - 1);
      _updateTotalOrderSummary();
    }
  }

  void incrementGuest(int id) {
    final next = [...state.guests];
    for (final g in next) {
      if (g.id == id) g.qty++;
    }
    state = state.copyWith(guests: next);
    _updateTotalOrderSummary();
  }

  void decrementGuest(int id) {
    final next = [...state.guests];
    for (final g in next) {
      if (g.id == id && g.qty > 0) g.qty--;
    }
    state = state.copyWith(guests: next);
    _updateTotalOrderSummary();
  }

  void onSelectTattooType(String? val) {
    if (val == null) return;
    state = state.copyWith(selectTattoType: val);
  }

  void setGuide(String? val) {
    state = state.copyWith(guidSelected: val);
  }

  Future<void> changePhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    photoSelected(picked);
  }

  void photoSelected(XFile? picked) {
    state = state.copyWith(newPhoto: picked != null ? File(picked.path) : null);
  }

  void toggleAgeConfirmed(bool? value) {
    state = state.copyWith(ageConfirmed: value ?? false);
  }

  // -- Pickup / schedule / time --
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
    _updateTotalOrderSummary();
  }

  void changeSelectedDeliveryDate(String dateStr, int index) {
    final co = state.checkout;
    co.deliverySlotDate = dateStr;
    co.deliverySlotTime = "";
    final times =
        state.vendor != null &&
                index >= 0 &&
                index < (state.vendor!.deliverySlots.length)
            ? state.vendor!.deliverySlots[index].times
            : <String>[];

    state = state.copyWith(checkout: co, availableTimeSlots: times);
    _fetchTimeUse(dateStr);
    _fetchTableAvailability();
  }

  Future<void> _fetchTimeUse(String dateStr) async {
    if (state.vendor == null) return;
    state = state.copyWith(loadingTime: true);
    try {
      final times = await CheckoutSharedHelpers.fetchTimeUse(
        state.vendor!.id,
        dateStr,
      );
      state = state.copyWith(timeFull: times, loadingTime: false);
    } catch (e) {
      state = state.copyWith(timeFull: [], loadingTime: false);
      debugPrint("ServiceBooking fetchTimeUse error: $e");
    }
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
    state = state.copyWith(selectedPaymentMethod: pm, checkout: co);
  }

  // -- Coupon --
  void couponCodeChange(String code) {
    state = state.copyWith(canApplyCoupon: code.isNotBlank);
  }

  Future<void> applyCoupon() async {
    state = state.copyWith(couponBusy: true);
    try {
      final coupon = await _cartRequest.fetchCoupon(
        couponTEC.text,
        vendorTypeId: state.vendor!.vendorType.id,
      );
      if (coupon.useLeft <= 0) {
        throw "Coupon use limit exceeded".tr();
      } else if (coupon.expired) {
        throw "Coupon has expired".tr();
      }
      final co = state.checkout;
      if (coupon.percentage == 1) {
        co.discount = (coupon.discount / 100) * co.subTotal;
      } else {
        co.discount = coupon.discount;
      }
      state = state.copyWith(coupon: coupon, checkout: co, couponError: null);
      _updateTotalOrderSummary();
    } catch (error) {
      // ignore: avoid_print
      print("ServiceBooking applyCoupon error: $error");
      state = state.copyWith(couponError: error);
    }
    state = state.copyWith(couponBusy: false);
  }

  bool _verifyVendorOrderAmountCheck() {
    final v = state.vendor;
    if (v?.minOrder != null && v!.minOrder! > state.checkout.subTotal) {
      AlertService.error(
        title: "Minimum Order Value".tr(),
        text:
            "Order value/amount is less than vendor accepted minimum order"
                .tr(),
      );
      return false;
    }
    if (v?.maxOrder != null && v!.maxOrder! < state.checkout.subTotal) {
      AlertService.error(
        title: "Maximum Order Value".tr(),
        text:
            "Order value/amount is more than vendor accepted maximum order"
                .tr(),
      );
      return false;
    }
    return true;
  }

  Future<void> placeOrder(BuildContext context, {bool ignore = false}) async {
    final service = state.service;
    service.selectedQty = state.durationQty;
    if (state.isScheduled && state.checkout.deliverySlotDate.isEmptyOrNull) {
      AlertService.error(
        title: "Schedule Date".tr(),
        text: "Please select your desire order date".tr(),
      );
      return;
    } else if (state.isScheduled &&
        state.checkout.deliverySlotTime.isEmptyOrNull) {
      AlertService.error(
        title: "Schedule Time".tr(),
        text: "Please select your desire order time".tr(),
      );
      return;
    }
    final isTattoo = state.vendor?.vendorType.slug.toLowerCase() == "tattoo";
    if (!state.isPickup &&
        service.location &&
        !isTattoo &&
        state.deliveryAddress == null) {
      AlertService.error(
        title: "Booking address".tr(),
        text: "Please select booking address".tr(),
      );
      return;
    } else if (service.location &&
        !isTattoo &&
        state.deliveryAddressOutOfRange &&
        !state.isPickup) {
      AlertService.error(
        title: "Booking address".tr(),
        text: "Booking address is out of vendor booking range".tr(),
      );
      return;
    } else if (state.selectedPaymentMethod == null &&
        state.vendorTypeId != 13) {
      AlertService.error(
        title: "Payment Methods".tr(),
        text: "Please select a payment method".tr(),
      );
      return;
    } else if (!ignore && !_verifyVendorOrderAmountCheck()) {
      return;
    }
    if (state.vendorTypeId == 13) {
      if (tattooPlacementTEC.text.isEmpty) {
        AlertService.error(
          title: "Tattoo".tr(),
          text: "Please select tattoo placement".tr(),
        );
        return;
      }
      if (tattooSizeTEC.text.isEmpty) {
        AlertService.error(
          title: "Tattoo".tr(),
          text: "Please select tattoo size".tr(),
        );
        return;
      }
    }
    if (state.guests.isNotEmpty) {
      final guestTotal = state.guests.fold<double>(
        0,
        (sum, item) => sum + (item.qty * item.price),
      );
      if (guestTotal == 0) {
        AlertService.error(
          title: "Guest".tr(),
          text: "Guest total has not been filled".tr(),
        );
        return;
      }
    }
    await _processOrderPlacement(context);
  }

  Future<void> _processOrderPlacement(BuildContext context) async {
    state = state.copyWith(isBusy: true);
    try {
      final co = state.checkout;
      if (state.vendorTypeId == 13) {
        // Auto-use Cash payment method (id 1) for Tattoo to match Next.js
        co.paymentMethod = PaymentMethod(
          id: 1,
          name: 'Cash',
          slug: 'cash',
          isActive: 1,
          isCash: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          formattedDate: '',
          instruction: '',
          photo: '',
          useExternalBrowser: false,
          useWallet: 0,
        );
      }
      co.total = co.totalWithTip;
      final apiResponse = await _checkoutRequest.newServiceOrder(
        co,
        service: state.service,
        service_amount: co.subTotal,
        note: noteTEC.text,
        tatto_type: "Portrait",
        tatto_placement: tattooPlacementTEC.text,
        tatto_size: tattooSizeTEC.text,
        tatto_type_select: state.selectTattoType,
        tatto_msg: noteTEC.text,
        attach: state.newPhoto,
        banner_id: state.banner?.id,
        guide: state.guidSelected,
        guest: state.guests,
        options_price:
            state.vendorTypeId == 13
                ? 0
                : state.service.selectedOptions.fold<double>(
                  0,
                  (sum, item) => sum + item.price,
                ),
        tax_rate: co.tax_rate,
      );
      if (apiResponse.allGood) {
        final paymentLink = apiResponse.body["link"].toString();
        if (!paymentLink.isEmptyOrNull) {
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
          _showOrdersTab(context: context);
          await PaymentHelper.openWebpageLink(context, paymentLink);
        } else {
          AlertService.success(
            title: "Checkout".tr(),
            text: apiResponse.message,
            barrierDismissible: false,
            result: true,
            onConfirm: () {
              _showOrdersTab(context: context);
            },
          );
        }
      } else {
        AlertService.error(title: "Checkout".tr(), text: apiResponse.message);
      }
    } catch (e) {
      // ignore: avoid_print
      print("ServiceBooking placeOrder error: $e");
      ToastService.toastError("$e");
    }
    state = state.copyWith(isBusy: false);
  }

  void _showOrdersTab({required BuildContext context}) {
    AppService().changeHomePageIndex(index: 2);
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).popUntil(
        (route) => route.settings.name == AppRoutes.homeRoute || route.isFirst,
      );
    }
  }
}

final serviceBookingSummaryControllerProvider = NotifierProvider.autoDispose
    .family<
      ServiceBookingSummaryController,
      ServiceBookingSummaryState,
      Service
    >(ServiceBookingSummaryController.new);
