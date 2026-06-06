import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/custom_dynamic_grid_view.dart';
import 'package:fuodz/component/list/category.list_item.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/providers/vendor_sections_providers.dart';
import 'package:fuodz/services/navigation.service.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/utils.dart';

class VendorTypeCategories extends ConsumerStatefulWidget {
  const VendorTypeCategories(
    this.vendorType, {
    this.title,
    this.description,
    this.showTitle = true,
    this.showDescription = false,
    this.crossAxisCount,
    this.childAspectRatio,
    this.invertedItemDesign = true,
    this.listPadding,
    this.headerPadding,
    super.key,
  });

  final VendorType vendorType;
  final String? title;
  final String? description;
  final bool showTitle;
  final bool showDescription;
  final int? crossAxisCount;
  final double? childAspectRatio;
  final bool invertedItemDesign;
  final EdgeInsets? listPadding;
  final EdgeInsets? headerPadding;

  @override
  ConsumerState<VendorTypeCategories> createState() =>
      _VendorTypeCategoriesState();
}

class _VendorTypeCategoriesState extends ConsumerState<VendorTypeCategories> {
  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    final args = (
      vendorTypeId: widget.vendorType.id,
      page: 1 as int?,
    );
    final asyncCategories =
        ref.watch(vendorCategoriesControllerProvider(args));
    final categories = asyncCategories.valueOrNull ?? const [];
    final isLoading = asyncCategories.isLoading;

    return VStack([
      Padding(
        padding: widget.headerPadding ??
            const EdgeInsets.symmetric(horizontal: 12),
        child: HStack([
          VStack([
            if (widget.showTitle)
              ((widget.title ?? "We are here for you")
                  .tr()
                  .text
                  .xl
                  .medium
                  .make()),
            if (widget.showDescription)
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
                () => context.pushRoute(
                  '/categories',
                  extra: widget.vendorType,
                ),
              ),
        ]),
      ),
      if (AppStrings.categoryStyleGrid)
        CustomDynamicHeightGridView(
          padding: widget.listPadding ??
              const EdgeInsets.symmetric(horizontal: 10),
          crossAxisCount: AppStrings.categoryPerRow,
          itemCount: categories.length,
          mainAxisSpacing: 0,
          crossAxisSpacing: 0,
          isLoading: isLoading,
          noScrollPhysics: true,
          itemBuilder: (ctx, index) => CategoryListItem(
            category: categories[index],
            onPressed: NavigationService.categorySelected,
            maxLine: true,
            lines: 1,
            inverted: false,
            textColor: Utils.textColorByBrightness(),
            h: 90,
          ),
        ),
      if (!AppStrings.categoryStyleGrid)
        Padding(
          padding: widget.listPadding ??
              const EdgeInsets.symmetric(horizontal: 10),
          child: HStack([
            ...categories.map(
              (e) => CategoryListItem(
                category: e,
                onPressed: NavigationService.categorySelected,
                maxLine: !AppStrings.categoryStyleGrid,
                lines: 2,
                h: AppStrings.categoryImageHeight + 41,
                inverted: widget.invertedItemDesign,
              ).w(context.screenWidth / AppStrings.categoryPerRow),
            ),
          ],
              crossAlignment: CrossAxisAlignment.start,
              alignment: MainAxisAlignment.start,
              axisSize: MainAxisSize.max),
        ).scrollHorizontal().wFull(context),
    ], spacing: 10);
  }
}
