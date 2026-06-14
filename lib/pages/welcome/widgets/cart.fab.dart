import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/pages/cart/cart.page.dart';
import 'package:fuodz/services/cart.service.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/sizes.dart';
import 'package:fuodz/utils/utils.dart';

class CartHomeFab extends StatelessWidget {
  const CartHomeFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      backgroundColor: AppColor.primaryColorDark,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onPressed: () => context.pushWidget(CartPage()),
      child: StreamBuilder<int>(
        stream: CartServices.cartItemsCountStream.stream,
        initialData: CartServices.productsInCart.length,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          Widget child = Icon(
            HugeIcons.strokeRoundedShoppingBasket01,
            color: Utils.textColorByPrimaryColor(),
          );
          if (snapshot.hasData && snapshot.data > 0) {
            return child
                .p(Sizes.paddingSizeExtraSmall)
                .badge(
                  position:
                      Utils.isArabic
                          ? VxBadgePosition.leftTop
                          : VxBadgePosition.rightTop,
                  count: snapshot.data,
                  color: Colors.white,
                  textStyle: context.textTheme.bodyLarge?.copyWith(
                    color: AppColor.primaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                );
          }
          return child;
        },
      ),
    );
  }
}
