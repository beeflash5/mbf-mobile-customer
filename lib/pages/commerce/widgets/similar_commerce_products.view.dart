import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/custom_masonry_grid_view.dart';
import 'package:fuodz/component/list/commerce_product.list_item.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/providers/products_listing_providers.dart';
import 'package:fuodz/utils/product_fetch_data_type.enum.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class SimilarCommerceProducts extends ConsumerWidget {
  const SimilarCommerceProducts(this.product, {super.key});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = (
      vendorTypeId: product.vendor.vendorType.id,
      type: ProductFetchDataType.RANDOM,
      categoryId: product.categoryId ?? 0,
      byLocation: false,
      isHome: false,
    );
    final asyncProducts =
        ref.watch(productsListingControllerProvider(args));
    final products = asyncProducts.valueOrNull ?? const <Product>[];

    return VStack([
      UiSpacer.verticalSpace(),
      UiSpacer.cutDivider(),
      'Related Products'
          .tr()
          .text
          .make()
          .wFull(context)
          .px20()
          .py12()
          .box
          .color(context.theme.colorScheme.surface)
          .make(),
      UiSpacer.verticalSpace(),
      CustomMasonryGridView(
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        isLoading: asyncProducts.isLoading,
        items: products
            .map((p) => CommerceProductListItem(p, height: 90))
            .toList(),
      ),
    ]);
  }
}
