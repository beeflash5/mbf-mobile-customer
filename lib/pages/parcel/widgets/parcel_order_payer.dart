import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/providers/new_parcel_providers.dart';

class ParcelOrderPayer extends StatelessWidget {
  const ParcelOrderPayer({
    super.key,
    required this.state,
    required this.controller,
  });

  final NewParcelState state;
  final NewParcelController controller;

  @override
  Widget build(BuildContext context) {
    return VStack([
      "Order Payer".tr().text.xl.semiBold.make(),
      "Who is paying for order?".tr().text.sm.make(),
      Wrap(
        children: [
          HStack([
            Radio(
              value: true,
              groupValue: state.packageCheckout.payer,
              onChanged: (bool? value) {
                state.packageCheckout.payer = value ?? false;
                controller.notifyExternalChange();
              },
            ),
            "Sender".tr().text.make().p4(),
          ]),
          HStack([
            Radio(
              value: false,
              groupValue: state.packageCheckout.payer,
              onChanged: (bool? value) {
                state.packageCheckout.payer = value ?? false;
                controller.notifyExternalChange();
                controller.setupReceiverPaymentMethod();
              },
            ),
            "Receiver".tr().text.make().p4(),
          ]),
        ],
      ),
    ]);
  }
}
