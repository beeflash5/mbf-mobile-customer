import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/custom_grid_view.dart';
import 'package:fuodz/component/list/payment_method.list_item.dart';
import 'package:fuodz/models/payment_method.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class PaymentMethodsView extends StatelessWidget {
  const PaymentMethodsView({
    super.key,
    required this.paymentMethods,
    required this.selectedPaymentMethod,
    required this.onSelected,
    this.isLoading = false,
  });

  final List<PaymentMethod> paymentMethods;
  final PaymentMethod? selectedPaymentMethod;
  final ValueChanged<PaymentMethod> onSelected;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return VStack([
      "Payment Methods".tr().text.semiBold.lg.make(),
      "How do you want to pay for this order?".text
          .color(const Color(0xff808080))
          .make(),
      CustomGridView(
        crossAxisCount: 1,
        noScrollPhysics: true,
        dataSet: paymentMethods,
        childAspectRatio: 6,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        isLoading: isLoading,
        itemBuilder: (context, index) {
          final paymentMethod = paymentMethods[index];
          return PaymentOptionListItem(
            paymentMethod,
            selected: selectedPaymentMethod?.id == paymentMethod.id,
            onSelected: onSelected,
          );
        },
      ).pOnly(top: Vx.dp16),
      UiSpacer.divider(thickness: 2).py12(),
    ]);
  }
}
