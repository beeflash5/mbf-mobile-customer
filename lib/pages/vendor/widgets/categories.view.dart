import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/custom_horizontal_list_view.dart';
import 'package:fuodz/component/list/category.list_item.dart';
import 'package:fuodz/component/section.title.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/providers/vendor_sections_providers.dart';
import 'package:fuodz/services/navigation.service.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class Categories extends ConsumerWidget {
  const Categories(this.vendorType, {super.key});

  final VendorType vendorType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCategories = ref.watch(
      vendorCategoriesControllerProvider((
        vendorTypeId: vendorType.id,
        page: null,
      )),
    );
    final categories = asyncCategories.valueOrNull ?? const [];

    return VStack([
      HStack([
        SectionTitle("Categories".tr()).expand(),
        UiSpacer.smHorizontalSpace(),
        "See all"
            .tr()
            .text
            .color(context.primaryColor)
            .make()
            .onInkTap(
              () => context.pushRoute('/categories', extra: vendorType),
            ),
      ]).p12(),
      CustomHorizontalListView(
        isLoading: asyncCategories.isLoading,
        itemsViews:
            categories
                .map(
                  (category) => CategoryListItem(
                    category: category,
                    onPressed: NavigationService.categorySelected,
                    maxLine: false,
                  ),
                )
                .toList(),
      ),
    ]);
  }
}
