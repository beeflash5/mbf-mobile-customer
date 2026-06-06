import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/list/coupon.list_item.dart';
import 'package:fuodz/component/section.title.dart';
import 'package:fuodz/models/search.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/providers/coupons_providers.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class SectionCouponsView extends ConsumerWidget {
  const SectionCouponsView(
    this.vendorType, {
    this.title = '',
    this.scrollDirection = Axis.vertical,
    this.type = SearchFilterType.sales,
    this.itemWidth,
    this.viewType,
    this.separator,
    this.byLocation = false,
    this.itemsPadding,
    this.titlePadding,
    this.height,
    this.bPadding = 0,
    super.key,
  });

  final VendorType? vendorType;
  final Axis scrollDirection;
  final SearchFilterType type;
  final String title;
  final double? height;
  final double? itemWidth;
  final dynamic viewType;
  final Widget? separator;
  final bool byLocation;
  final EdgeInsets? itemsPadding;
  final EdgeInsets? titlePadding;
  final double bPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couponsAsync =
        ref.watch(couponsByVendorTypeProvider(vendorType?.id ?? 0));
    final coupons = couponsAsync.valueOrNull ?? const [];
    final isBusy = couponsAsync.isLoading;

    final listView = CustomListView(
      scrollDirection: scrollDirection,
      padding: itemsPadding ?? const EdgeInsets.symmetric(horizontal: 10),
      dataSet: coupons,
      isLoading: isBusy,
      noScrollPhysics: scrollDirection != Axis.horizontal,
      itemBuilder: (context, index) {
        final coupon = coupons[index];
        return CouponListItem(
          coupon,
          onPressed: (c) => context.pushRoute('/coupons/${c.id}', extra: c),
        ).w(itemWidth ?? (context.percentWidth * 50));
      },
      separatorBuilder:
          separator != null ? (ctx, index) => separator! : null,
    );

    if (coupons.isEmpty && !isBusy) return UiSpacer.emptySpace();
    return VStack([
      Visibility(
        visible: title.isNotBlank,
        child: Padding(
          padding: titlePadding ?? const EdgeInsets.all(12),
          child: SectionTitle(title),
        ),
      ),
      if (scrollDirection == Axis.horizontal)
        listView.h(height ?? 195)
      else
        listView,
      UiSpacer.vSpace(bPadding),
    ]);
  }
}
