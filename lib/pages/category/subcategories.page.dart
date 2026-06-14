import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/custom_dynamic_grid_view.dart';
import 'package:fuodz/component/list/category.list_item.dart';
import 'package:fuodz/component/states/subcategories.empty.dart';
import 'package:fuodz/models/category.dart';
import 'package:fuodz/models/search.dart';
import 'package:fuodz/providers/vendor_sections_providers.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/utils/utils.dart';

class SubcategoriesPage extends ConsumerStatefulWidget {
  const SubcategoriesPage({required this.category, super.key});

  final Category category;

  @override
  ConsumerState<SubcategoriesPage> createState() => _SubcategoriesPageState();
}

class _SubcategoriesPageState extends ConsumerState<SubcategoriesPage> {
  final RefreshController _refreshController = RefreshController();

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncSubcats = ref.watch(
      subcategoriesControllerProvider(widget.category.id),
    );
    final items = asyncSubcats.valueOrNull ?? const [];

    asyncSubcats.whenData((_) {
      if (_refreshController.isRefresh) _refreshController.refreshCompleted();
    });

    return BasePage(
      showAppBar: true,
      showCart: true,
      showLeadingAction: true,
      title: widget.category.name,
      body: CustomDynamicHeightGridView(
        noScrollPhysics: true,
        crossAxisCount: AppStrings.categoryPerRow,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        isLoading: asyncSubcats.isLoading,
        itemCount: items.length,
        canRefresh: true,
        refreshController: _refreshController,
        onRefresh: () async {
          ref.invalidate(subcategoriesControllerProvider(widget.category.id));
          await ref.read(
            subcategoriesControllerProvider(widget.category.id).future,
          );
        },
        padding: const EdgeInsets.all(12),
        emptyWidget: EmptySubcategoriesView(),
        itemBuilder: (context, index) {
          final c = items[index];
          return CategoryListItem(
            category: c,
            onPressed: (cat) {
              final search = Search(
                vendorType: cat.vendorType,
                subcategory: cat,
                showProductsTag: !(cat.vendorType?.isService ?? false),
                showVendorsTag: !(cat.vendorType?.isService ?? false),
                showServicesTag: (cat.vendorType?.isService ?? false),
                showProvidesTag: (cat.vendorType?.isService ?? false),
              );
              context.pushRoute('/search', extra: search);
            },
            maxLine: false,
            textColor: Utils.textColorByBrightness(),
          );
        },
      ),
    );
  }
}
