import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/custom_image.view.dart';
import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/list/order_product.list_item.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/pages/cart/widgets/amount_tile.dart';
import 'package:fuodz/pages/order/widgets/order_stops.view.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';

class OrderDetailsItemsView extends StatelessWidget {
  const OrderDetailsItemsView({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return VStack([
      Visibility(
        visible: order.isPackageDelivery,
        child: OrderStopsView(order: order),
      ),
      (order.isPackageDelivery
              ? "Package Details"
              : order.isSerice
              ? "Service"
              : "Products")
          .tr()
          .text
          .semiBold
          .xl
          .make()
          .pOnly(bottom: Vx.dp10),
      Visibility(
        visible: order.isPackageDelivery,
        child: VStack([
          AmountTile("Package Type".tr(), "${order.packageType?.name}"),
          AmountTile("Width".tr(), "${order.width}cm"),
          AmountTile("Length".tr(), "${order.length}cm"),
          AmountTile("Height".tr(), "${order.height}cm"),
          AmountTile("Weight".tr(), "${order.weight}kg"),
        ], crossAlignment: CrossAxisAlignment.end),
      ),
      Visibility(
        visible: order.isSerice,
        child: VStack([
          HStack([
            "Service".tr().text.make().expand(),
            "${order.orderService?.service?.name ?? order.vendor?.name ?? ''}"
                .text
                .semiBold
                .lg
                .make(),
          ]).py4(),
          if (order.orderService != null &&
              order.orderService!.options != null &&
              order.orderService!.options!.isNotEmpty)
            VStack([
              "Options".tr().text.make(),
              "${order.orderService?.options}".text.medium.sm.make(),
            ]).py4(),
          if (order.note.isNotEmpty)
            VStack([
              "Note".tr().text.make(),
              "${order.note}".text.medium.sm.make(),
            ]).py4(),
          HStack([
            "Category".tr().text.make().expand(),
            "${order.orderService?.service?.category?.name ?? order.orderService?.service?.subcategory?.name ?? order.vendor?.vendorType?.name ?? ''}"
                .text
                .semiBold
                .lg
                .make(),
          ]),
        ], crossAlignment: CrossAxisAlignment.end),
      ),
      if (order.tatto_type_select.isNotEmptyAndNotNull &&
          order.tatto_placement.isNotEmptyAndNotNull)
        Column(
          children: [
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                "Tatto Type".text.make(),
                "${order.tatto_type_select}".text.medium.bold.make(),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                "Tatto Placement".text.make(),
                "${order.tatto_placement}".text.medium.bold.make(),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                "Tatto Size".text.make(),
                "${order.tatto_size}".text.medium.bold.make(),
              ],
            ),
          ],
        ),
      if (order.orderProducts != null && order.orderProducts!.isNotEmpty)
        CustomListView(
          noScrollPhysics: true,
          dataSet: order.orderProducts!,
          itemBuilder: (context, index) {
            final orderProduct = order.orderProducts![index];
            return OrderProductListItem(
              orderProduct: orderProduct,
              order: order,
            );
          },
          separatorBuilder:
              order.isCompleted ? (ctx, index) => UiSpacer.emptySpace() : null,
        ),
      if (order.attachments == null || order.attachments!.isEmpty)
        if (order.photo != null && !Utils.isDefaultImg(order.photo!))
          CustomImage(
            imageUrl: order.photo!,
            boxFit: BoxFit.fill,
          ).h(context.percentHeight * 30).wFull(context),
    ]);
  }
}
