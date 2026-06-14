import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/custom_masonry_grid_view.dart';
import 'package:fuodz/component/list/commerce_product.list_item.dart';
import 'package:fuodz/component/list/dynamic_product.list_item.dart';
import 'package:fuodz/component/states/search.empty.dart';
import 'package:fuodz/pages/product/product_details.page.dart';
import 'package:fuodz/providers/main_search_providers.dart';

class ProductSearchResultView extends ConsumerStatefulWidget {
  const ProductSearchResultView({super.key});

  @override
  ConsumerState<ProductSearchResultView> createState() =>
      _ProductSearchResultViewState();
}

class _ProductSearchResultViewState
    extends ConsumerState<ProductSearchResultView> {
  final RefreshController _refreshController = RefreshController();

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(mainSearchControllerProvider);
    final notifier = ref.read(mainSearchControllerProvider.notifier);
    final state = asyncState.valueOrNull;
    final products = state?.products ?? const [];
    final isLoading = asyncState.isLoading;
    final layout = state?.search?.layoutType;

    asyncState.whenData((_) {
      if (_refreshController.isRefresh) _refreshController.refreshCompleted();
      if (_refreshController.isLoading) _refreshController.loadComplete();
    });

    void openProduct(product) =>
        context.pushWidget(ProductDetailsPage(product: product));

    if (layout == null || layout == 'grid') {
      return CustomMasonryGridView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        refreshController: _refreshController,
        canPullUp: true,
        canRefresh: true,
        onRefresh: () => notifier.startSearch(),
        onLoading: notifier.loadMoreProducts,
        isLoading: isLoading,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: (context.screenWidth / 2.5) / 100,
        emptyWidget: EmptySearch(type: 'product'),
        items:
            products
                .map((p) => CommerceProductListItem(p, height: 100))
                .toList(),
      );
    }
    return CustomListView(
      padding: const EdgeInsets.symmetric(vertical: 10),
      refreshController: _refreshController,
      canPullUp: true,
      canRefresh: true,
      onRefresh: () => notifier.startSearch(),
      onLoading: notifier.loadMoreProducts,
      dataSet: products,
      isLoading: isLoading,
      emptyWidget: EmptySearch(type: 'product'),
      itemBuilder: (ctx, index) {
        final product = products[index];
        return DynamicProductListItem(
          product,
          onPressed: openProduct,
          padding: EdgeInsets.zero,
        );
      },
      separatorBuilder: (_, __) => 12.heightBox,
    );
  }
}
