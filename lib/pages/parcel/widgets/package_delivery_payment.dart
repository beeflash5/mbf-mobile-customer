import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/busy_indicator.dart';
import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/component/card/vendor_fees.view.dart';
import 'package:fuodz/component/custom_grid_view.dart';
import 'package:fuodz/component/list/payment_method.list_item.dart';
import 'package:fuodz/pages/cart/widgets/amount_tile.dart';
import 'package:fuodz/pages/parcel/widgets/form_step_controller.dart';
import 'package:fuodz/pages/parcel/widgets/package_delivery_discount_section.dart';
import 'package:fuodz/pages/parcel/widgets/parcel_order_payer.dart';
import 'package:fuodz/providers/new_parcel_providers.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/extensions/string.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class PackageDeliveryPayment extends StatelessWidget {
  const PackageDeliveryPayment({
    super.key,
    required this.state,
    required this.controller,
  });

  final NewParcelState state;
  final NewParcelController controller;

  @override
  Widget build(BuildContext context) {
    final co = state.packageCheckout;
    return VStack([
      VStack([
        UiSpacer.formVerticalSpace(),
        DottedBorder(
          dashPattern: const [5, 1],
          color: AppColor.accentColor,
          child:
              ParcelDeliveryDiscountSection(
                    state: state,
                    controller: controller,
                  )
                  .p20()
                  .box
                  .color(AppColor.accentColor.withOpacity(0.10))
                  .clip(Clip.antiAlias)
                  .roundedSM
                  .make(),
          radius: const Radius.circular(10),
          borderType: BorderType.RRect,
          padding: const EdgeInsets.all(0),
        ).py12(),
        const DottedLine().py12(),
        ParcelOrderPayer(state: state, controller: controller),
        const DottedLine().py12(),
        "Payment".tr().text.xl2.semiBold.make().py12(),
        CustomVisibilty(
          visible: state.packageCheckoutBusy,
          child: const BusyIndicator().centered(),
        ),
        CustomVisibilty(
          visible: !state.packageCheckoutBusy,
          child: VStack([
            AmountTile("Distance".tr(), "${co.distance?.numCurrency} km"),
            AmountTile(
              "Delivery Charges".tr(),
              "${controller.currencySymbol} ${co.deliveryFee}".currencyFormat(),
            ),
            AmountTile(
              "Package Size Charges".tr(),
              "${controller.currencySymbol} ${co.packageTypeFee}"
                  .currencyFormat(),
            ),
            const DottedLine().py12(),
            AmountTile(
              "Subtotal".tr(),
              "${controller.currencySymbol} ${co.subTotal ?? ''}"
                  .currencyFormat(),
            ),
            AmountTile(
              "Discount".tr(),
              "- ${controller.currencySymbol} ${co.discount}".currencyFormat(),
            ),
            const DottedLine().py12(),
            AmountTile(
              "Tax".tr() + " (${co.taxRate}%)",
              "${controller.currencySymbol} ${co.tax ?? ''}".currencyFormat(),
            ),
            VendorFeesView(fees: co.fees, subTotal: co.subTotal ?? 0),
            const DottedLine().py12(),
            AmountTile(
              "Total".tr(),
              "${controller.currencySymbol} ${co.total}".currencyFormat(),
            ),
          ]),
        ),
        UiSpacer.formVerticalSpace(),
        const Divider(),
        UiSpacer.formVerticalSpace(),
        "Payment Methods".tr().text.semiBold.xl.make(),
        "Please select your mode of payment".tr().text.lg.make(),
        CustomGridView(
          noScrollPhysics: true,
          dataSet: state.paymentMethods,
          childAspectRatio: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          itemBuilder: (context, index) {
            final paymentMethod = state.paymentMethods[index];
            return PaymentOptionListItem(
              paymentMethod,
              selected: paymentMethod == state.selectedPaymentMethod,
              onSelected: controller.changeSelectedPaymentMethod,
            );
          },
        ).pOnly(top: Vx.dp16),
      ]).scrollVertical().expand(),
      FormStepController(
        onPreviousPressed: () => controller.nextForm(5),
        nextTitle: "PLACE ORDER".tr(),
        nextBtnWidth: context.percentWidth * 45,
        onNextPressed: () => controller.initiateOrderPayment(context),
      ),
    ]);
  }
}
