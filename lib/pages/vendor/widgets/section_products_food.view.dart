import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/button/custom_button_light.dart';
import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/food_card.dart';
import 'package:fuodz/component/states/vendor.empty.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/pages/product/product_details.page.dart';
import 'package:fuodz/providers/products_listing_providers.dart';
import 'package:fuodz/services/product_search.helper.dart';
import 'package:fuodz/utils/product_fetch_data_type.enum.dart';

class SectionProductFoodsView extends ConsumerWidget {
  const SectionProductFoodsView(
    this.vendorType, {
    this.title = "",
    this.scrollDirection = Axis.vertical,
    this.type = ProductFetchDataType.BEST,
    this.itemWidth,
    this.itemHeight,
    this.viewType,
    this.listHeight = 195,
    this.separator,
    this.byLocation = false,
    this.hideEmpty = false,
    this.itemsPadding,
    this.titlePadding,
    this.spacer,
    super.key,
  });

  final VendorType? vendorType;
  final Axis scrollDirection;
  final ProductFetchDataType type;
  final String title;
  final double? itemWidth;
  final double? itemHeight;
  final dynamic viewType;
  final double? listHeight;
  final Widget? separator;
  final bool byLocation;
  final EdgeInsets? itemsPadding;
  final EdgeInsets? titlePadding;
  final double? spacer;
  final bool hideEmpty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = (
      vendorTypeId: vendorType?.id ?? 0,
      type: type,
      categoryId: 0,
      byLocation: byLocation,
      isHome: false,
    );
    final asyncProducts =
        ref.watch(productsListingControllerProvider(args));
    final products = asyncProducts.valueOrNull ?? const <Product>[];
    final isLoading = asyncProducts.isLoading;

    if (!isLoading && products.isEmpty && hideEmpty) return 0.widthBox;

    Widget listView = CustomListView(
      noScrollPhysics: true,
      scrollDirection: Axis.vertical,
      padding: itemsPadding ?? const EdgeInsets.symmetric(horizontal: 10),
      dataSet: products,
      isLoading: isLoading,
      itemBuilder: (context, index) {
        final product = products[index];
        Widget itemView = FoodCard(
          product: product,
          onTap: () => context.pushWidget(ProductDetailsPage(product: product)),
        );
        if (itemWidth != null) return itemView.w(itemWidth!);
        return itemView;
      },
      emptyWidget: EmptyVendor(),
      separatorBuilder:
          separator != null ? (ctx, index) => separator! : null,
    );

    return CustomVisibilty(
      child: CustomVisibilty(
        visible: !isLoading && products.isNotEmpty,
        child: VStack([
          const SizedBox(height: 16),
          Padding(
            padding:
                titlePadding ?? const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                "Popular Foods Nearby".tr().text.bold.xl.make(),
                "Best selling products around selected location"
                    .tr()
                    .text
                    .make(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          listView,
          const SizedBox(height: 10),
          products.isNotEmpty
              ? CustomButtonLight(
                  title: "View All".tr(),
                  onPressed: () =>
                      ProductSearchHelper.openProductsSeeAllPage(
                    title: "Popular".tr(),
                    vendorType: vendorType,
                    type: ProductFetchDataType.BEST,
                  ),
                )
              : const SizedBox(),
        ], spacing: spacer ?? 5),
      ),
    );
  }
}
