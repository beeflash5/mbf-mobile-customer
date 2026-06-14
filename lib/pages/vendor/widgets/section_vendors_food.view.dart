import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/component/card_vendor.dart';
import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/list/horizontal_vendor.list_item.dart';
import 'package:fuodz/component/list/vendor_home.list_item.dart';
import 'package:fuodz/component/states/vendor.empty.dart';
import 'package:fuodz/models/search.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/pages/vendor_details/vendor_details.page.dart';
import 'package:fuodz/providers/vendor_sections_providers.dart';
import 'package:fuodz/utils/app_strings.dart';

class SectionVendorsHomeView extends ConsumerWidget {
  const SectionVendorsHomeView(
    this.vendorType, {
    this.title = "",
    this.scrollDirection = Axis.vertical,
    this.type = SearchFilterType.sales,
    this.itemWidth,
    this.viewType,
    this.separator,
    this.byLocation = false,
    this.itemsPadding,
    this.titlePadding,
    this.hideEmpty = false,
    this.onSeeAllPressed,
    this.itemBuilder,
    this.spacer,
    super.key,
  });

  final VendorType? vendorType;
  final Axis scrollDirection;
  final SearchFilterType type;
  final String title;
  final double? itemWidth;
  final dynamic viewType;
  final Widget? separator;
  final bool byLocation;
  final EdgeInsets? itemsPadding;
  final EdgeInsets? titlePadding;
  final bool hideEmpty;
  final Function? onSeeAllPressed;
  final Widget Function(BuildContext, int, Vendor)? itemBuilder;
  final double? spacer;

  void _openVendor(BuildContext context, Vendor vendor) {
    context.pushWidget(VendorDetailsPage(vendor: vendor));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = (
      vendorTypeId: vendorType?.id ?? 0,
      type: type,
      byLocation: byLocation,
    );
    final asyncVendors = ref.watch(sectionVendorsControllerProvider(args));
    final vendors = asyncVendors.valueOrNull ?? const <Vendor>[];

    final Widget listView = CustomListView(
      scrollDirection: scrollDirection,
      padding: itemsPadding ?? const EdgeInsets.symmetric(horizontal: 10),
      dataSet: vendors,
      isLoading: asyncVendors.isLoading,
      noScrollPhysics: scrollDirection != Axis.horizontal,
      itemBuilder:
          itemBuilder != null
              ? (ctx, index) => itemBuilder!(ctx, index, vendors[index])
              : (context, index) {
                final vendor = vendors[index];
                if (viewType != null && viewType == HorizontalVendorListItem) {
                  return HorizontalVendorListItem(
                    vendor,
                    onPressed: (v) => _openVendor(context, v),
                  );
                } else if (vendor.vendorType.isFood) {
                  return CardVendor(
                    vendor: vendor,
                    onPressed: (v) => _openVendor(context, v),
                  ).w(itemWidth ?? (context.percentWidth * 50));
                } else {
                  return VendorHomeListItem(
                    vendor: vendor,
                    onPressed: (v) => _openVendor(context, v),
                  );
                }
              },
      emptyWidget: EmptyVendor(),
      separatorBuilder: separator != null ? (ctx, index) => separator! : null,
    );

    return CustomVisibilty(
      visible: !AppStrings.enableSingleVendor,
      child: Visibility(
        visible: !hideEmpty || vendors.isNotEmpty,
        child: VStack([
          Visibility(
            visible: title.isNotBlank,
            child: Padding(
              padding: titlePadding ?? const EdgeInsets.all(12),
              child: HStack([
                title.text.xl.semiBold.make().expand(),
                if (onSeeAllPressed != null)
                  "See more".tr().text.sm.make().onInkTap(
                    () => onSeeAllPressed!(),
                  ),
              ], spacing: 10).wFull(context),
            ),
          ),
          if (vendors.isEmpty)
            listView.h(240).wFull(context)
          else if (scrollDirection == Axis.horizontal)
            listView.h(210).wFull(context)
          else
            listView.wFull(context),
        ], spacing: spacer ?? 0),
      ),
    );
  }
}
