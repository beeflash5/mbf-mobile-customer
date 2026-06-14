import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/list/parcel_order_stop.list_view.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/utils/app_images.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class OrderAddressesView extends StatelessWidget {
  const OrderAddressesView({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return VStack([
      if (order.isPackageDelivery &&
          order.orderStops != null &&
          order.orderStops!.isNotEmpty)
        VStack([
          ParcelOrderStopListView(
            "Pickup Location",
            order.orderStops!.first,
            canCall: order.canChatVendor,
          ),
          ..._stopsList(),
          if (order.orderStops!.length > 1)
            ParcelOrderStopListView(
              "Dropoff Location",
              order.orderStops!.last,
              canCall: order.canChatVendor,
            ),
        ])
      else
        UiSpacer.emptySpace(),
      Visibility(
        visible: !order.isPackageDelivery,
        child: VStack([
          "Delivery details".tr().text.xl.semiBold.make(),
          HStack([
            Image.asset(AppImages.pickupLocation, width: 15, height: 15),
            UiSpacer.smHorizontalSpace(),
            "${order.vendor?.address}".text.make().expand(),
          ], crossAlignment: CrossAxisAlignment.start).py12(),
          Visibility(
            visible: order.deliveryAddress != null,
            child: HStack([
              Image.asset(AppImages.dropoffLocation, width: 15, height: 15),
              UiSpacer.smHorizontalSpace(),
              VStack([
                if (order.deliveryAddress != null)
                  "${order.deliveryAddress!.address}".text.make(),
                if (order.deliveryAddress != null)
                  "${order.deliveryAddress!.name}".text
                      .color(Vx.gray400)
                      .sm
                      .light
                      .make(),
              ]).expand(),
            ], crossAlignment: CrossAxisAlignment.start),
          ),
        ]),
      ),
    ]);
  }

  List<Widget> _stopsList() {
    final stops = order.orderStops;
    if (stops == null || stops.length <= 2) {
      return [UiSpacer.emptySpace()];
    }
    return stops
        .sublist(1, stops.length - 1)
        .mapIndexed(
          (stop, index) => VStack([
            ParcelOrderStopListView(
              "Stop".tr() + " ${index + 1}",
              stop,
              canCall: order.canChatVendor,
            ),
          ]),
        )
        .toList();
  }
}
