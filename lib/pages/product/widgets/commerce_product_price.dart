import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/component/currency_hstack.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/services/app_currency_system.service.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/extensions/string.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class CommerceProductPrice extends StatelessWidget {
  const CommerceProductPrice({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final currencySymbol = AppStrings.currentCurrencySymbol;
    return HStack([
      "Price:".text.make().expand(flex: 2),
      UiSpacer.smHorizontalSpace(),
      HStack([
        CurrencyHStack([
          currencySymbol.text.sm.bold.color(context.primaryColor).make(),
          product.sellPrice.convertCurrency
              .currencyValueFormat()
              .text
              .xl
              .bold
              .color(context.primaryColor)
              .make(),
        ], crossAlignment: CrossAxisAlignment.end),
        UiSpacer.smHorizontalSpace(),
        CustomVisibilty(
          visible: product.showDiscount,
          child: CurrencyHStack([
            currencySymbol.text.lineThrough.xs
                .color(context.primaryColor)
                .make(),
            product.price
                .currencyValueFormat()
                .text
                .lineThrough
                .lg
                .thin
                .color(context.primaryColor)
                .make(),
          ]),
        ),
      ]).expand(flex: 4),
    ]).py12().px20();
  }
}
