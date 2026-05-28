import 'package:dartx/dartx.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/extensions/string.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:fuodz/widgets/cards/custom.visibility.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/order_details.vm.dart';
import 'package:jiffy/jiffy.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderStatusView extends StatelessWidget {
  const OrderStatusView(this.vm, {Key? key}) : super(key: key);

  final OrderDetailsViewModel vm;
  @override
  Widget build(BuildContext context) {
    return VStack([
      HStack([
        //status
        VStack([
          "Status".tr().text.gray500.medium.sm.make(),
          "${vm.order.status.tr()}".capitalized.text
              .color(AppColor.getStausColor(vm.order.status))
              .medium
              .xl
              .make(),
        ]).expand(),

        //payment status
        vm.vendor_type_id == 13
            ? VStack([
              "Cash Payment".tr().text.gray500.medium.sm.make(),
              //
              "(After Service)".text
                  .color(AppColor.getStausColor(vm.order.paymentStatus))
                  .medium
                  .xl
                  .make(),
            ]).expand()
            : VStack([
              "Payment Status".tr().text.gray500.medium.sm.make(),
              //
              "${vm.order.paymentStatus.tr().capitalized}".text
                  .color(AppColor.getStausColor(vm.order.paymentStatus))
                  .medium
                  .xl
                  .make(),
            ]).expand(),
      ]).pOnly(bottom: Vx.dp20),

      //
      //show payer if order is parcel order
      CustomVisibilty(
        visible: vm.order.isPackageDelivery,
        child: VStack([
          "Order Payer".tr().text.medium.make(),
          (vm.order.payer == "1" ? "Sender" : "Receiver")
              .tr()
              .text
              .xl
              .semiBold
              .make(),
          UiSpacer.verticalSpace(),
        ]),
      ),

      //scheduled order info
      vm.order.pickupDate.isNotNullOrEmpty &&
              vm.order.pickupTime.isNotNullOrEmpty
          // vm.order.isScheduled
          ? HStack([
            //date
            VStack([
              //
              "Scheduled Date".tr().text.gray500.medium.sm.make(),
              // "${vm.order.pickupDate}"
              "${Jiffy.parse(vm.order.pickupDate!).format(pattern: "dd MMM yyyy")}"
                  .text
                  .color(AppColor.getStausColor(vm.order.status))
                  .medium
                  .xl
                  .make()
                  .pOnly(bottom: Vx.dp20),
            ]).expand(),
            //time
            VStack([
              //
              "Scheduled Time".tr().text.gray500.medium.sm.make(),
              "${Jiffy.parse(vm.order.pickupTime!).format(pattern: "hh:mm a")}"
                  .text
                  .color(AppColor.getStausColor(vm.order.status))
                  .medium
                  .xl
                  .make()
                  .pOnly(bottom: Vx.dp20),
            ]).expand(),
          ])
          : UiSpacer.emptySpace(),

      vm.order.reser_table != null &&
              vm.order.reser_table != 0 &&
              vm.order.reser_guest != null
          ? HStack([
            //date
            VStack([
              //
              "Table Number".tr().text.gray500.medium.sm.make(),
              "${vm.order.reser_table}".text
                  .color(AppColor.getStausColor(vm.order.status))
                  .medium
                  .xl
                  .make()
                  .pOnly(bottom: Vx.dp20),
              // "${vm.order.pickupDate}"
            ]).expand(),
            //time
            VStack([
              //
              "Number of Guests".tr().text.gray500.medium.sm.make(),
              "${vm.order.reser_guest}".text
                  .color(AppColor.getStausColor(vm.order.status))
                  .medium
                  .xl
                  .make()
                  .pOnly(bottom: Vx.dp20),
            ]).expand(),
          ])
          : UiSpacer.emptySpace(),

      ([
                'scheduled',
                'pending',
                'preparing',
                'ready',
              ].contains(vm.order.status) &&
              vm.order.dp_status == 1 &&
              vm.order.vendor?.vendorType.slug == 'food')
          ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              vm.order.check_in == 0
                  ? Column(
                    children: [
                      CustomButton(
                        title: "Check-in",
                        onPressed: vm.order.checkin_status ? vm.checkIn : null,
                        loading: vm.busy(vm.checkIn),
                      ),
                      SizedBox(height: 4),
                      "Check-in available at ${Jiffy.parse(vm.order.pickupDate!).format(pattern: "dd MMM yyyy")} ${Jiffy.parse(vm.order.pickupTime!).format(pattern: "hh:mm a")}"
                          .text
                          .make(),

                      SizedBox(height: 10),
                      "Please check in upon arrival to avoid automatic cancellation after 30 minutes."
                          .text
                          .make(),
                    ],
                  )
                  : Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'Check-in Success',
                            style: TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Divider(color: Colors.grey.shade400),
                    ],
                  ),
            ],
          )
          : SizedBox(),

      vm.order.pickupDate != null &&
              vm.order.pickupTime != null &&
              vm.order.vendor?.vendorType.slug == 'food' &&
              vm.order.can_reschedule
          ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              CustomButton(title: "Reschedule", onPressed: vm.rescedule),
            ],
          )
          : SizedBox(),

      (['ready'].contains(vm.order.status) &&
              vm.order.dp_status == 1 &&
              vm.order.sisa_status == 0 &&
              vm.order.vendor?.vendorType.slug == 'food')
          ? Column(
            children: [
              SizedBox(height: 10),

              "Remaining Balance".text.make(),
              "${vm.order.sisa}"
                  .currencyValueFormat()
                  .text
                  .color(AppColor.primaryColor)
                  .xl3
                  .make(),
              SizedBox(height: 10),
              CustomButton(
                title: "Complate Payment".tr(),
                titleStyle: context.textTheme.bodyLarge!.copyWith(
                  color: Colors.white,
                ),
                icon: FlutterIcons.credit_card_fea,
                iconSize: 18,
                onPressed: vm.openOrderPayment,
                shapeRadius: 0,
              ),
              SizedBox(height: 10),
            ],
          )
          : SizedBox(),

      vm.order.reser_table == null && vm.order.reser_guest == null
          ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              "Order Status tracking".tr().text.make(),

              Timeline.tileBuilder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                builder: TimelineTileBuilder.connected(
                  contentsAlign: ContentsAlign.basic,
                  nodePositionBuilder: (context, index) => 0.00,
                  indicatorPositionBuilder: (context, index) => 0.35,
                  indicatorBuilder: (context, index) {
                    //
                    final orderStatus = vm.order.totalStatuses[index];
                    //
                    return (orderStatus.passed ?? true)
                        ? DotIndicator(
                          color: AppColor.primaryColor,
                          size: 24,
                          child: Icon(
                            FlutterIcons.check_ant,
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
                          ('${vm.order.totalStatuses[index].name}'
                              .tr()
                              .capitalized),
                          style: context.textTheme.bodyLarge!.copyWith(
                            fontSize: Vx.dp16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        //if created at is not null
                        Text(
                          "${vm.order.totalStatuses[index].createdAt != null ? Jiffy.parseFromDateTime(vm.order.totalStatuses[index].createdAt!).format(pattern: "dd MMM, yyy 'at' hh:mm a") : ''}",
                          style: context.textTheme.bodyLarge!.copyWith(
                            fontSize: Vx.dp16,
                            fontWeight: FontWeight.w300,
                          ),
                        ),

                        //track order
                        ((vm.order.totalStatuses[index].createdAt != null &&
                                    "${vm.order.totalStatuses[index].name}" ==
                                        "enroute" &&
                                    vm.order.status == "enroute") &&
                                AppStrings.enableOrderTracking &&
                                (vm.order.dropoffLocation != null ||
                                    vm.order.deliveryAddress != null)
                                //driver must be assigned
                                &&
                                vm.order.driverId != null)
                            ? CustomButton(
                              title: "Track Order".tr(),
                              icon: FlutterIcons.map_ent,
                              onPressed: vm.trackOrder,
                              loading: vm.busy(vm.order),
                            ).p20()
                            : UiSpacer.emptySpace(),
                      ]).p(Vx.dp20),
                  itemCount: vm.order.totalStatuses.length,
                ),
              ),
            ],
          )
          : SizedBox(),

      //status changes
    ]);
  }
}
