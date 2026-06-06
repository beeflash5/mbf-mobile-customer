import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/list/commerce_option.list_item.dart';
import 'package:fuodz/models/option_group.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class CommerceProductOptionGroup extends StatelessWidget {
  const CommerceProductOptionGroup({
    super.key,
    required this.optionGroup,
    required this.product,
  });

  final OptionGroup optionGroup;
  final Product product;

  @override
  Widget build(BuildContext context) {
    return VStack([
      "${optionGroup.name}".text.lg.semiBold.make(),
      Visibility(
        visible: optionGroup.maxOptions != null,
        child: ("Max Selection: ".tr() + "${optionGroup.maxOptions}")
            .text
            .sm
            .make(),
      ),
      UiSpacer.vSpace(6),
      Wrap(
        children: optionGroup.options
            .map(
              (e) => CommerceOptionListItem(
                option: e,
                optionGroup: optionGroup,
                product: product,
              ),
            )
            .toList(),
      ),
    ]).px20().py12();
  }
}
