import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/custom_image.view.dart';
import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class OrderStopsView extends StatelessWidget {
  const OrderStopsView({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: order.orderStops != null && order.orderStops!.isNotEmpty,
      child: VStack([
        "Order Stops".tr().text.xl.semiBold.make(),
        UiSpacer.vSpace(10),
        Timeline.tileBuilder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          builder: TimelineTileBuilder.connected(
            itemCount: order.orderStops?.length ?? 0,
            contentsAlign: ContentsAlign.basic,
            nodePositionBuilder: (context, index) => 0.00,
            indicatorPositionBuilder: (context, index) => 0.10,
            indicatorBuilder: (context, index) {
              return DotIndicator(
                color: AppColor.primaryColor,
                size: 24,
                child: const Icon(
                  Icons.location_on,
                  size: 12,
                  color: Colors.white,
                ),
              );
            },
            connectorBuilder: (context, index, connectorType) {
              return SolidLineConnector(color: AppColor.primaryColor);
            },
            contentsBuilder: (context, index) {
              final orderStop = order.orderStops![index];
              return VStack([
                Text(
                  "${orderStop.deliveryAddress?.name}",
                  style: context.textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "${orderStop.deliveryAddress?.address}",
                  style: context.textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  "${orderStop.name} (${orderStop.phone})",
                  style: context.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Visibility(
                  visible: orderStop.note != null && orderStop.note!.isNotEmpty,
                  child: Text(
                    "${orderStop.note}",
                    style: context.textTheme.bodySmall!.copyWith(
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                Visibility(
                  visible:
                      orderStop.attachments != null &&
                      orderStop.attachments!.isNotEmpty,
                  child: CustomListView(
                    scrollDirection: Axis.horizontal,
                    dataSet: order.attachments ?? [],
                    itemBuilder: (ctx, index) {
                      final attachment = orderStop.attachments![index];
                      return Column(
                        children: [
                          UiSpacer.vSpace(10),
                          CustomImage(
                            imageUrl: attachment.link!,
                            canZoom: true,
                            width: 70,
                            height: 70,
                          ),
                          "${attachment.collectionName}".text.make().py2(),
                        ],
                      );
                    },
                  ).h(110),
                ),
              ]).p(Vx.dp20);
            },
          ),
        ),
        UiSpacer.divider().py8(),
      ]),
    );
  }
}
