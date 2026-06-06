import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/bottom_sheet/option_details.bottomsheet.dart';
import 'package:fuodz/models/option.dart';
import 'package:fuodz/models/option_group.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/providers/product_details_providers.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/app_currency_system.service.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/extensions/string.dart';
import 'package:fuodz/utils/utils.dart';

class CommerceOptionListItem extends ConsumerWidget {
  const CommerceOptionListItem({
    super.key,
    required this.option,
    required this.optionGroup,
    required this.product,
  });

  final Option option;
  final OptionGroup optionGroup;
  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productDetailsControllerProvider(product));
    final notifier =
        ref.read(productDetailsControllerProvider(product).notifier);
    final selected =
        state.valueOrNull?.selectedOptionIds.contains(option.id) ?? false;
    return "${option.name}${option.price > 0 ? ' (+${option.price.convertCurrency.currencyValueFormat()})' : ''}"
        .text
        .medium
        .lg
        .make()
        .box
        .p8
        .roundedSM
        .border(
          color: selected ? AppColor.primaryColor : Colors.grey,
          width: selected ? 1.4 : 1,
        )
        .make()
        .pOnly(left: !Utils.isArabic ? 0 : 10, right: Utils.isArabic ? 0 : 10)
        .onInkTap(() {
          final error = notifier.toggleOption(optionGroup, option);
          if (error != null) AlertService.error(text: error);
        })
        .onInkLongPress(() => _showOptionDetails(context, option));
  }

  void _showOptionDetails(BuildContext ctx, Option option) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (ctx) => OptionDetailsBottomSheet(option),
    );
  }
}
