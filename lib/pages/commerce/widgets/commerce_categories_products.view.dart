import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/pages/commerce/widgets/products_section.view.dart';
import 'package:fuodz/providers/vendor_sections_providers.dart';
import 'package:fuodz/services/product_search.helper.dart';

class CommerceCategoryProducts extends ConsumerWidget {
  const CommerceCategoryProducts(this.vendorType, {this.length = 2, super.key});

  final VendorType vendorType;
  final int length;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = (vendorTypeId: vendorType.id, page: null as int?);
    final asyncCategories = ref.watch(vendorCategoriesControllerProvider(args));
    final categories = asyncCategories.valueOrNull ?? const [];

    final shown = categories.sublist(
      0,
      categories.length < length ? categories.length : length,
    );

    return VStack([
      ...shown.map(
        (category) => ProductsSectionView(
          category.name,
          vendorType: vendorType,
          category: category,
          showGrid: false,
          onSeeAllPressed:
              () => ProductSearchHelper.openProductsSeeAllPage(
                title: category.name,
                vendorType: vendorType,
                category: category,
              ),
        ),
      ),
    ]);
  }
}
