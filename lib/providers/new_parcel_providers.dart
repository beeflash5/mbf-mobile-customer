import 'dart:async';
import 'dart:developer';

import 'package:dartx/dartx.dart' hide IterableForEachIndexed;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_place_picker_mb_v2/google_maps_place_picker.dart';
import 'package:jiffy/jiffy.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/bottom_sheet/parcel_location_picker_option.bottomsheet.dart';
import 'package:fuodz/models/coupon.dart';
import 'package:fuodz/models/delivery_address.dart';
import 'package:fuodz/models/order_stop.dart';
import 'package:fuodz/models/package_checkout.dart';
import 'package:fuodz/models/package_type.dart';
import 'package:fuodz/models/payment_method.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/cart.service.dart';
import 'package:fuodz/services/checkout.request.dart';
import 'package:fuodz/models/address.dart';
import 'package:fuodz/services/location.service.dart';
import 'package:fuodz/services/location_picker.helper.dart';
import 'package:fuodz/services/package.request.dart';
import 'package:fuodz/services/payment.helper.dart';
import 'package:fuodz/services/payment_method.request.dart';
import 'package:fuodz/services/toast.service.dart';
import 'package:fuodz/services/validator.service.dart';
import 'package:fuodz/services/vendor.request.dart';
import 'package:fuodz/utils/app_routes.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/extensions/context.dart';

class NewParcelState {
  const NewParcelState({
    required this.packageCheckout,
    this.activeStep = 0,
    this.packageTypes = const [],
    this.selectedPackageType,
    this.vendors = const [],
    this.selectedVendor,
    this.requireParcelInfo = true,
    this.pickupLocation,
    this.dropoffLocation,
    this.selectedPickupDate,
    this.pickupDate,
    this.selectedPickupTime,
    this.pickupTime,
    this.isScheduled = false,
    this.availableTimeSlots = const [],
    this.openedRecipientFormIndex = 0,
    this.paymentMethods = const [],
    this.selectedPaymentMethod,
    this.canApplyCoupon = false,
    this.coupon,
    this.isBusy = false,
    this.packageTypesBusy = false,
    this.vendorsBusy = false,
    this.paymentBusy = false,
    this.packageCheckoutBusy = false,
    this.couponBusy = false,
    this.couponError,
    this.deliveryaddress,
  });

  final PackageCheckout packageCheckout;
  final int activeStep;
  final List<PackageType> packageTypes;
  final PackageType? selectedPackageType;
  final List<Vendor> vendors;
  final Vendor? selectedVendor;
  final bool requireParcelInfo;
  final DeliveryAddress? pickupLocation;
  final DeliveryAddress? dropoffLocation;
  final DateTime? selectedPickupDate;
  final String? pickupDate;
  final TimeOfDay? selectedPickupTime;
  final String? pickupTime;
  final bool isScheduled;
  final List<String> availableTimeSlots;
  final int openedRecipientFormIndex;
  final List<PaymentMethod> paymentMethods;
  final PaymentMethod? selectedPaymentMethod;
  final bool canApplyCoupon;
  final Coupon? coupon;
  final bool isBusy;
  final bool packageTypesBusy;
  final bool vendorsBusy;
  final bool paymentBusy;
  final bool packageCheckoutBusy;
  final bool couponBusy;
  final Object? couponError;
  final DeliveryAddress? deliveryaddress;

