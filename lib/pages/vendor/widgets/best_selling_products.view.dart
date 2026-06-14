import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/custom_dynamic_grid_view.dart';
import 'package:fuodz/component/list/commerce_product.list_item.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/providers/vendor_sections_providers.dart';
import 'package:fuodz/services/product_search.helper.dart';
import 'package:fuodz/utils/product_fetch_data_type.enum.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class BestSellingProducts extends ConsumerWidget {
  const BestSellingProducts(this.vendorType, {this.imageHeight, super.key});

  final VendorType vendorType;
  final double? imageHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProducts = ref.watch(
      bestSellingProductsControllerProvider(vendorType.id),
    );
    final products = asyncProducts.valueOrNull ?? const [];

    return VStack([
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          "Best Selling".tr().text.semiBold.lg.make(),
          "See all"
              .tr()
              .text
              .color(const Color(0xFF1B8A9E))
              .make()
              .onTap(
                () => ProductSearchHelper.openProductsSeeAllPage(
                  title: "Best Selling".tr(),
                  vendorType: vendorType,
                  type: ProductFetchDataType.BEST,
                ),
              ),
        ],
      ).px12().py2(),
      CustomDynamicHeightGridView(
        noScrollPhysics: true,
        separatorBuilder: (context, index) => UiSpacer.smHorizontalSpace(),
        itemCount: products.length,
        isLoading: asyncProducts.isLoading,
        itemBuilder:
            (context, index) => CommerceProductListItem(
              products[index],
              height: imageHeight ?? 80,
            ),
      ).px12().py2(),
    ], spacing: 10);
  }
}
