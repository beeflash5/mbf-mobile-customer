import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/custom_masonry_grid_view.dart';
import 'package:fuodz/component/list/grocery_product.list_item.dart';
import 'package:fuodz/models/category.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/models/search.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/pages/product/product_details.page.dart';
import 'package:fuodz/providers/products_listing_providers.dart';
import 'package:fuodz/services/cart.helper.dart';
import 'package:fuodz/utils/app_routes.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/utils/product_fetch_data_type.enum.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class GroceryProductsSectionView extends ConsumerWidget {
  const GroceryProductsSectionView(
    this.title,
    this.vendorType, {
    this.type = ProductFetchDataType.RANDOM,
    this.category,
    this.showGrid = true,
    this.crossAxisCount = 2,
    this.onSeeAllPressed,
    super.key,
  });

  final String title;
  final bool showGrid;
  final int crossAxisCount;
  final VendorType vendorType;
  final ProductFetchDataType type;
  final Category? category;
  final Function? onSeeAllPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = (
      vendorTypeId: vendorType.id,
      type: type,
      categoryId: category?.id ?? 0,
      byLocation: false,
      isHome: false,
    );
    final asyncProducts =
        ref.watch(productsListingControllerProvider(args));
    final products = asyncProducts.valueOrNull ?? const <Product>[];
    final isLoading = asyncProducts.isLoading;
    final anyWithOptions = products.any((e) =>
        e.optionGroups.isNotEmpty && e.optionGroups.first.options.isNotEmpty);

    return CustomVisibilty(
      visible: products.isNotEmpty && !isLoading,
      child: VStack([
        HStack([
          title.text.xl.semiBold.make().expand(),
          UiSpacer.smHorizontalSpace(),
          "See all".tr().text.color(context.primaryColor).make().onInkTap(() {
            if (onSeeAllPressed != null) {
              onSeeAllPressed!();
            } else {
              final search = Search(
                category: category,
                vendorType: vendorType,
                showProductsTag: true,
              );
              context.pushRoute(AppRoutes.search, extra: search);
            }
          }),
        ]).p12(),
        if (!showGrid)
          CustomListView(
            isLoading: isLoading,
            dataSet: products,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: Vx.dp12),
            itemBuilder: (context, index) {
              return GroceryProductListItem(
                product: products[index],
                onPressed: (p) => context.pushWidget(ProductDetailsPage(product: p)),
                qtyUpdated: (p, q) =>
                    CartHelper.addToCartDirectly(context, p, q),
              );
            },
          ).h(anyWithOptions ? 220 : 180),
        if (showGrid)
          CustomMasonryGridView(
            isLoading: isLoading,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: crossAxisCount,
            items: products
                .map(
                  (product) => GroceryProductListItem(
                    product: product,
                    onPressed: (p) => context.pushWidget(ProductDetailsPage(product: p)),
                    qtyUpdated: (p, q) =>
                        CartHelper.addToCartDirectly(context, p, q),
                  ),
                )
                .toList(),
          ).px12(),
      ]).py12(),
    );
  }
}
