import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_ui_settings.dart';
import 'package:fuodz/utils/extensions/dynamic.dart';
import 'package:fuodz/utils/sizes.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class OrderDetailsVendorInfoView extends StatelessWidget {
  const OrderDetailsVendorInfoView({
    super.key,
    required this.order,
    required this.vendorTypeId,
    required this.onCallVendor,
    required this.onChatVendor,
    required this.onRateVendor,
  });

  final Order order;
  final int? vendorTypeId;
  final VoidCallback onCallVendor;
  final VoidCallback onChatVendor;
  final VoidCallback onRateVendor;

  @override
  Widget build(BuildContext context) {
    return VStack([
      HStack([
        VStack([
          (!order.isSerice ? "Vendor" : "Service Provider")
              .tr()
              .text
              .gray500
              .medium
              .make(),
          order.vendor!.name.text.medium.xl.make().py8().pOnly(bottom: Vx.dp4),
        ]).expand(),
        // if (vendorTypeId != 13)
        //   Visibility(
        //     visible: order.canChatVendor && AppUISettings.canCallVendor,
        //     child: CustomButton(
        //       icon: Icons.phone,
        //       iconColor: Colors.white,
        //       color: AppColor.primaryColor,
        //       shapeRadius: Sizes.radiusSmall,
        //       onPressed: onCallVendor,
        //     ).h(50).fittedBox(),
        //   ),
        // if (order.canChatVendor && vendorTypeId != 13)
        //   Visibility(
        //     visible: AppUISettings.canVendorChat,
        //     child: CustomButton(
        //       icon: Icons.chat,
        //       iconColor: Colors.white,
        //       color: AppColor.primaryColor,
        //       shapeRadius: Sizes.radiusSmall,
        //       onPressed: onChatVendor,
        //     ).h(50).fittedBox(),
        //   ),
      ], spacing: 8),
      if (order.canRateVendor)
        CustomButton(
          icon: Icons.rate_review,
          iconColor: Colors.white,
          title: "Rate %s".tr().fill([
            (!order.isSerice ? "Vendor" : "Service Provider").tr(),
          ]),
          color: AppColor.primaryColor,
          onPressed: onRateVendor,
        ).h(Vx.dp48).pOnly(top: Vx.dp12, bottom: Vx.dp20)
      else
        UiSpacer.emptySpace(),
    ]).px(20);
  }
}
