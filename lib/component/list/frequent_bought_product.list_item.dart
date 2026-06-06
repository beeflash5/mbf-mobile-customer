import 'package:flutter/material.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/extensions/string.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/services/app_currency_system.service.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:velocity_x/velocity_x.dart';

class FrequentBoughtProductListItem extends StatefulWidget {
  FrequentBoughtProductListItem({
    required this.product,
    required this.oncheckChange,
    this.selected = true,
    Key? key,
  }) : super(key: key);

  final Product product;
  final Function(bool) oncheckChange;
  final bool selected;
  @override
  State<FrequentBoughtProductListItem> createState() =>
      _FrequentBoughtProductListItemState();
}

class _FrequentBoughtProductListItemState
    extends State<FrequentBoughtProductListItem> {
  @override
  Widget build(BuildContext context) {
    return HStack([
      //checkbox
      Checkbox(
        value: widget.selected,
        onChanged: (value) {
          widget.oncheckChange(value ?? false);
        },
      ).p8(),

      UiSpacer.hSpace(8),
      //
      HStack([
        VStack([
          "${widget.product.name}".text
              .scale(1.2)
              .maxLines(2)
              .overflow(TextOverflow.ellipsis)
              .make(),
          UiSpacer.vSpace(3),
          "${AppStrings.currentCurrencySymbol} ${widget.product.sellPrice.convertCurrency}"
              .currencyFormat()
              .text
              .color(AppColor.primaryColor)
              .semiBold
              .make(),
        ]).expand(),
        //
        Icon(
          !Utils.isArabic
              ? Icons.keyboard_arrow_right
              : Icons.keyboard_arrow_left,
        ),
      ], crossAlignment: CrossAxisAlignment.center).p8().onInkTap(() {
        context.pushRoute(
          '/products/${widget.product.id}',
          extra: widget.product,
        );
      }).expand(),
    ]);
  }
}
