import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/custom_masonry_grid_view.dart';
import 'package:fuodz/component/list/commerce_product.list_item.dart';
import 'package:fuodz/models/category.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/models/search.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/providers/products_listing_providers.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_routes.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/utils/product_fetch_data_type.enum.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class ProductsSectionView extends ConsumerWidget {
  const ProductsSectionView(
    this.title, {
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
    final asyncProducts =
        ref.watch(productsListingControllerProvider(args));
    final products = asyncProducts.valueOrNull ?? const <Product>[];
    final isLoading = asyncProducts.isLoading;

    return CustomVisibilty(
      visible: !isLoading && products.isNotEmpty,
      child: VStack([
        HStack([
          (!titleCapitalize ? title : title.toUpperCase())
              .text
              .semiBold
              .xl
              .make()
              .expand(),
          UiSpacer.horizontalSpace(),
          HStack([
            "See all"
                .tr()
                .text
                .lg
                .medium
                .color(AppColor.primaryColor)
                .make(),
          ]).onInkTap(() {
            if (onSeeAllPressed != null) {
              onSeeAllPressed!();
            } else {
              _openSearchPage(context);
            }
          }),
        ]).wFull(context),
        UiSpacer.vSpace(10),
        CustomVisibilty(
          visible: !showGrid,
          child: CustomListView(
            isLoading: isLoading,
            dataSet: products,
            scrollDirection: scrollDirection ?? Axis.horizontal,
            separatorBuilder:
                (scrollDirection ?? Axis.horizontal) == Axis.horizontal
                    ? (_, __) => 12.widthBox
                    : null,
            itemBuilder: (context, index) {
              final product = products[index];
              return FittedBox(
                child: CommerceProductListItem(product, height: 80)
                    .w(context.percentWidth * 35)
                    .pOnly(bottom: itemBottomPadding ?? 0),
              );
            },
          ).h(itemHeight ?? (Platform.isAndroid ? 160 : 190)),
        ),
        CustomVisibilty(
          visible: showGrid,
          child: CustomMasonryGridView(
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            crossAxisCount: crossAxisCount ?? 2,
            isLoading: isLoading,
            items: List.generate(products.length, (index) {
              final product = products[index];
              return Container(
                constraints: BoxConstraints(
                  maxHeight: maxHeight ?? double.infinity,
                ),
                child: CommerceProductListItem(
                  product,
                  boxFit: BoxFit.cover,
                ).wFull(context),
              );
            }),
          ),
        ),
      ]).py12(),
    );
  }

  void _openSearchPage(BuildContext context) {
    final search = Search(
      type: type.name,
      category: category,
      vendorType: vendorType,
      showProductsTag: true,
      productDataFetchType: type,
    );
    context.pushRoute(AppRoutes.search, extra: search);
  }
}
