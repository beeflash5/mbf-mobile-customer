import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/currency_hstack.dart';
import 'package:fuodz/component/custom_image.view.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/models/service_option.dart';
import 'package:fuodz/models/service_option_group.dart';
import 'package:fuodz/providers/service_details_providers.dart';
import 'package:fuodz/services/app_currency_system.service.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/extensions/string.dart';
import 'package:fuodz/utils/sizes.dart';

class ServiceOptionListItem extends ConsumerWidget {
  const ServiceOptionListItem({
    super.key,
    required this.option,
    required this.optionGroup,
    required this.service,
  });

  final ServiceOption option;
  final ServiceOptionGroup optionGroup;
  final Service service;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencySymbol = AppStrings.currentCurrencySymbol;
    final asyncState = ref.watch(serviceDetailsControllerProvider(service));
    final notifier =
        ref.read(serviceDetailsControllerProvider(service).notifier);
    final selected = asyncState.valueOrNull?.selectedOptionIds
            .contains(option.id) ??
        false;

    return HStack([
      Checkbox(
        visualDensity: VisualDensity.compact,
        value: selected,
        onChanged: (value) {
          if (value != null) {
            notifier.toggleOption(optionGroup, option);
          }
        },
      ),
      VStack([
        HStack([
          if (option.photo.isNotEmptyAndNotNull && option.photo.isNotDefaultImage)
            CustomImage(
              imageUrl: option.photo,
              width: Vx.dp32,
              height: Vx.dp32,
              canZoom: true,
              hideDefaultImg: true,
            ).card.clip(Clip.antiAlias).roundedSM.make(),
          option.name.text.medium.lg.make().expand(),
          CurrencyHStack(
            [
              currencySymbol.text.sm.medium.make(),
              option.price.convertCurrency
                  .currencyValueFormat()
                  .text
                  .sm
                  .bold
                  .make(),
            ],
            crossAlignment: CrossAxisAlignment.end,
          ),
        ], crossAlignment: CrossAxisAlignment.center, spacing: 12),
        (option.description.isNotEmptyAndNotNull &&
                option.description.isNotNullOrBlank)
            ? "${option.description}"
                .text
                .sm
                .maxLines(3)
                .overflow(TextOverflow.ellipsis)
                .make()
            : 0.widthBox,
      ], spacing: 5).expand(),
    ], spacing: 10, crossAlignment: CrossAxisAlignment.start)
        .p(10)
        .box
        .withRounded(value: Sizes.radiusSmall)
        .border(
          color: selected ? context.primaryColor : Colors.grey.shade200,
          width: selected ? 2.5 : 1.0,
        )
        .make();
  }
}
