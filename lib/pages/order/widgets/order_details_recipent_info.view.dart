import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class OrderDetailsRecipentInfoView extends StatelessWidget {
  const OrderDetailsRecipentInfoView({
    super.key,
    required this.order,
    required this.onCallRecipient,
  });

  final Order order;
  final VoidCallback onCallRecipient;

  @override
  Widget build(BuildContext context) {
    final hasRecipient =
        order.recipientName != null && order.recipientName!.isNotBlank;
    if (!hasRecipient) return UiSpacer.emptySpace();
    return VStack(
      [
        HStack(
          [
            VStack(
              [
                "Recipient Name".tr().text.gray500.medium.sm.make(),
                order.recipientName!.text.medium.xl
                    .make()
                    .pOnly(bottom: Vx.dp20),
              ],
            ).expand(),
            CustomButton(
              icon: Icons.phone,
              iconColor: Colors.white,
              title: "",
              color: AppColor.primaryColor,
              shapeRadius: Vx.dp24,
              onPressed: onCallRecipient,
            ).wh(Vx.dp64, Vx.dp40).p12(),
          ],
        ),
      ],
    );
  }
}
