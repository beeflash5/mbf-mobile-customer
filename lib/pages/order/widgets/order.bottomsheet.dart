import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class OrderBottomSheet extends StatelessWidget {
  const OrderBottomSheet({
    super.key,
    required this.order,
    required this.onCancel,
    this.isBusy = false,
    this.orderBusy = false,
  });

  final Order order;
  final VoidCallback onCancel;
  final bool isBusy;
  final bool orderBusy;

  @override
  Widget build(BuildContext context) {
    if (!order.canCancel || isBusy) {
      return UiSpacer.emptySpace();
    }
    return SafeArea(
      child: VStack([
        CustomButton(
          title: "Cancel Order".tr(),
          color: AppColor.closeColor,
          icon: Icons.close,
          onPressed: onCancel,
          loading: orderBusy,
        ).p20(),
      ], crossAlignment: CrossAxisAlignment.center),
    ).box.shadow.color(context.theme.colorScheme.surface).make().wFull(context);
  }
}
