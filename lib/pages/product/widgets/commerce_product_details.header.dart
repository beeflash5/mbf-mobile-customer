import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/pages/product/widgets/product_fav.btn.dart';
import 'package:fuodz/utils/extensions/dynamic.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class CommerceProductDetailsHeader extends StatelessWidget {
  const CommerceProductDetailsHeader({
    super.key,
    required this.product,
    this.showVendor = true,
  });

  final Product product;
  final bool showVendor;

  @override
  Widget build(BuildContext context) {
    return VStack([
      UiSpacer.verticalSpace(),
      product.name.text.lg.semiBold.make(),
      HStack([
        (product.canBeDelivered ? "Deliverable".tr() : "Not Deliverable".tr())
            .text
            .white
            .sm
            .make()
            .py4()
            .px8()
            .box
            .roundedLg
            .color(product.canBeDelivered ? Vx.green500 : Vx.red500)
            .make(),
        UiSpacer.expandedSpace(),
        CustomVisibilty(
          visible:
              !product.capacity.isEmptyOrNull && !product.unit.isEmptyOrNull,
          child: "${product.capacity} ${product.unit}".text.sm.black
              .make()
              .py4()
              .px8()
              .box
              .roundedLg
              .gray500
              .make()
              .pOnly(right: Vx.dp12),
        ),
        CustomVisibilty(
          visible: product.packageCount != null,
          child:
              "%s Items"
                  .tr()
                  .fill(["${product.packageCount}"])
                  .text
                  .sm
                  .black
                  .make()
                  .py4()
                  .px8()
                  .box
                  .roundedLg
                  .gray500
                  .make(),
        ),
        UiSpacer.smHorizontalSpace(),
        ProductFavButton(product: product),
      ]).pOnly(top: Vx.dp10),
    ]).px20();
  }
}
