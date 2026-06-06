import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/list/commerce_product.list_item.dart';
import 'package:fuodz/component/list/food_horizontal_product.list_item.dart';
import 'package:fuodz/component/list/grid_view_product.list_item.dart';
import 'package:fuodz/component/list/grocery_product.list_item.dart';
import 'package:fuodz/component/list/horizontal_product.list_item.dart';
import 'package:fuodz/component/section.title.dart';
import 'package:fuodz/component/states/vendor.empty.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/pages/product/product_details.page.dart';
import 'package:fuodz/providers/products_listing_providers.dart';
import 'package:fuodz/services/cart.helper.dart';
import 'package:fuodz/utils/product_fetch_data_type.enum.dart';

class SectionProductsView extends ConsumerWidget {
  const SectionProductsView(
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

  void _openProduct(BuildContext context, Product p) {
    context.pushWidget(ProductDetailsPage(product: p));
  }

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
      scrollDirection: scrollDirection,
      padding: itemsPadding ?? const EdgeInsets.symmetric(horizontal: 10),
      dataSet: products,
      isLoading: isLoading,
      noScrollPhysics: scrollDirection != Axis.horizontal,
      itemBuilder: (context, index) {
        final product = products[index];
        Widget itemView;
        if (viewType != null && viewType == HorizontalProductListItem) {
          itemView = HorizontalProductListItem(
            product,
            qtyUpdated: (p, q) => CartHelper.addToCartDirectly(context, p, q),
            onPressed: (p) => _openProduct(context, p),
            height: itemHeight,
          );
        } else if (viewType != null &&
            viewType == FoodHorizontalProductListItem) {
          itemView = FoodHorizontalProductListItem(
            product,
            qtyUpdated: (p, q) => CartHelper.addToCartDirectly(context, p, q),
            onPressed: (p) => _openProduct(context, p),
            height: itemHeight,
          );
        } else if (viewType != null && viewType == GridViewProductListItem) {
          itemView = GridViewProductListItem(
            product: product,
            qtyUpdated: (p, q) => CartHelper.addToCartDirectly(context, p, q),
            onPressed: (p) => _openProduct(context, p),
          );
        } else {
          if (product.vendor.vendorType.isGrocery) {
            itemView = GroceryProductListItem(
              product: product,
              onPressed: (p) => _openProduct(context, p),
              qtyUpdated: (p, q) =>
                  CartHelper.addToCartDirectly(context, p, q),
            );
          }
          itemView = CommerceProductListItem(product, height: 80);
        }
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
          Padding(
            padding:
                titlePadding ?? const EdgeInsets.symmetric(horizontal: 12),
            child: SectionTitle(title),
          ),
          if (products.isEmpty)
            listView.h(240)
          else if (listHeight != null)
            listView.h(listHeight!)
          else
            listView,
        ], spacing: spacer ?? 5),
      ),
    );
  }
}
