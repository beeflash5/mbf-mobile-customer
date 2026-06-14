import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/card/order_summary.dart';
import 'package:fuodz/component/currency_conversion_notice.dart';
import 'package:fuodz/component/custom_text_form_field.dart';
import 'package:fuodz/models/checkout.dart';
import 'package:fuodz/pages/checkout/widgets/driver_cash_delivery_note.view.dart';
import 'package:fuodz/pages/checkout/widgets/order_delivery_address.view.dart';
import 'package:fuodz/pages/checkout/widgets/payment_methods.view.dart';
import 'package:fuodz/pages/checkout/widgets/schedule_order.view.dart';
import 'package:fuodz/providers/checkout_providers.dart';
import 'package:fuodz/services/app_currency_system.service.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/extensions/string.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({required this.checkout, super.key});

  final CheckOut checkout;

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(checkoutControllerProvider(widget.checkout).notifier)
          .initialise();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkoutControllerProvider(widget.checkout));
    final controller = ref.read(
      checkoutControllerProvider(widget.checkout).notifier,
    );
    final vendor = state.vendor;
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: "Checkout".tr(),
      body: VStack([
        UiSpacer.verticalSpace(),
        if (vendor != null)
          OrderDeliveryAddressPickerView(
            vendor: vendor,
            isPickup: state.isPickup,
            onTogglePickup: controller.togglePickupStatus,
            onPickAddress: () => controller.pickDeliveryAddress(context),
            deliveryAddress: state.deliveryAddress,
            deliveryAddressOutOfRange: state.deliveryAddressOutOfRange,
          ),
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
            guestCountController: controller.guestCountTEC,
            onSelectTable: controller.selectTableSelecte,
            isFoodOverride: state.isFoodOrder,
          ),

        if (state.hasAgeRestricted)
          VStack([
            "Batas Usia (Age Limit)".tr().text.lg.bold.color(Vx.red800).make(),
            UiSpacer.verticalSpace(space: 10),
            HStack([
              Checkbox(
                value: state.ageConfirmed,
                onChanged: controller.toggleAgeConfirmed,
                activeColor: Vx.red600,
              ).pOnly(right: 10),
              VStack([
                "I confirm that I am old enough to purchase the products in this order.".tr().text.sm.color(Vx.red700).make(),
                "(Saya mengonfirmasi bahwa saya sudah cukup umur untuk membeli produk ini.)".tr().text.xs.color(Vx.red700).make(),
              ]).expand(),
            ]).onInkTap(() => controller.toggleAgeConfirmed(!state.ageConfirmed)),
          ])
          .p12()
          .box
          .roundedSM
          .color(Vx.red50)
          .border(color: Vx.red200)
          .make()
          .pOnly(bottom: Vx.dp20),        CustomTextFormField(
          labelText: "Note".tr(),
          textEditingController: controller.noteTEC,
        ).pOnly(bottom: Vx.dp20),
        /* 
        Visibility(
          visible: !state.isPickup && state.tableSelected == null,
          child: CustomTextFormField(
            labelText: "Driver Tip".tr() + " (${AppStrings.currencySymbol})",
            textEditingController: controller.driverTipTEC,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onFieldSubmitted: (_) => controller.updateTotalOrderSummary(),
          ).pOnly(bottom: Vx.dp20),
        ),
        */
        Visibility(
          visible: state.canSelectPaymentOption,
          child: PaymentMethodsView(
            paymentMethods: state.paymentMethods,
            selectedPaymentMethod: state.selectedPaymentMethod,
            onSelected: controller.changeSelectedPaymentMethod,
          ),
        ),
        if (vendor != null)
          OrderSummary(
            subTotal: state.checkout.subTotal,
            discount:
                (state.checkout.coupon?.for_delivery ?? false)
                    ? null
                    : state.checkout.discount,
            deliveryDiscount:
                (state.checkout.coupon?.for_delivery ?? false)
                    ? state.checkout.deliveryDiscount
                    : null,
            deliveryFee: state.checkout.deliveryFee,
            tax: state.checkout.tax,
            vendorTax:
                state.checkout.tax_rate?.currencyValueFormat() ?? vendor.tax,
            driverTip: double.tryParse(controller.driverTipTEC.text) ?? 0.00,
            total: state.checkout.totalWithTip,
            fees: vendor.fees,
            mCurrencySymbol: AppStrings.currentCurrencySymbol,
            allowConvert: true,
            // Show DP breakdown for food reservations (matching Next.js)
            dp:
                (state.isFoodOrder &&
                        state.isScheduled &&
                        (state.checkout.dp ?? 0) > 0)
                    ? state.checkout.dp
                    : null,
            sisa:
                (state.isFoodOrder &&
                        state.isScheduled &&
                        (state.checkout.sisa ?? 0) > 0)
                    ? state.checkout.sisa
                    : null,
          ),
        if (state.checkout.deliveryAddress != null)
          CheckoutDriverCashDeliveryNoticeView(state.checkout.deliveryAddress!),
        HStack([
          Checkbox(
            value: state.paymentTermsAgreed,
            onChanged:
                (value) => controller.setPaymentTermsAgreed(value ?? false),
          ),
          "By proceeding to place order, you agree that you are bound by our"
              .tr()
              .richText
              .withTextSpanChildren([
                "  ".textSpan.make(),
                "Terms & Conditions"
                    .tr()
                    .textSpan
                    .color(AppColor.primaryColor)
                    .bold
                    .underline
                    .tap(() => controller.openPaymentTerms(context))
                    .make(),
                "  ".textSpan.make(),
              ])
              .make()
              .expand(),
        ], alignment: MainAxisAlignment.start).py(20),
        if (AppCurrencySystemService().currentCurrencyCode !=
            AppStrings.currencyCode)
          CurrencyConversionNotice(
            convertedAmount: state.checkout.totalWithTip.convertCurrency,
            originalAmount: state.checkout.totalWithTip,
            baseCurrency: AppStrings.currencyCode,
          ),
        CustomButton(
          title: "PLACE ORDER".tr().padRight(14),
          icon: Icons.shopping_basket,
          onPressed:
              state.paymentTermsAgreed
                  ? () => controller.placeOrder(context)
                  : null,
          loading: state.isBusy,
        ).centered().py16(),
      ]).p20().scrollVertical().pOnly(bottom: context.mq.viewInsets.bottom),
    );
  }
}
