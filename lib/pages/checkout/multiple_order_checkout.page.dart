import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/card/multiple_vendor_order_summary.dart';
import 'package:fuodz/component/currency_conversion_notice.dart';
import 'package:fuodz/component/custom_text_form_field.dart';
import 'package:fuodz/models/checkout.dart';
import 'package:fuodz/pages/checkout/widgets/driver_cash_delivery_note.view.dart';
import 'package:fuodz/pages/checkout/widgets/order_delivery_address.view.dart';
import 'package:fuodz/pages/checkout/widgets/payment_methods.view.dart';
import 'package:fuodz/pages/checkout/widgets/schedule_order.view.dart';
import 'package:fuodz/providers/multiple_checkout_providers.dart';
import 'package:fuodz/services/app_currency_system.service.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class MultipleOrderCheckoutPage extends ConsumerStatefulWidget {
  const MultipleOrderCheckoutPage({required this.checkout, super.key});

  final CheckOut checkout;

  @override
  ConsumerState<MultipleOrderCheckoutPage> createState() =>
      _MultipleOrderCheckoutPageState();
}

class _MultipleOrderCheckoutPageState
    extends ConsumerState<MultipleOrderCheckoutPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(multipleCheckoutControllerProvider(widget.checkout).notifier)
          .initialise();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state =
        ref.watch(multipleCheckoutControllerProvider(widget.checkout));
    final controller = ref.read(
      multipleCheckoutControllerProvider(widget.checkout).notifier,
    );
    final vendor = state.vendor;
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: "Multiple Order Checkout".tr(),
      body: VStack([
        UiSpacer.verticalSpace(),
        CustomTextFormField(
          labelText: "Note".tr(),
          textEditingController: controller.noteTEC,
        ),
        Divider(thickness: 2, height: 3, color: Vx.zinc300).py12(),
        if (vendor != null)
          ScheduleOrderView(
            vendor: vendor,
            isScheduled: state.isScheduled,
            onToggleScheduled: controller.toggleScheduledOrder,
            selectedDate: state.checkout.deliverySlotDate,
            selectedTime: state.checkout.deliverySlotTime,
            availableTimeSlots: state.availableTimeSlots,
            dateFull: state.dateFull,
            timeFull: state.timeFull,
            onSelectDate: controller.changeSelectedDeliveryDate,
            onSelectTime: controller.changeSelectedDeliveryTime,
            loadingTime: state.loadingTime,
            loadingTables: state.loadingTables,
            tables: state.tables,
            tableSelected: state.tableSelected,
            onSelectTable: controller.selectTableSelecte,
          ),
        if (vendor != null)
          OrderDeliveryAddressPickerView(
            vendor: vendor,
            isPickup: state.isPickup,
            onTogglePickup: controller.togglePickupStatus,
            onPickAddress: () => controller.pickDeliveryAddress(context),
            deliveryAddress: state.deliveryAddress,
            deliveryAddressOutOfRange: state.deliveryAddressOutOfRange,
          ),
        Visibility(
          visible: state.canSelectPaymentOption,
          child: PaymentMethodsView(
            paymentMethods: state.paymentMethods,
            selectedPaymentMethod: state.selectedPaymentMethod,
            onSelected: controller.changeSelectedPaymentMethod,
          ),
        ),
        MultipleVendorOrderSummary(
          subTotal: state.checkout.subTotal,
          deliveryFee: state.totalDeliveryFee,
          discount: (state.checkout.coupon?.for_delivery ?? false)
              ? null
              : state.checkout.discount,
          deliveryDiscount: (state.checkout.coupon?.for_delivery ?? false)
              ? state.checkout.discount
              : null,
          totalTax: state.taxes.sum(),
          totalFee: state.vendorFees.sum(),
          taxes: state.taxes,
          vendors: state.vendors,
          subtotals: state.subtotals,
          driverTip: double.tryParse(controller.driverTipTEC.text) ?? 0.00,
          total: state.checkout.total,
          mCurrencySymbol: AppStrings.currentCurrencySymbol,
          allowConvert: true,
        ),
        if (state.checkout.deliveryAddress != null)
          CheckoutDriverCashDeliveryNoticeView(state.checkout.deliveryAddress!),
        if (AppCurrencySystemService().currentCurrencyCode !=
            AppStrings.currencyCode)
          CurrencyConversionNotice(
            convertedAmount: state.checkout.totalWithTip.convertCurrency,
            originalAmount: state.checkout.totalWithTip,
            baseCurrency: AppStrings.currencyCode,
          ),
        CustomButton(
          title: "PLACE ORDER".tr().padRight(14),
          icon: Icons.credit_card,
          onPressed: () => controller.placeOrder(context),
          loading: state.isBusy,
        ).centered().py16(),
      ]).p20().scrollVertical().pOnly(bottom: context.mq.viewInsets.bottom),
    );
  }
}
