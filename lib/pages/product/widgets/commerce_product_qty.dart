import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/button/qty_stepper.dart';
import 'package:fuodz/component/currency_hstack.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/providers/product_details_providers.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/extensions/string.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class CommerceProductQtyEntry extends ConsumerWidget {
  const CommerceProductQtyEntry({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencySymbol = AppStrings.currencySymbol;
    final asyncState = ref.watch(productDetailsControllerProvider(product));
    final notifier = ref.read(
      productDetailsControllerProvider(product).notifier,
    );
    final state = asyncState.valueOrNull;
    final liveProduct = state?.product ?? product;
    final total = state?.total ?? 0;
    return Visibility(
      visible: liveProduct.hasStock,
      child:
          VStack([
            HStack([
              "Quantity:".tr().text.make().expand(flex: 2),
              HStack([
                QtyStepper(
                  defaultValue: liveProduct.selectedQty,
                  min: 1,
                  max:
                      (liveProduct.availableQty != null &&
                              liveProduct.availableQty! > 0)
                          ? liveProduct.availableQty!
                          : 20,
                  disableInput: true,
                  onChange: notifier.updateSelectedQty,
                  actionIconColor: AppColor.primaryColor,
                ).box.border(color: AppColor.primaryColor).roundedLg.p1.make(),
              ]).expand(flex: 4),
            ]),
            UiSpacer.verticalSpace(),
            HStack([
              "Total Price:".tr().text.make().expand(flex: 2),
              UiSpacer.smHorizontalSpace(),
              CurrencyHStack([
                currencySymbol.text.sm.bold.color(context.primaryColor).make(),
                total
                    .currencyValueFormat()
                    .text
                    .xl
                    .bold
                    .color(context.primaryColor)
                    .make(),
              ], crossAlignment: CrossAxisAlignment.end).expand(flex: 4),
            ]),
          ]).py12().px20(),
    );
  }
}
