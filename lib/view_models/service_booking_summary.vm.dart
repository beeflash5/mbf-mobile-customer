import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fuodz/models/checkout.dart';
import 'package:fuodz/models/coupon.dart';
import 'package:fuodz/models/guest_model.dart';
import 'package:fuodz/models/payment_method.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/requests/cart.request.dart';
import 'package:fuodz/requests/payment_method.request.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/view_models/checkout_base.vm.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:fuodz/extensions/context.dart';
import 'package:fuodz/models/banner.dart' as ban;

class ServiceBookingSummaryViewModel extends CheckoutBaseViewModel {
  //
  List<Map> calFees = [];
  //
  ServiceBookingSummaryViewModel(BuildContext context, this.service) {
    this.viewContext = context;
    vendor = service!.vendor;
    AppService().vendorId = vendor?.id;
    fetchPaymentOptions();

    //prepare checkout
    checkout = CheckOut();
    final subTotal = double.parse(
      ((service!.showDiscount ? service!.discountPrice : service!.price) *
              (!(service!.isFixed) ? (service!.selectedQty ?? 1) : 1))
          .toString(),
    );
    checkout!.subTotal = subTotal;
    //add price of selected options
    service!.selectedOptions.forEach((option) {
      checkout!.subTotal += option.price;
    });
  }
  //
  CartRequest cartRequest = CartRequest();
  PaymentMethodRequest paymentOptionRequest = PaymentMethodRequest();
  TextEditingController noteTEC = TextEditingController();
  TextEditingController tatto_placement = TextEditingController();
  TextEditingController tatto_size = TextEditingController();
  //coupons
  bool canApplyCoupon = false;
  Coupon? coupon;
  TextEditingController couponTEC = TextEditingController();

  //
  CheckOut? checkout = CheckOut();
  Service? service;
  double subTotal = 0.0;
  double total = 0.0;
  ban.Banner? banner;
  int? vendor_type_id;

  File? newPhoto;

  final currencySymbol = AppStrings.currencySymbol;
  //
  List<PaymentMethod> paymentMethods = [];
  PaymentMethod? selectedPaymentMethod;
  String selectTattoType = 'Black / Grey';

  List<GuestModel> guests = [];

  int durationQty = 1;
  String? guidSelected;

  void setGuide(val) {
    guidSelected = val;
    notifyListeners();
  }

  void incrementDuration() {
    durationQty++;
    updateTotalOrderSummary();
    notifyListeners();
  }

  void decrementDuration() {
    if (durationQty > 1) {
      durationQty--;
      updateTotalOrderSummary();
    }

    notifyListeners();
  }

