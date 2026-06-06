import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/states/loading.shimmer.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/pages/service/widgets/category_services.view.dart';
import 'package:fuodz/providers/vendor_lists_providers.dart';

class CategoriesServicesView extends ConsumerWidget {
  const CategoriesServicesView(
    this.vendorType, {
    super.key,
    this.showTitle = true,
    this.maxCategories,
  });

  final VendorType vendorType;
  final bool showTitle;
  final int? maxCategories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = (
      vendorTypeId: vendorType.id,
      maxCategories: maxCategories ?? 0,
    );
    final asyncCats = ref.watch(categoriesServicesControllerProvider(args));
    final categories = asyncCats.valueOrNull ?? const [];
    final isLoading = asyncCats.isLoading;

    if (!isLoading && categories.isEmpty) return const SizedBox.shrink();

    return VStack([
      ...categories.map(
        (category) => LoadingShimmer(
          loading: isLoading,
          child: CategoryServicesView(
            category,
            loading: isLoading,
            hideEmpty: true,
            showTitle: true,
          ),
        ),
      ),
    ], spacing: 10).py12();
  }
}
