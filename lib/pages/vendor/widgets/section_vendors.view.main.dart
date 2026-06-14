import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/list/vendor.list_item.main..dart';
import 'package:fuodz/component/section.title.dart';
import 'package:fuodz/component/states/vendor.empty.dart';
import 'package:fuodz/models/search.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/pages/vendor_details/vendor_details.page.dart';
import 'package:fuodz/providers/vendor_sections_providers.dart';
import 'package:fuodz/utils/app_strings.dart';

class SectionVendorsViewMain extends ConsumerWidget {
  const SectionVendorsViewMain(
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
    super.key,
  });

  final VendorType vendorType;
  final Axis scrollDirection;
  final SearchFilterType type;
  final String title;
  final double? itemWidth;
  final dynamic viewType;
  final Widget? separator;
  final bool byLocation;
  final EdgeInsets? itemsPadding;
  final EdgeInsets? titlePadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = (vendorTypeId: vendorType.id, type: type, byLocation: true);
    final asyncVendors = ref.watch(sectionVendorsControllerProvider(args));
    final vendors = asyncVendors.valueOrNull ?? const <Vendor>[];

    final Widget listView = CustomListView(
      scrollDirection: scrollDirection,
      padding: itemsPadding ?? const EdgeInsets.symmetric(horizontal: 10),
      dataSet: vendors,
      isLoading: asyncVendors.isLoading,
      noScrollPhysics: scrollDirection != Axis.horizontal,
      itemBuilder: (context, index) {
        final vendor = vendors[index];
        return VendorListItemMain(
          vendor: vendor,
          onPressed: (v) => context.pushWidget(VendorDetailsPage(vendor: v)),
        ).w(itemWidth ?? (context.percentWidth * 50));
      },
      emptyWidget: EmptyVendor(),
      separatorBuilder: separator != null ? (ctx, index) => separator! : null,
    );

    return CustomVisibilty(
      visible: !AppStrings.enableSingleVendor,
      child: VStack([
        Visibility(
          visible: title.isNotBlank,
          child: Padding(
            padding: titlePadding ?? const EdgeInsets.all(12),
            child: SectionTitle(title),
          ),
        ),
        if (vendors.isEmpty)
          listView.h(240)
        else if (scrollDirection == Axis.horizontal)
          listView.h(195)
        else
          listView,
      ]),
    );
  }
}
