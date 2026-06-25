import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/list/option.list_item.dart';
import 'package:fuodz/models/option_group.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/providers/product_details_providers.dart';
import 'package:fuodz/utils/app_colors.dart';

class ProductOptionGroup extends ConsumerWidget {
  const ProductOptionGroup({
    super.key,
    required this.optionGroup,
    required this.product,
  });

  final OptionGroup optionGroup;
  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productDetailsControllerProvider(product));
    final notifier = ref.read(
      productDetailsControllerProvider(product).notifier,
    );

    // Is this group optional (not required) AND single-select?
    final isOptionalSingle =
        optionGroup.required == 0 && optionGroup.multiple == 0;

    // Is the "None" row active (nothing selected in this group)?
    final noneSelected =
        !(state.valueOrNull?.selectedOptions.any(
              (o) => o.optionGroupId == optionGroup.id,
            ) ??
            false);

    return VStack([
      // Group name + required marker
      HStack([
        optionGroup.name.text.base.semiBold.make().expand(),
        if (optionGroup.required == 1)
          " *".text.red500.sm.bold.make(),
      ]).px20(),

      // "None" row for optional single-select groups
      if (isOptionalSingle)
        _NoneRow(
          active: noneSelected,
          onTap: () => notifier.clearOptionGroup(optionGroup),
        ),

      // Option items
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
    ]);
  }
}

/// Small "None" selection row shown for optional single-select groups.
class _NoneRow extends StatelessWidget {
  const _NoneRow({required this.active, required this.onTap});
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HStack([
      Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: active ? AppColor.primaryColor : Colors.grey.shade400,
            width: 2,
          ),
        ),
        child: active
            ? Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.primaryColor,
                  ),
                ),
              )
            : null,
      ),
      "None".tr().text.sm.medium
          .color(active ? AppColor.primaryColor : Colors.grey.shade600)
          .make()
          .px12(),
    ], crossAlignment: CrossAxisAlignment.center)
        .onInkTap(onTap)
        .px20()
        .py8();
  }
}

