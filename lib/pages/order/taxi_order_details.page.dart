import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/card/order_summary.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/pages/cart/widgets/amount_tile.dart';
import 'package:fuodz/pages/order/widgets/basic_taxi_trip_info.view.dart';
import 'package:fuodz/pages/order/widgets/order_driver_info.view.dart';
import 'package:fuodz/pages/order/widgets/order_payment_info.view.dart';
import 'package:fuodz/pages/order/widgets/taxi_order_trip_verification.view.dart';
import 'package:fuodz/providers/order_details_providers.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/extensions/string.dart';
import 'package:fuodz/utils/ui_spacer.dart';

import 'widgets/taxi_trip_map.preview.dart';

class TaxiOrderDetailPage extends ConsumerStatefulWidget {
  const TaxiOrderDetailPage({super.key, required this.order});

  final Order order;

  @override
  ConsumerState<TaxiOrderDetailPage> createState() =>
      _TaxiOrderDetailPageState();
}

class _TaxiOrderDetailPageState extends ConsumerState<TaxiOrderDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(orderDetailsControllerProvider(widget.order).notifier)
          .initialise();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderDetailsControllerProvider(widget.order));
    final controller = ref.read(
      orderDetailsControllerProvider(widget.order).notifier,
    );
    final order = state.order;
    final String currencySymbol = order.taxiOrder!.currencySymbol;

    return BasePage(
      title: "Trip Details".tr(),
      elevation: 0,
      showAppBar: true,
      showLeadingAction: true,
      isLoading: state.isBusy,
      body:
          VStack([
            TaxiTripMapPreview(order),
            BasicTaxiTripInfoView(order),
            UiSpacer.vSpace(),
            OrderPaymentInfoView(
                  order: order,
                  onOpenPaymentMethodSelection:
                      () => controller.openPaymentMethodSelection(context),
                  paymentStatusBusy: state.paymentStatusBusy,
                )
                .wFull(context)
                .box
                .shadowXs
                .color(context.theme.colorScheme.surface)
                .make(),
            OrderDriverInfoView(
              order,
              rateDriverAction: () => controller.rateDriver(context),
            ),
            TaxiOrderTripVerificationView(order),
            OrderSummary(
                  subTotal: order.subTotal!,
                  discount: order.discount ?? 0,
                  driverTip: order.tip ?? 0,
                  tax: order.tax,
                  total: order.total!,
                  mCurrencySymbol:
                      "${order.taxiOrder!.currency != null ? order.taxiOrder!.currency!.symbol : AppStrings.currencySymbol}",
                  customWidget: VStack([
                    AmountTile(
                      "Base Fare".tr(),
                      "$currencySymbol ${order.taxiOrder!.base_fare ?? 0}"
                          .currencyFormat(currencySymbol),
                    ).py2(),
                    AmountTile(
                      ("Trip Distance".tr() + " (Km)"),
                      "${order.taxiOrder!.trip_distance ?? 0}  (${order.taxiOrder!.distance_fare ?? 0}/Km)",
                    ).py2(),
                    AmountTile(
                      "Trip Duration".tr(),
                      "${order.taxiOrder!.trip_time ?? 0}  (${order.taxiOrder!.time_fare ?? 0}/${'Minute'.tr()})",
                    ).py2(),
                    DottedLine(
                      dashColor: context.textTheme.bodyLarge!.color!,
                    ).py8(),
                  ]),
                )
                .px20()
                .py12()
                .box
                .shadowXs
                .color(context.theme.colorScheme.surface)
                .make()
                .pSymmetric(v: 20),
            (context.percentHeight * 20).heightBox,
          ]).scrollVertical(),
      bottomSheet:
          order.isScheduled
              ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.backgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      offset: const Offset(0, 0),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: SafeArea(
                  child: CustomButton(
                    loading: state.orderBusy,
                    color: AppColor.closeColor,
                    title: "Cancel Order".tr(),
                    onPressed: () => controller.cancelOrder(context),
                  ),
                ),
              )
              : null,
    );
  }
}
