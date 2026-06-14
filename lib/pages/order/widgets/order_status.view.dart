import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/extensions/string.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class OrderStatusView extends StatelessWidget {
  const OrderStatusView({
    super.key,
    required this.order,
    required this.vendorTypeId,
    required this.onCheckIn,
    required this.onReschedule,
    required this.onOpenOrderPayment,
    required this.onTrackOrder,
    this.checkInBusy = false,
    this.orderBusy = false,
  });

  final Order order;
  final int? vendorTypeId;
  final VoidCallback onCheckIn;
  final VoidCallback onReschedule;
  final VoidCallback onOpenOrderPayment;
  final VoidCallback onTrackOrder;
  final bool checkInBusy;
  final bool orderBusy;

  @override
  Widget build(BuildContext context) {
    return VStack([
      HStack([
        VStack([
          "Status".tr().text.gray500.medium.sm.make(),
          "${order.status.tr()}".capitalized.text
              .color(AppColor.getStausColor(order.status))
              .medium
              .xl
              .make(),
        ]).expand(),
        vendorTypeId == 13
            ? VStack([
              "Cash Payment".tr().text.gray500.medium.sm.make(),
              "(After Service)".text
                  .color(AppColor.getStausColor(order.paymentStatus))
                  .medium
                  .xl
                  .make(),
            ]).expand()
            : VStack([
              "Payment Status".tr().text.gray500.medium.sm.make(),
              "${order.paymentStatus.tr().capitalized}".text
                  .color(AppColor.getStausColor(order.paymentStatus))
                  .medium
                  .xl
                  .make(),
            ]).expand(),
      ]).pOnly(bottom: Vx.dp20),
      CustomVisibilty(
        visible: order.isPackageDelivery,
        child: VStack([
          "Order Payer".tr().text.medium.make(),
          (order.payer == "1" ? "Sender" : "Receiver")
              .tr()
              .text
              .xl
              .semiBold
              .make(),
          UiSpacer.verticalSpace(),
        ]),
      ),
      if (order.pickupDate.isNotNullOrEmpty &&
          order.pickupTime.isNotNullOrEmpty)
        HStack([
          VStack([
            "Scheduled Date".tr().text.gray500.medium.sm.make(),
            "${Jiffy.parse(order.pickupDate!).format(pattern: "dd MMM yyyy")}"
                .text
                .color(AppColor.getStausColor(order.status))
                .medium
                .xl
                .make()
                .pOnly(bottom: Vx.dp20),
          ]).expand(),
          VStack([
            "Scheduled Time".tr().text.gray500.medium.sm.make(),
            "${Jiffy.parse(order.pickupTime!).format(pattern: "hh:mm a")}".text
                .color(AppColor.getStausColor(order.status))
                .medium
                .xl
                .make()
                .pOnly(bottom: Vx.dp20),
          ]).expand(),
        ])
      else
        UiSpacer.emptySpace(),
      if (order.reser_table != null &&
          order.reser_table != 0 &&
          order.reser_guest != null)
        HStack([
          VStack([
            "Table Number".tr().text.gray500.medium.sm.make(),
            "${order.reser_table}".text
                .color(AppColor.getStausColor(order.status))
                .medium
                .xl
                .make()
                .pOnly(bottom: Vx.dp20),
          ]).expand(),
          VStack([
            "Number of Guests".tr().text.gray500.medium.sm.make(),
            "${order.reser_guest}".text
                .color(AppColor.getStausColor(order.status))
                .medium
                .xl
                .make()
                .pOnly(bottom: Vx.dp20),
          ]).expand(),
        ])
      else
        UiSpacer.emptySpace(),
      if ([
            'scheduled',
            'pending',
            'preparing',
            'ready',
          ].contains(order.status) &&
          order.dp_status == 1 &&
          order.vendor?.vendorType.slug == 'food')
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (order.check_in == 0)
              Column(
                children: [
                  CustomButton(
                    title: "Check-in",
                    onPressed: order.checkin_status ? onCheckIn : null,
                    loading: checkInBusy,
                  ),
                  const SizedBox(height: 4),
                  "Check-in available at ${Jiffy.parse(order.pickupDate!).format(pattern: "dd MMM yyyy")} ${Jiffy.parse(order.pickupTime!).format(pattern: "hh:mm a")}"
                      .text
                      .make(),
                  const SizedBox(height: 10),
                  "Please check in upon arrival to avoid automatic cancellation after 30 minutes."
                      .text
                      .make(),
                ],
              )
            else
              Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'Check-in Success',
                        style: TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Divider(color: Colors.grey.shade400),
                ],
              ),
          ],
        ),
      if (order.pickupDate != null &&
          order.pickupTime != null &&
          order.vendor?.vendorType.slug == 'food' &&
          order.can_reschedule)
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            CustomButton(title: "Reschedule", onPressed: onReschedule),
          ],
        ),
      if (['ready'].contains(order.status) &&
          order.dp_status == 1 &&
          order.sisa_status == 0 &&
          order.vendor?.vendorType.slug == 'food')
        Column(
          children: [
            const SizedBox(height: 10),
            "Remaining Balance".text.make(),
            "${order.sisa}"
                .currencyValueFormat()
                .text
                .color(AppColor.primaryColor)
                .xl3
                .make(),
            const SizedBox(height: 10),
            CustomButton(
              title: "Complate Payment".tr(),
              titleStyle: context.textTheme.bodyLarge!.copyWith(
                color: Colors.white,
              ),
              icon: Icons.credit_card,
              iconSize: 18,
              onPressed: onOpenOrderPayment,
              shapeRadius: 0,
            ),
            const SizedBox(height: 10),
          ],
        ),
      if (order.reser_table == null && order.reser_guest == null)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            "Order Status tracking".tr().text.make(),
            Timeline.tileBuilder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              builder: TimelineTileBuilder.connected(
                contentsAlign: ContentsAlign.basic,
                nodePositionBuilder: (context, index) => 0.00,
                indicatorPositionBuilder: (context, index) => 0.35,
                indicatorBuilder: (context, index) {
                  final orderStatus = order.totalStatuses[index];
                  return (orderStatus.passed ?? true)
                      ? DotIndicator(
                        color: AppColor.primaryColor,
                        size: 24,
                        child: const Icon(
                          Icons.check,
                          size: 12,
                          color: Colors.white,
                        ),
                      )
                      : OutlinedDotIndicator(
                        color: AppColor.primaryColor,
                        size: 24,
                      );
                },
                connectorBuilder:
                    (context, index, connectorType) =>
                        SolidLineConnector(color: AppColor.primaryColor),
                contentsBuilder:
                    (context, index) => VStack([
                      Text(
                        '${order.totalStatuses[index].name}'.tr().capitalized,
                        style: context.textTheme.bodyLarge!.copyWith(
                          fontSize: Vx.dp16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "${order.totalStatuses[index].createdAt != null ? Jiffy.parseFromDateTime(order.totalStatuses[index].createdAt!).format(pattern: "dd MMM, yyy 'at' hh:mm a") : ''}",
                        style: context.textTheme.bodyLarge!.copyWith(
                          fontSize: Vx.dp16,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      if (order.totalStatuses[index].createdAt != null &&
                          "${order.totalStatuses[index].name}" == "enroute" &&
                          order.status == "enroute" &&
                          AppStrings.enableOrderTracking &&
                          (order.dropoffLocation != null ||
                              order.deliveryAddress != null) &&
                          order.driverId != null)
                        CustomButton(
                          title: "Track Order".tr(),
                          icon: Icons.map,
                          onPressed: onTrackOrder,
                          loading: orderBusy,
                        ).p20()
                      else
                        UiSpacer.emptySpace(),
                    ]).p(Vx.dp20),
                itemCount: order.totalStatuses.length,
              ),
            ),
          ],
        ),
    ]);
  }
}
