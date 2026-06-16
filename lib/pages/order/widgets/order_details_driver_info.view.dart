import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_ui_settings.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class OrderDetailsDriverInfoView extends StatelessWidget {
  const OrderDetailsDriverInfoView({
    super.key,
    required this.order,
    required this.onCallDriver,
    required this.onChatDriver,
    required this.onRateDriver,
  });

  final Order order;
  final VoidCallback onCallDriver;
  final VoidCallback onChatDriver;
  final VoidCallback onRateDriver;

  @override
  Widget build(BuildContext context) {
    if (order.driver == null) return UiSpacer.emptySpace();

    bool isTattoo =
        order.vendor?.vendorType.slug.toLowerCase() == 'tattoo' ||
        order.vendor?.vendorType.slug.toLowerCase() == 'tatto' ||
        order.vendor?.vendorType.slugUrl?.toLowerCase() == 'tattoo' ||
        order.vendor?.vendorType.slugUrl?.toLowerCase() == 'tatto';

    return VStack([
      HStack([
        VStack([
          "Driver".tr().text.gray500.medium.make(),
          "${order.driver?.name}".text.medium.xl.make().pOnly(bottom: Vx.dp20),
        ]).expand(),
        Visibility(
          visible:
              !isTattoo && order.canChatDriver && AppUISettings.canCallDriver,
          child:
              CustomButton(
                icon: Icons.phone,
                iconColor: Colors.white,
                color: AppColor.primaryColor,
                shapeRadius: Vx.dp48,
                onPressed: onCallDriver,
              ).wh(Vx.dp64, Vx.dp40).p12(),
        ),
      ]),
      if (!isTattoo && order.canChatDriver && AppUISettings.canDriverChat)
        CustomButton(
          icon: Icons.chat,
          iconColor: Colors.white,
          title: "Chat with driver".tr(),
          color: AppColor.primaryColor,
          onPressed: onChatDriver,
        ).h(Vx.dp48).pOnly(top: Vx.dp12, bottom: Vx.dp20),
      if (order.canRateDriver)
        CustomButton(
          icon: Icons.rate_review,
          iconColor: Colors.white,
          title: "Rate The Driver".tr(),
          color: AppColor.primaryColor,
          onPressed: onRateDriver,
        ).h(Vx.dp48).pOnly(top: Vx.dp12, bottom: Vx.dp20),
    ]).px(20);
  }
}
