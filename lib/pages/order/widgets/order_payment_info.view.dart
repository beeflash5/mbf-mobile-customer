import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/services/order.service.dart';

class OrderPaymentInfoView extends StatelessWidget {
  const OrderPaymentInfoView({
    super.key,
    required this.order,
    required this.onOpenPaymentMethodSelection,
    this.paymentStatusBusy = false,
  });

  final Order order;
  final VoidCallback onOpenPaymentMethodSelection;
  final bool paymentStatusBusy;

  @override
  Widget build(BuildContext context) {
    return VStack([
      CustomVisibilty(
        visible: order.isPaymentPending && order.isOngoing,
        child: CustomButton(
          title: "PAY FOR ORDER".tr(),
          titleStyle: context.textTheme.bodyLarge!.copyWith(
            color: Colors.white,
          ),
          icon: Icons.credit_card,
          iconSize: 18,
          onPressed:
              () => OrderService.openOrderPayment(order, context: context),
        ).p20().pOnly(bottom: Vx.dp20),
      ),
      CustomVisibilty(
        visible:
            order.paymentStatus == "request" &&
            ["pending"].contains(order.status),
        child: CustomButton(
          title: "PAY FOR ORDER".tr(),
          titleStyle: context.textTheme.bodyLarge!.copyWith(
            color: Colors.white,
          ),
          icon: Icons.credit_card,
          iconSize: 18,
          loading: paymentStatusBusy,
          onPressed: onOpenPaymentMethodSelection,
        ).wFull(context).p20().pOnly(bottom: Vx.dp20),
      ),
    ]);
  }
}