  NewParcelState copyWith({
    PackageCheckout? packageCheckout,
    int? activeStep,
    List<PackageType>? packageTypes,
    Object? selectedPackageType = _sentinel,
    List<Vendor>? vendors,
    Object? selectedVendor = _sentinel,
    bool? requireParcelInfo,
    Object? pickupLocation = _sentinel,
    Object? dropoffLocation = _sentinel,
    Object? selectedPickupDate = _sentinel,
    Object? pickupDate = _sentinel,
    Object? selectedPickupTime = _sentinel,
    Object? pickupTime = _sentinel,
    bool? isScheduled,
    List<String>? availableTimeSlots,
    int? openedRecipientFormIndex,
    List<PaymentMethod>? paymentMethods,
    Object? selectedPaymentMethod = _sentinel,
    bool? canApplyCoupon,
    Object? coupon = _sentinel,
    bool? isBusy,
    bool? packageTypesBusy,
    bool? vendorsBusy,
    bool? paymentBusy,
    bool? packageCheckoutBusy,
    bool? couponBusy,
    Object? couponError = _sentinel,
    Object? deliveryaddress = _sentinel,
  }) {
    return NewParcelState(
      packageCheckout: packageCheckout ?? this.packageCheckout,
      activeStep: activeStep ?? this.activeStep,
      packageTypes: packageTypes ?? this.packageTypes,
      selectedPackageType:
          identical(selectedPackageType, _sentinel)
              ? this.selectedPackageType
              : selectedPackageType as PackageType?,
      vendors: vendors ?? this.vendors,
      selectedVendor:
          identical(selectedVendor, _sentinel)
              ? this.selectedVendor
              : selectedVendor as Vendor?,
      requireParcelInfo: requireParcelInfo ?? this.requireParcelInfo,
      pickupLocation:
          identical(pickupLocation, _sentinel)
              ? this.pickupLocation
              : pickupLocation as DeliveryAddress?,
      dropoffLocation:
          identical(dropoffLocation, _sentinel)
              ? this.dropoffLocation
              : dropoffLocation as DeliveryAddress?,
      selectedPickupDate:
          identical(selectedPickupDate, _sentinel)
              ? this.selectedPickupDate
              : selectedPickupDate as DateTime?,
      pickupDate:
          identical(pickupDate, _sentinel)
              ? this.pickupDate
              : pickupDate as String?,
      selectedPickupTime:
          identical(selectedPickupTime, _sentinel)
              ? this.selectedPickupTime
              : selectedPickupTime as TimeOfDay?,
      pickupTime:
          identical(pickupTime, _sentinel)
              ? this.pickupTime
              : pickupTime as String?,
      isScheduled: isScheduled ?? this.isScheduled,
      availableTimeSlots: availableTimeSlots ?? this.availableTimeSlots,
      openedRecipientFormIndex:
          openedRecipientFormIndex ?? this.openedRecipientFormIndex,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      selectedPaymentMethod:
          identical(selectedPaymentMethod, _sentinel)
              ? this.selectedPaymentMethod
              : selectedPaymentMethod as PaymentMethod?,
      canApplyCoupon: canApplyCoupon ?? this.canApplyCoupon,
      coupon: identical(coupon, _sentinel) ? this.coupon : coupon as Coupon?,
      isBusy: isBusy ?? this.isBusy,
      packageTypesBusy: packageTypesBusy ?? this.packageTypesBusy,
      vendorsBusy: vendorsBusy ?? this.vendorsBusy,
      paymentBusy: paymentBusy ?? this.paymentBusy,
      packageCheckoutBusy: packageCheckoutBusy ?? this.packageCheckoutBusy,
      couponBusy: couponBusy ?? this.couponBusy,
      couponError:
          identical(couponError, _sentinel) ? this.couponError : couponError,
      deliveryaddress:
          identical(deliveryaddress, _sentinel)
              ? this.deliveryaddress
              : deliveryaddress as DeliveryAddress?,
    );
  }

  static const _sentinel = Object();
}

