import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/list/category.list_item.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/providers/vendor_sections_providers.dart';
import 'package:fuodz/services/navigation.service.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class CommerceTypeVendorTypeCategories extends ConsumerStatefulWidget {
  const CommerceTypeVendorTypeCategories(
    this.vendorType, {
    this.title,
    this.description,
    this.showTitle = true,
    this.crossAxisCount,
    this.childAspectRatio,
    this.lessItemCount = 6,
    super.key,
  });

  final VendorType vendorType;
  final String? title;
  final String? description;
  final bool showTitle;
  final int? crossAxisCount;
  final double? childAspectRatio;
  final int lessItemCount;

  @override
  ConsumerState<CommerceTypeVendorTypeCategories> createState() =>
      _CommerceTypeVendorTypeCategoriesState();
}

class _CommerceTypeVendorTypeCategoriesState
    extends ConsumerState<CommerceTypeVendorTypeCategories> {
  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    final args = (vendorTypeId: widget.vendorType.id, page: null as int?);
    final asyncCategories = ref.watch(vendorCategoriesControllerProvider(args));
    final categories = asyncCategories.valueOrNull ?? const [];

    return VStack([
      HStack([
        VStack([
          widget.showTitle
              ? ((widget.title ?? "We are here for you")
                  .tr()
                  .text
                  .lg
                  .medium
                  .make())
              : UiSpacer.emptySpace(),
          (widget.description ?? "How can we help?")
              .tr()
              .text
              .xl
              .semiBold
              .make(),
        ]).expand(),
        (!isOpen ? "See all" : "Show less")
            .tr()
            .text
            .color(AppColor.primaryColor)
            .make()
            .onInkTap(
              () => context.pushRoute('/categories', extra: widget.vendorType),
            ),
      ]).p12(),
      CustomListView(
        scrollDirection: Axis.horizontal,
        dataSet: categories,
        isLoading: asyncCategories.isLoading,
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryListItem(
            category: category,
            onPressed: NavigationService.categorySelected,
          );
        },
      ).h(100),
    ]);
  }
}
