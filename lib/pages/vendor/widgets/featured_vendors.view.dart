import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/component/list/featured_vendor.list_item.dart';
import 'package:fuodz/component/lists/custom_horizonatal.listview.dart';
import 'package:fuodz/models/search.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/providers/vendor_sections_providers.dart';
import 'package:fuodz/utils/app_strings.dart';

class FeaturedVendorsView extends ConsumerWidget {
  const FeaturedVendorsView({
    this.title,
    this.scrollDirection = Axis.vertical,
    this.itemWidth,
    this.hideEmpty = false,
    this.onSeeAllPressed,
    this.titlePadding,
    this.listViewPadding,
    this.onVendorSelected,
    super.key,
  });

  final Axis scrollDirection;
  final String? title;
  final double? itemWidth;
  final bool hideEmpty;
  final Function? onSeeAllPressed;
  final EdgeInsets? titlePadding;
  final EdgeInsets? listViewPadding;
  final Function(Vendor)? onVendorSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncVendors = ref.watch(
      sectionVendorsControllerProvider((
        vendorTypeId: 0,
        type: SearchFilterType.featured,
        byLocation: false,
      )),
    );
    final vendors = asyncVendors.valueOrNull ?? const [];

    return CustomVisibilty(
      visible: !AppStrings.enableSingleVendor,
      child: VStack([
        Visibility(
          visible: title != null && title!.isNotBlank,
          child: Padding(
            padding: titlePadding ?? Vx.mSymmetric(v: 10, h: 20),
            child: HStack([
              "$title".text.lg.medium.make().expand(),
              if (onSeeAllPressed != null)
                "See more".tr().text.sm.make().onInkTap(
                  () => onSeeAllPressed!(),
                ),
            ], spacing: 10).wFull(context),
          ),
        ),
        if (scrollDirection == Axis.horizontal)
          CustomHScrollView(
            itemCount: vendors.length,
            isLoading: asyncVendors.isLoading,
            itemWidth: itemWidth ?? (context.percentWidth * 55),
            padding: listViewPadding,
            itemSpacing: 20,
            hideEmpty: hideEmpty,
            itemBuilder: (context, index) {
              final vendor = vendors[index];
              return FeaturedVendorListItem(
                vendor: vendor,
                onPressed: (v) => onVendorSelected?.call(v),
              );
            },
          ),
      ]),
    );
  }
}
