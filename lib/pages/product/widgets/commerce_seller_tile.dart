import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/models/product.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class CommerceSellerTile extends StatelessWidget {
  const CommerceSellerTile({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return HStack([
      "Seller:".text.make().expand(flex: 2),
      UiSpacer.smHorizontalSpace(),
      "${product.vendor.name}".text.underline
          .color(AppColor.primaryColor)
          .make()
          .onInkTap(
            () => context.pushRoute(
              '/vendors/${product.vendor.id}',
              extra: product.vendor,
            ),
          )
          .expand(flex: 4),
    ]).py12().px20();
  }
}