class NewParcelController
    extends AutoDisposeFamilyNotifier<NewParcelState, VendorType> {
  final PackageRequest _packageRequest = PackageRequest();
  final VendorRequest _vendorRequest = VendorRequest();
  final CheckoutRequest _checkoutRequest = CheckoutRequest();
  final PaymentMethodRequest _paymentOptionRequest = PaymentMethodRequest();

  final PageController pageController = PageController();
  final GlobalKey<FormState> deliveryInfoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> recipientInfoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> packageInfoFormKey = GlobalKey<FormState>();

  final TextEditingController fromTEC = TextEditingController();
  final TextEditingController toTEC = TextEditingController();
  final TextEditingController dateTEC = TextEditingController();
  final TextEditingController timeTEC = TextEditingController();
  final TextEditingController packageWeightTEC = TextEditingController();
  final TextEditingController packageHeightTEC = TextEditingController();
  final TextEditingController packageWidthTEC = TextEditingController();
  final TextEditingController packageLengthTEC = TextEditingController();
  final TextEditingController noteTEC = TextEditingController();
  final TextEditingController couponTEC = TextEditingController();

  final List<TextEditingController> toTECs = [];
  final List<TextEditingController> recipientNamesTEC = [
    TextEditingController(),
  ];
  final List<TextEditingController> recipientPhonesTEC = [
    TextEditingController(),
  ];
  final List<TextEditingController> recipientNotesTEC = [
    TextEditingController(),
  ];

  Function? onFinish;
  StreamSubscription? _currentLocationChangeStream;

  String get currencySymbol => AppStrings.currencySymbol;

  @override
  NewParcelState build(VendorType arg) {
    ref.onDispose(() {
      _currentLocationChangeStream?.cancel();
      pageController.dispose();
      fromTEC.dispose();
      toTEC.dispose();
      dateTEC.dispose();
      timeTEC.dispose();
      packageWeightTEC.dispose();
      packageHeightTEC.dispose();
      packageWidthTEC.dispose();
      packageLengthTEC.dispose();
      noteTEC.dispose();
      couponTEC.dispose();
      for (final c in toTECs) {
        c.dispose();
      }
      for (final c in recipientNamesTEC) {
        c.dispose();
      }
      for (final c in recipientPhonesTEC) {
        c.dispose();
      }
      for (final c in recipientNotesTEC) {
        c.dispose();
      }
    });
    return NewParcelState(packageCheckout: PackageCheckout());
  }

  Future<void> initialise() async {
    await CartServices.clearCart();
    _currentLocationChangeStream = LocationService.currenctAddressSubject.stream
        .listen((location) async {
          var addr = state.deliveryaddress ?? DeliveryAddress();
          addr.address = location.addressLine;
          addr.latitude = location.coordinates?.latitude;
          addr.longitude = location.coordinates?.longitude;
          addr = await LocationPickerHelper.getLocationCityName(addr);
          state = state.copyWith(deliveryaddress: addr);
        });
    if (AppStrings.enableParcelMultipleStops) {
      state.packageCheckout.stopsLocation = [];
      addNewStop();
    }
    await fetchParcelTypes();
  }

  Future<void> fetchParcelTypes() async {
    state = state.copyWith(packageTypesBusy: true);
    try {
      final types = await _packageRequest.fetchPackageTypes();
      state = state.copyWith(packageTypes: types);
    } catch (e) {
      // ignore: avoid_print
      print("NewParcel fetchParcelTypes error: $e");
    }
    state = state.copyWith(packageTypesBusy: false);
  }

  Future<void> fetchParcelVendors() async {
    state = state.copyWith(
      vendors: [],
      selectedVendor: null,
      vendorsBusy: true,
    );
    try {
      final allStops = getAllStops();
      final vendors = await _vendorRequest.fetchParcelVendors(
        vendorTypeId: arg.id,
        packageTypeId: state.selectedPackageType!.id,
        stops: allStops,
      );
      state = state.copyWith(vendors: vendors);
      if (AppStrings.enableSingleVendor && vendors.isNotEmpty) {
        changeSelectedVendor(vendors.first);
      }
    } catch (e) {
      // ignore: avoid_print
      print("NewParcel fetchParcelVendors error: $e");
    }
    state = state.copyWith(vendorsBusy: false);
  }

  Future<void> fetchPaymentOptions() async {
    state = state.copyWith(paymentBusy: true);
    try {
      final methods = await _paymentOptionRequest.getPaymentOptions(
        vendorId: state.selectedVendor?.id,
      );
      state = state.copyWith(paymentMethods: methods);
    } catch (e) {
      // ignore: avoid_print
      print("NewParcel fetchPaymentOptions error: $e");
    }
    state = state.copyWith(paymentBusy: false);
  }

  void nextForm(int index) {
    state = state.copyWith(activeStep: index);
    pageController.jumpToPage(index);
  }

  void changeSelectedPackageType(PackageType packageType) {
    state.packageCheckout.packageType = packageType;
    state = state.copyWith(selectedPackageType: packageType);
  }

  void showNoVendorSelectedError() {
    ToastService.toastError("No vendor for the selected package type.".tr());
    if (kDebugMode) {
      ToastService.toastError(
        "DEBUG: Ensure you have at least one vendor under the package type. Also if you are using single mode, make sure the package types are attached to the active vendor."
            .tr(),
      );
    }
  }

  void changeSelectedVendor(Vendor vendor) {
    state.packageCheckout.vendor = vendor;
    final vendorPackagePricing = vendor.packageTypesPricing.firstOrNullWhere(
      (e) => e.packageTypeId == state.selectedPackageType?.id,
    );
    final requireParcelInfo = vendorPackagePricing?.fieldRequired ?? true;
    state = state.copyWith(
      selectedVendor: vendor,
      requireParcelInfo: requireParcelInfo,
    );
  }

  Future<bool> _ensureAuthenticated(BuildContext context) async {
    if (AuthServices.authenticated()) return true;
    final result = await context.pushRoute(AppRoutes.loginRoute);
    if (result == null || (result is bool && !result)) return false;
    return true;
  }

  Future<void> changePickupAddress(BuildContext context) async {
    if (!await _ensureAuthenticated(context)) return;
    final result = await _pickFromMap(context);
    if (result == null) return;
    state.packageCheckout.pickupLocation = result;
    fromTEC.text = result.address ?? "";
    state = state.copyWith(pickupLocation: result);
  }

  Future<void> changeDropOffAddress(BuildContext context) async {
    if (!await _ensureAuthenticated(context)) return;
    final result = await _pickFromMap(context);
    if (result == null) return;
    state.packageCheckout.dropoffLocation = result;
    toTEC.text = result.address ?? "";
    state = state.copyWith(dropoffLocation: result);
  }

  Future<void> changeStopDeliveryAddress(
    BuildContext context,
    int index,
  ) async {
    if (!await _ensureAuthenticated(context)) return;
    final result = await _pickFromMap(context);
    if (result == null) return;
    toTECs[index].text = result.address ?? "";
    final stop = OrderStop();
    stop.deliveryAddress = result;
    state.packageCheckout.stopsLocation?[index] = stop;
    state = state.copyWith(dropoffLocation: result);
  }

  Future<void> manualChangeStopDeliveryAddress(
    BuildContext context,
    int index,
    DeliveryAddress deliveryAddress,
  ) async {
    if (!await _ensureAuthenticated(context)) return;
    toTECs[index].text = deliveryAddress.address ?? "";
    final stop = OrderStop();
    stop.deliveryAddress = deliveryAddress;
    state.packageCheckout.stopsLocation?[index] = stop;
    state = state.copyWith(dropoffLocation: deliveryAddress);
  }

  Future<void> handlePickupStop(BuildContext context) async {
    final result = await _showLocationPickerOptionBottomsheet(context);
    if (result is bool && result) {
      await changePickupAddress(context);
    } else if (result is DeliveryAddress) {
      result.name = result.address;
      state.packageCheckout.pickupLocation = result;
      fromTEC.text = result.address ?? "";
      state = state.copyWith(pickupLocation: result);
    }
  }

  Future<void> handleDropoffStop(BuildContext context) async {
    if (recipientNamesTEC.length < 2) {
      recipientNamesTEC.add(TextEditingController());
      recipientPhonesTEC.add(TextEditingController());
      recipientNotesTEC.add(TextEditingController());
    }
    final result = await _showLocationPickerOptionBottomsheet(context);
    if (result is bool && result) {
      await changeDropOffAddress(context);
    } else if (result is DeliveryAddress) {
      state.packageCheckout.dropoffLocation = result;
      toTEC.text = result.address ?? "";
      state = state.copyWith(dropoffLocation: result);
    }
  }

  Future<void> handleOtherStop(BuildContext context, int index) async {
    final result = await _showLocationPickerOptionBottomsheet(context);
    if (result is bool && result) {
      await changeStopDeliveryAddress(context, index);
    } else if (result is DeliveryAddress) {
      await manualChangeStopDeliveryAddress(context, index, result);
    }
  }

  Future<dynamic> _showLocationPickerOptionBottomsheet(
    BuildContext context,
  ) async {
    final result = await showModalBottomSheet(
      context: context,
      builder: (ctx) => ParcelLocationPickerOptionBottomSheet(),
    );
    if (result != null && result is int) {
      if (result == 1) {
        return await _pickFromMap(context);
      }
      return true;
    }
    return false;
  }

  Future<DeliveryAddress?> _pickFromMap(BuildContext context) async {
    final result = await LocationPickerHelper.newPlacePicker(context);
    if (result is PickResult) {
      var addr = DeliveryAddress();
      addr.name = result.formattedAddress;
      addr.address = result.formattedAddress;
      addr.latitude = result.geometry?.location.lat;
      addr.longitude = result.geometry?.location.lng;
      state = state.copyWith(isBusy: true);
      addr = await LocationPickerHelper.getLocationCityName(addr);
      state = state.copyWith(isBusy: false, deliveryaddress: addr);
      return addr;
    } else if (result is Address) {
      var addr = DeliveryAddress();
      addr.name = result.addressLine;
      addr.address = result.addressLine;
      addr.latitude = result.coordinates?.latitude;
      addr.longitude = result.coordinates?.longitude;
      addr.city = result.locality;
      addr.state = result.adminArea;
      addr.country = result.countryName;
      state = state.copyWith(isBusy: true);
      addr = await LocationPickerHelper.getLocationCityName(addr);
      state = state.copyWith(isBusy: false, deliveryaddress: addr);
      return addr;
    }
    return null;
  }

  void toggleScheduledOrder(bool? value) {
    final isScheduled = value ?? false;
    final co = state.packageCheckout;
    co.isScheduled = isScheduled;
    co.date = null;
    co.deliverySlotDate = null;
    co.time = null;
    co.deliverySlotTime = null;
    state = state.copyWith(
      isScheduled: isScheduled,
      packageCheckout: co,
      pickupDate: null,
      pickupTime: null,
    );
  }

  void changeSelectedDeliveryDate(String dateStr, int index) {
    final co = state.packageCheckout;
    co.deliverySlotDate = dateStr;
    co.date = dateStr;
    final times = state.selectedVendor?.deliverySlots[index].times ?? [];
    state = state.copyWith(
      packageCheckout: co,
      pickupDate: dateStr,
      availableTimeSlots: times,
    );
  }

  void changeSelectedDeliveryTime(String time) {
    final co = state.packageCheckout;
    co.deliverySlotTime = time;
    co.time = time;
    state = state.copyWith(packageCheckout: co, pickupTime: time);
  }

  Future<void> changeDropOffDate(BuildContext context) async {
    final result = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        Duration(
          days:
              state.selectedVendor?.packageTypesPricing.first.maxBookingDays ??
              7,
        ),
      ),
      initialDate: state.selectedPickupDate ?? DateTime.now(),
    );
    if (result != null) {
      final pickupDate = Jiffy.parseFromMillisecondsSinceEpoch(
        result.millisecondsSinceEpoch,
      ).format(pattern: "yyyy-MM-dd");
      dateTEC.text =
          Jiffy.parseFromMillisecondsSinceEpoch(
            result.millisecondsSinceEpoch,
          ).yMMMMd;
      state.packageCheckout.date = pickupDate;
      state = state.copyWith(
        selectedPickupDate: result,
        pickupDate: pickupDate,
      );
    }
  }

  Future<void> changeDropOffTime(BuildContext context) async {
    final result = await showTimePicker(
      context: context,
      initialTime: state.selectedPickupTime ?? TimeOfDay.now(),
    );
    if (result != null) {
      final pickupTime = result.format(context);
      timeTEC.text = pickupTime;
      try {
        state.packageCheckout.time = "${result.hour}:${result.minute}";
      } catch (_) {
        state.packageCheckout.time = pickupTime;
      }
      state = state.copyWith(
        selectedPickupTime: result,
        pickupTime: pickupTime,
      );
    }
  }

  void changeSelectedPaymentMethod(PaymentMethod paymentMethod) {
    state.packageCheckout.paymentMethod = paymentMethod;
    state = state.copyWith(selectedPaymentMethod: paymentMethod);
  }

  Future<void> validateDeliveryInfo() async {
    if (!(deliveryInfoFormKey.currentState?.validate() ?? false)) return;
    if (AppStrings.enableSingleVendor) {
      state = state.copyWith(vendorsBusy: true);
      await fetchParcelVendors();
      state = state.copyWith(vendorsBusy: false);
      if (AppStrings.enableSingleVendor && state.selectedVendor == null) {
        showNoVendorSelectedError();
      } else {
        nextForm(2);
      }
    } else {
      nextForm(2);
      fetchParcelVendors();
    }
  }

  void validateRecipientInfo(BuildContext context) {
    recipientInfoFormKey.currentState?.validate();
    var dataRequired = false;
    for (final c in recipientNamesTEC) {
      if (c.text.isEmpty) {
        dataRequired = true;
        break;
      }
    }
    if (!dataRequired) {
      for (final c in recipientPhonesTEC) {
        if (c.text.isEmpty || FormValidator.validatePhone(c.text) != null) {
          dataRequired = true;
          break;
        }
      }
    }
    if (dataRequired) {
      AlertService.warning(
        title: "Fill Contact Info".tr(),
        text:
            "Please ensure you fill in contact info for all added stops. Thank you"
                .tr(),
        onConfirm: () => FocusScope.of(context).requestFocus(FocusNode()),
      );
      return;
    }
    if (recipientInfoFormKey.currentState?.validate() ?? false) {
      nextForm(!state.requireParcelInfo ? 5 : 4);
    }
  }

  void validateDeliveryParcelInfo(BuildContext context) {
    if (!(packageInfoFormKey.currentState?.validate() ?? false)) return;
    final co = state.packageCheckout;
    co.weight = packageWeightTEC.text;
    co.width = packageWidthTEC.text;
    co.length = packageLengthTEC.text;
    co.height = packageHeightTEC.text;
    FocusScope.of(context).unfocus();
    nextForm(5);
  }

  void validateSelectedVendor(BuildContext context) {
    final v = state.selectedVendor;
    if (v == null) return;
    final co = state.packageCheckout;
    if (!v.isOpen &&
        (co.deliverySlotDate == null ||
            co.deliverySlotTime == null ||
            co.deliverySlotDate.isEmptyOrNull ||
            co.deliverySlotTime.isEmptyOrNull)) {
      if (v.allowScheduleOrder) {
        AlertService.error(
          text: "Vendor is not open. Please schedule order".tr(),
        );
      } else {
        AlertService.error(text: "Vendor is not open".tr());
      }
      return;
    }
    FocusScope.of(context).unfocus();
    nextForm(3);
  }

  void setOpenedRecipientFormIndex(int index) {
    state = state.copyWith(openedRecipientFormIndex: index);
  }

  void notifyExternalChange() {
    state = state.copyWith();
  }

  Future<void> prepareOrderSummary() async {
    nextForm(6);
    await fetchPaymentOptions();
    state = state.copyWith(packageCheckoutBusy: true);
    try {
      final allStops = getAllStops();
      for (int index = 0; index < recipientNamesTEC.length; index++) {
        if (index >= allStops.length) break;
        allStops[index].stopId = allStops[index].deliveryAddress?.id;
        allStops[index].name = recipientNamesTEC[index].text;
        allStops[index].phone = recipientPhonesTEC[index].text;
        allStops[index].note = recipientNotesTEC[index].text;
        allStops[index].deliveryAddress ??= DeliveryAddress();
      }
      state.packageCheckout.allStops = allStops;
      final mPackageCheckout = await _packageRequest.parcelSummary(
        vendorId: state.selectedVendor?.id,
        packageTypeId: state.selectedPackageType?.id,
        stops: allStops,
        packageWeight: packageWeightTEC.text,
        couponCode: couponTEC.text,
      );
      state.packageCheckout.copyWith(packageCheckout: mPackageCheckout);
    } catch (error) {
      AlertService.error(title: "Checkout".tr(), text: "$error");
    }
    state = state.copyWith(packageCheckoutBusy: false);
  }

  void couponCodeChange(String code) {
    state = state.copyWith(canApplyCoupon: code.isNotEmpty);
  }

  Future<bool> applyCoupon() async {
    state = state.copyWith(couponBusy: true);
    try {
      await prepareOrderSummary();
      state = state.copyWith(couponError: null, couponBusy: false);
      return true;
    } catch (error) {
      // ignore: avoid_print
      print("NewParcel applyCoupon error: $error");
      state = state.copyWith(couponError: error, couponBusy: false);
      return false;
    }
  }

  void clearCoupon() {
    couponTEC.text = "";
    state = state.copyWith(coupon: null);
    applyCoupon();
  }

  Future<void> initiateOrderPayment(BuildContext context) async {
    AlertService.loading(
      barrierDismissible: false,
      title: "Checkout".tr(),
      text: "Processing order. Please wait...".tr(),
    );
    try {
      final apiResponse = await _checkoutRequest.newPackageOrder(
        state.packageCheckout,
        note: noteTEC.text,
      );
      if (context.mounted) context.pop();
      if (apiResponse.allGood) {
        final paymentLink = apiResponse.body["link"].toString();
        if (paymentLink.isNotEmpty) {
          _showOrdersTab(context);
          await PaymentHelper.openWebpageLink(context, paymentLink);
        } else {
          AlertService.success(
            title: "Checkout".tr(),
            text: apiResponse.message,
            barrierDismissible: false,
            onConfirm: () => _showOrdersTab(context),
          );
        }
      } else {
        AlertService.error(title: "Checkout".tr(), text: apiResponse.message);
      }
    } catch (error) {
      log("Error ==> $error");
      if (context.mounted) context.pop();
      AlertService.error(title: "Checkout".tr(), text: "$error");
    }
  }

  void _showOrdersTab(BuildContext context) {
    context.pop();
    AppService().changeHomePageIndex(index: 1);
  }

  void addNewStop() {
    if (AppStrings.maxParcelStops > (toTECs.length - 1)) {
      toTECs.add(TextEditingController());
      recipientNamesTEC.add(TextEditingController());
      recipientPhonesTEC.add(TextEditingController());
      recipientNotesTEC.add(TextEditingController());
      state.packageCheckout.stopsLocation?.add(OrderStop());
      state = state.copyWith();
    }
  }

  void removeStop(int index) {
    toTECs.removeAt(index);
    recipientNamesTEC.removeAt(index);
    recipientPhonesTEC.removeAt(index);
    recipientNotesTEC.removeAt(index);
    state.packageCheckout.stopsLocation?.removeAt(index);
    state = state.copyWith();
  }

  List<OrderStop> getAllStops() {
    final allStops = <OrderStop>[];
    final co = state.packageCheckout;
    if (co.pickupLocation != null) {
      allStops.add(OrderStop(deliveryAddress: co.pickupLocation));
    }
    if (co.stopsLocation != null && co.stopsLocation!.isNotEmpty) {
      allStops.addAll(co.stopsLocation!);
    }
    if (co.dropoffLocation != null) {
      allStops.add(OrderStop(deliveryAddress: co.dropoffLocation));
    }
    return allStops;
  }

  void setupReceiverPaymentMethod() {
    final cash = state.paymentMethods.firstOrNullWhere((e) => e.isCash == 1);
    if (cash != null) {
      changeSelectedPaymentMethod(cash);
    }
  }
}

final newParcelControllerProvider = NotifierProvider.autoDispose
    .family<NewParcelController, NewParcelState, VendorType>(
      NewParcelController.new,
    );
