import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/busy_indicator.dart';
import 'package:fuodz/component/custom_grid_view.dart';
import 'package:fuodz/component/list/category.list_item.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/pages/vendor_details/widgets/vendor_details_header.view.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/providers/vendor_details_providers.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/app_ui_sizes.dart';

class VendorDetailsWithSubcategoryPage extends ConsumerWidget {
  const VendorDetailsWithSubcategoryPage({required this.vendor, super.key});

  final Vendor vendor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncVendor = ref.watch(vendorDetailsControllerProvider(vendor.id));
    final detail = asyncVendor.valueOrNull ?? vendor;
    final isLoading = asyncVendor.isLoading;

    return VStack([
      VendorDetailsHeader(detail, showPrescription: true),
      isLoading
          ? BusyIndicator().p20().centered()
          : CustomGridView(
            noScrollPhysics: true,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            childAspectRatio: AppUISizes.getAspectRatio(
              context,
              AppStrings.categoryPerRow,
              AppStrings.categoryImageHeight + 35,
            ),
            crossAxisCount: AppStrings.categoryPerRow,
            dataSet: detail.categories,
            padding: const EdgeInsets.all(20),
            itemBuilder: (ctx, index) {
              final category = detail.categories[index];
              return CategoryListItem(
                h: AppStrings.categoryImageHeight + 20,
                inverted: true,
                category: category,
                onPressed:
                    (category) => context.pushRoute(
                      '/vendors/${detail.id}/categories/${category.id}',
                      extra: {'vendor': detail, 'category': category},
                    ),
              );
            },
          ),
    ]).scrollVertical().expand();
  }
}
