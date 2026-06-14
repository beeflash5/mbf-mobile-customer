import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/button/custom_button_light.dart';
import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/component/card_commerce.dart';
import 'package:fuodz/component/custom_masonry_grid_view.dart';
import 'package:fuodz/component/states/loading.shimmer.dart';
import 'package:fuodz/models/category.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/providers/products_listing_providers.dart';
import 'package:fuodz/services/product_search.helper.dart';
import 'package:fuodz/utils/product_fetch_data_type.enum.dart';

class ProductsNewArival extends ConsumerWidget {
  const ProductsNewArival(
    this.title,
    this.subtitle, {
    this.vendorType,
    this.category,
    this.type = ProductFetchDataType.RANDOM,
    this.showGrid = true,
    this.crossAxisCount,
    this.scrollDirection,
    this.itemBottomPadding,
    this.itemHeight,
    this.titleCapitalize = true,
    this.onSeeAllPressed,
    this.maxHeight,
    super.key,
  });

  final String title;
  final String subtitle;
  final VendorType? vendorType;
  final ProductFetchDataType type;
  final Category? category;
  final bool showGrid;
  final int? crossAxisCount;
  final Axis? scrollDirection;
  final double? itemBottomPadding;
  final double? itemHeight;
  final bool titleCapitalize;
  final Function? onSeeAllPressed;
  final double? maxHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = (
      vendorTypeId: vendorType?.id ?? 0,
      type: type,
      categoryId: category?.id ?? 0,
      byLocation: false,
      isHome: false,
    );
    final asyncProducts = ref.watch(productsListingControllerProvider(args));
    final products = asyncProducts.valueOrNull ?? const <Product>[];
    final isLoading = asyncProducts.isLoading;

    if (isLoading) return LoadingShimmer().px20().h(150);

    return CustomVisibilty(
      visible: !isLoading && products.isNotEmpty,
      child:
          VStack([
            HStack([const SizedBox(height: 20)]).wFull(context),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title.tr().text.bold.xl.make(),
                subtitle.tr().text.make(),
              ],
            ),
            const SizedBox(height: 20),
            CustomVisibilty(
              visible: showGrid,
              child: CustomMasonryGridView(
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                crossAxisCount: 1,
                isLoading: isLoading,
                items: List.generate(products.length, (index) {
                  final product = products[index];
                  return Container(
                    constraints: BoxConstraints(
                      maxHeight: maxHeight ?? double.infinity,
                    ),
                    child: CardCommerce(
                      product,
                      boxFit: BoxFit.cover,
                    ).wFull(context),
                  );
                }),
              ),
            ),
            products.isNotEmpty
                ? CustomButtonLight(
                  title: "View All".tr(),
                  onPressed:
                      () => ProductSearchHelper.openProductsSeeAllPage(
                        title: "New Arrivals".tr(),
                        vendorType: vendorType,
                        type: ProductFetchDataType.NEW,
                      ),
                )
                : const SizedBox(),
          ]).py12(),
    );
  }
}
