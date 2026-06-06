import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/custom_dynamic_grid_view.dart';
import 'package:fuodz/component/list/category.list_item.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/pages/service/widgets/modern_category_gridview.list_item.dart';
import 'package:fuodz/providers/vendor_sections_providers.dart';
import 'package:fuodz/services/navigation.service.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/utils.dart';

class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({this.vendorType, super.key});

  final VendorType? vendorType;

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage> {
  final RefreshController _refreshController = RefreshController();

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = (
      vendorTypeId: widget.vendorType?.id ?? 0,
      page: null as int?,
    );
    final asyncCategories =
        ref.watch(vendorCategoriesControllerProvider(args));
    final categories = asyncCategories.valueOrNull ?? const [];
    final isLoading = asyncCategories.isLoading;
    final isService = widget.vendorType?.isService ?? false;

    asyncCategories.whenData((_) {
      if (_refreshController.isRefresh) _refreshController.refreshCompleted();
    });

    return BasePage(
      showAppBar: true,
      showCart: true,
      showLeadingAction: true,
      title: "Categories".tr(),
      body: CustomDynamicHeightGridView(
        noScrollPhysics: true,
        crossAxisCount: isService ? 2 : AppStrings.categoryPerRow,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        isLoading: isLoading,
        itemCount: categories.length,
        canRefresh: true,
        refreshController: _refreshController,
        onRefresh: () async {
          ref.invalidate(vendorCategoriesControllerProvider(args));
          await ref.read(vendorCategoriesControllerProvider(args).future);
        },
        padding: const EdgeInsets.all(20),
        itemBuilder: (context, index) {
          final cat = categories[index];
          if (isService) {
            return ModernCategoryGridviewListItem(
              category: cat,
              onPressed: NavigationService.categorySelected,
            );
          }
          return CategoryListItem(
            category: cat,
            onPressed: NavigationService.categorySelected,
            maxLine: false,
            textColor: Utils.textColorByBrightness(),
          );
        },
      ),
    );
  }
}
