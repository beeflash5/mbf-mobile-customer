import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/busy_indicator.dart';
import 'package:fuodz/models/option_group.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/pages/product/widgets/commerce_product_option_group.dart';
import 'package:fuodz/providers/product_details_providers.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class CommerceProductOptions extends ConsumerWidget {
  const CommerceProductOptions(this.product, {super.key});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(productDetailsControllerProvider(product));
    if (product.optionGroups.isEmpty) return const SizedBox.shrink();
    if (asyncState.isLoading) return BusyIndicator().centered().py20();
    return VStack([
      UiSpacer.vSpace(10),
      "Note: Long press option to see option full details"
          .tr()
          .text
          .sm
          .light
          .italic
          .make()
          .px20(),
      UiSpacer.vSpace(5),
      ...product.optionGroups.map(
        (OptionGroup g) =>
            CommerceProductOptionGroup(optionGroup: g, product: product),
      ),
      UiSpacer.vSpace(10),
    ]);
  }
}
