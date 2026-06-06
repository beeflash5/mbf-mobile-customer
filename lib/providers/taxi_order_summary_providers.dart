import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:fuodz/models/coupon.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/pages/shared/payment_method_selection.page.dart';
import 'package:fuodz/pages/taxi/apply_discount.page.dart';
import 'package:fuodz/providers/taxi_providers.dart';
import 'package:fuodz/utils/app_ui_sizes.dart';
import 'package:fuodz/utils/extensions/context.dart';

class TaxiOrderSummaryState {
  const TaxiOrderSummaryState({
    this.customViewHeight = AppUISizes.taxiNewOrderSummaryHeight,
  });

  final double customViewHeight;

  TaxiOrderSummaryState copyWith({double? customViewHeight}) =>
      TaxiOrderSummaryState(
        customViewHeight: customViewHeight ?? this.customViewHeight,
      );
}

class TaxiOrderSummaryController
    extends AutoDisposeFamilyNotifier<TaxiOrderSummaryState, VendorType> {
  final PanelController panelController = PanelController();

  @override
  TaxiOrderSummaryState build(VendorType arg) {
    return const TaxiOrderSummaryState();
  }

  void initialise() {}

  void updateLoadingHeight() {
    state = state.copyWith(
      customViewHeight: AppUISizes.taxiNewOrderHistoryHeight,
    );
  }

  void resetStateViewHeight([double height = 0]) {
    state = state.copyWith(
      customViewHeight: AppUISizes.taxiNewOrderIdleHeight + height,
    );
  }

  Future<void> closePanel(BuildContext context) async {
    clearFocus(context);
    await panelController.close();
  }

  void clearFocus(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  Future<void> openPanel() async {
    await panelController.open();
  }

  Future<void> openPaymentMethodSelection(BuildContext context) async {
    final taxi = ref.read(taxiControllerProvider(arg).notifier);
    final taxiState = ref.read(taxiControllerProvider(arg));
    if (taxiState.paymentMethods.isEmpty) {
      await taxi.fetchTaxiPaymentOptions();
    }
    final mPaymentMethod = await context.push(
      (ctx) => PaymentMethodSelectionPage(
        list: ref.read(taxiControllerProvider(arg)).paymentMethods,
      ),
    );
    if (mPaymentMethod != null) {
      taxi.changeSelectedPaymentMethod(mPaymentMethod, callTotal: false);
    }
  }

  Future<void> openCouponDialog(BuildContext context) async {
    final taxi = ref.read(taxiControllerProvider(arg).notifier);
    final taxiState = ref.read(taxiControllerProvider(arg));
    final result = await context.pushWidget(ApplyDiscountPage(coupon: taxiState.coupon));
    if (result != null && result is Coupon) {
      // Set coupon by triggering apply through TaxiController fields.
      taxi.couponTEC.text = result.code;
      await taxi.applyCoupon();
    } else if (result != null && result is bool && result == false) {
      taxi.couponTEC.clear();
      await taxi.applyCoupon();
    }
  }
}

final taxiOrderSummaryControllerProvider = NotifierProvider.autoDispose
    .family<TaxiOrderSummaryController, TaxiOrderSummaryState, VendorType>(
  TaxiOrderSummaryController.new,
);
