import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/currency_hstack.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/extensions/string.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class OrderDetailsHeaderView extends StatelessWidget {
  const OrderDetailsHeaderView({
    super.key,
    required this.order,
    required this.onShowVerificationQR,
  });

  final Order order;
  final VoidCallback onShowVerificationQR;

  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        HStack(
          [
            VStack(
              [
                "Code".tr().text.gray500.medium.sm.make(),
                "#${order.code}".text.medium.xl.make(),
              ],
            ).expand(),
            CurrencyHStack(
              [
                AppStrings.currencySymbol.text.medium.lg.make().px4(),
                (order.total ?? 0.00)
                    .currencyValueFormat()
                    .text
                    .medium
                    .xl2
                    .make(),
              ],
            ),
          ],
        ).pOnly(bottom: Vx.dp20),
        HStack(
          [
            VStack(
              [
                "Verification Code".tr().text.gray500.medium.sm.make(),
                "${order.verificationCode}".text.medium.xl.make(),
              ],
            ).expand(),
            const Icon(
              Icons.qr_code,
              size: 28,
            ).onInkTap(onShowVerificationQR),
          ],
        ).wFull(context).pOnly(bottom: Vx.dp20),
      ],
    );
  }
}
