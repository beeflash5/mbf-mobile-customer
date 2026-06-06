import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/currency_hstack.dart';
import 'package:fuodz/component/custom_image.view.dart';
import 'package:fuodz/models/option.dart';
import 'package:fuodz/models/option_group.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/providers/product_details_providers.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/app_currency_system.service.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/extensions/string.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class OptionListItem extends ConsumerWidget {
  const OptionListItem({
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
    final currencySymbol = AppStrings.currentCurrencySymbol;
    final state = ref.watch(productDetailsControllerProvider(product));
    final notifier =
        ref.read(productDetailsControllerProvider(product).notifier);
    final selected =
        state.valueOrNull?.selectedOptionIds.contains(option.id) ?? false;

    return HStack([
      Stack(children: [
        CustomImage(
          imageUrl: option.photo,
          width: Vx.dp32,
          height: Vx.dp32,
          canZoom: true,
          hideDefaultImg: true,
        ).card.clip(Clip.antiAlias).roundedSM.make(),
        if (selected)
          Positioned(
            top: 5,
            bottom: 5,
            left: 5,
            right: 5,
            child: Icon(Icons.check)
                .box
                .color(AppColor.accentColor)
                .roundedSM
                .make(),
          )
        else
          UiSpacer.emptySpace(),
      ]),
      VStack([
        option.name.text.medium.lg.make(),
        if (option.description.isNotEmptyAndNotNull ||
            option.description.isNotNullOrBlank)
          "${option.description}"
              .text
              .sm
              .maxLines(3)
              .overflow(TextOverflow.ellipsis)
              .make(),
      ]).px12().expand(),
      CurrencyHStack([
        currencySymbol.text.sm.medium.make(),
        option.price.convertCurrency
            .currencyValueFormat()
            .text
            .sm
            .bold
            .make(),
      ], crossAlignment: CrossAxisAlignment.end),
    ], crossAlignment: CrossAxisAlignment.center).onInkTap(() {
      final error = notifier.toggleOption(optionGroup, option);
      if (error != null) AlertService.error(text: error);
    });
  }
}
