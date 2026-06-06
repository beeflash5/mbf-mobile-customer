import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/list/option.list_item.dart';
import 'package:fuodz/models/option_group.dart';
import 'package:fuodz/models/product.dart';

class ProductOptionGroup extends StatelessWidget {
  const ProductOptionGroup({
    super.key,
    required this.optionGroup,
    required this.product,
  });

  final OptionGroup optionGroup;
  final Product product;

  @override
  Widget build(BuildContext context) {
    return VStack([
      optionGroup.name.text.base.semiBold.make(),
      CustomListView(
        dataSet: optionGroup.options,
        noScrollPhysics: true,
        itemBuilder: (context, index) {
          final option = optionGroup.options[index];
          return OptionListItem(
            option: option,
            optionGroup: optionGroup,
            product: product,
          );
        },
      ),
    ]).px20();
  }
}