  void initialise() async {
    // ambil campaign/banner dari local storage
    final prefs = await SharedPreferences.getInstance();

    final campaignData = prefs.getString('campaign_data');

    if (campaignData != null) {
      banner = ban.Banner.fromJSON(jsonDecode(campaignData));

      await prefs.remove('campaign_data');
    }

    guests =
        (service?.agebasePrice ?? []).asMap().entries.map((entry) {
          try {
            final index = entry.key;
            final guest = entry.value;

            return GuestModel(
              id: guest.id ?? 0,
              name: guest.name ?? '',
              description: guest.description ?? '',
              qty: index == 0 ? 1 : 0,
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

    if (service?.guide?.isNotEmpty ?? false) {
      guidSelected = service!.guide!.first.lang;
    }
    vendor_type_id = service?.vendor_type_id ?? service?.vendor.vendorTypeId;

    notifyListeners();

    fetchPaymentOptions();
    updateTotalOrderSummary();
    getDateUse();
  }

  void increment(int id) {
    for (int i = 0; i < guests.length; i++) {
      if (guests[i].id == id) {
        guests[i].qty++;
        updateTotalOrderSummary();
        break;
      }
    }

    notifyListeners();
  }

  void decrement(int id) {
    for (int i = 0; i < guests.length; i++) {
      if (guests[i].id == id && guests[i].qty > 0) {
        guests[i].qty--;
        updateTotalOrderSummary();
        break;
      }
    }

    notifyListeners();
  }

  onselectTypeTato(String? val) {
    if (val == null) return;
    selectTattoType = val;
    notifyListeners();
  }

  final picker = ImagePicker();

  void changePhoto() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      newPhoto = File(pickedFile.path);
    } else {
      newPhoto = null;
    }

    notifyListeners();
  }

  getDateUse() async {
    if (vendor == null) return;
    if (checkout == null) return;
    //
    setBusyForObject(getDateUse, true);
    try {
      final response = await vendorRequest.vendorGetDateUse(vendor!.id);

      date_full.clear();
      date_full = List<String>.from(response.body);

      print("testing ${date_full}");

      notifyListeners();
    } catch (error) {
      print("Error Getting Vendor Details ==> $error");
    }
    setBusyForObject(getDateUse, false);
  }

  //get payment options
  fetchPaymentOptions({int? vendorId}) async {
    setBusyForObject(paymentMethods, true);
    try {
      paymentMethods = await paymentOptionRequest.getPaymentOptions(
        vendorId: vendorId ?? service!.vendor.id,
      );
      //
      clearErrors();
    } catch (error) {
      print("Error getting payment methods ==> $error");
    }
    setBusyForObject(paymentMethods, false);
  }

  isSelected(PaymentMethod paymentMethod) {
    return paymentMethod.id == selectedPaymentMethod?.id;
  }

  @override
  changeSelectedPaymentMethod(
    PaymentMethod? paymentMethod, {
    bool callTotal = true,
  }) {
    selectedPaymentMethod = paymentMethod;
    checkout?.paymentMethod = paymentMethod;
    notifyListeners();
  }

  couponCodeChange(String code) {
    canApplyCoupon = code.isNotBlank;
    notifyListeners();
  }

  //
  applyCoupon() async {
    //
    setBusyForObject("coupon", true);
    try {
      coupon = await cartRequest.fetchCoupon(
        couponTEC.text,
        vendorTypeId: vendor!.vendorType.id,
      );
      //
      if (coupon == null) {
        throw "Invalid coupon code".tr();
      }
      //
      if (coupon!.useLeft <= 0) {
        throw "Coupon use limit exceeded".tr();
      } else if (coupon!.expired) {
        throw "Coupon has expired".tr();
      }
      clearErrors();
      //re-calculate the cart price with coupon
      //
      if (coupon!.percentage == 1) {
        checkout!.discount = (coupon!.discount / 100) * checkout!.subTotal;
      } else {
        checkout!.discount = coupon!.discount;
      }
      //
      updateTotalOrderSummary();
    } catch (error) {
      print("error ==> $error");
      setErrorForObject("coupon", error);
    }
    setBusyForObject("coupon", false);
  }

  //
  @override
  updateTotalOrderSummary() async {
    final guestTotal = guests.fold<double>(
      0,
      (sum, item) => sum + (item.qty * item.price),
    );
    //
    Map<String, dynamic> payload = {
      "delivery_address_id": deliveryAddress?.id,
      "coupon_code": checkout!.coupon?.code ?? "",
      "vendor_id": vendor!.id,
      "service_id": service!.id,
      "options_ids": service!.selectedOptions.map((e) => e.id).toList(),
      "qty": durationQty, // service!.selectedQty ?? 1,
      "guest_total": guestTotal,
    };

    setBusy(true);
    try {
      final mCheckout = await checkoutRequest.serviceOrderSummary(payload);
      checkout!.copyWith(
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
    } catch (error) {
      print("Error getting order summary ==> $error");
      toastError("$error");
    }
    setBusy(false);
    //
    notifyListeners();
  }

  //
  placeOrder({bool ignore = false}) async {
    service?.selectedQty = durationQty;
    //
    if (isScheduled && checkout!.deliverySlotDate.isEmptyOrNull) {
      //
      AlertService.error(
        title: "Schedule Date".tr(),
        text: "Please select your desire order date".tr(),
      );
    } else if (isScheduled && checkout!.deliverySlotTime.isEmptyOrNull) {
      //
      AlertService.error(
        title: "Schedule Time".tr(),
        text: "Please select your desire order time".tr(),
      );
    } else if (!isPickup && service!.location && deliveryAddress == null) {
      //
      AlertService.error(
        title: "Booking address".tr(),
        text: "Please select booking address".tr(),
      );
    } else if (service!.location && delievryAddressOutOfRange && !isPickup) {
      //
      AlertService.error(
        title: "Booking address".tr(),
        text: "Booking address is out of vendor booking range".tr(),
      );
    } else if (selectedPaymentMethod == null && vendor_type_id != 13) {
      AlertService.error(
        title: "Payment Methods".tr(),
        text: "Please select a payment method".tr(),
      );
    } else if (!ignore && !verifyVendorOrderAmountCheck()) {
      print("Failed");
    }
    //process the new order
    else {
      if (vendor_type_id == 13) {
        if (tatto_placement.text.isEmpty) {
          AlertService.error(
            title: "Tattoo".tr(),
            text: "Please select tattoo placement".tr(),
          );
          return;
        }

        if (tatto_size.text.isEmpty) {
          AlertService.error(
            title: "Tattoo".tr(),
            text: "Please select tattoo size".tr(),
          );
          return;
        }
      }

      if (guests.length > 0) {
        final guestTotal = guests.fold<double>(
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
      processOrderPlacement();
    }
  }

  //
  processOrderPlacement() async {
    //process the order placement
    setBusy(true);
    //set the total with discount as the new total
    checkout!.total = checkout!.totalWithTip;
    //
    final apiResponse = await checkoutRequest.newServiceOrder(
      checkout!,
      fees: calFees,
      service: service!,
      service_amount: checkout!.subTotal,
      note: noteTEC.text,
      tatto_placement: tatto_placement.text,
      tatto_size: tatto_size.text,
      tatto_type_select: selectTattoType,
      attach: newPhoto,
      banner_id: banner?.id,
      guide: guidSelected,
      guest: guests,
    );
    //not error
    if (apiResponse.allGood) {
      //cash payment

      final paymentLink = apiResponse.body["link"].toString();

      if (!paymentLink.isEmptyOrNull) {
        viewContext.pop();
        showOrdersTab(context: viewContext);
        openWebpageLink(paymentLink);
      }
      //cash payment
      else {
        AlertService.success(
          title: "Checkout".tr(),
          text: apiResponse.message,
          barrierDismissible: false,
          result: true,
          onConfirm: () {
            showOrdersTab(context: viewContext);
          },
        );
      }
    } else {
      AlertService.error(title: "Checkout".tr(), text: apiResponse.message);
    }
    setBusy(false);
  }
}
