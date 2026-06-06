import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/card_commerce.dart';
import 'package:fuodz/component/custom_dynamic_grid_view.dart';
import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/food_card.dart';
import 'package:fuodz/component/list/commerce_product.list_item.dart';
import 'package:fuodz/component/list/grocery_product.list_item.dart';
import 'package:fuodz/component/list/horizontal_product.list_item.dart';
import 'package:fuodz/component/states/product.empty.dart';
import 'package:fuodz/models/category.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/providers/see_all_products_providers.dart';
import 'package:fuodz/utils/app_routes.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/utils/product_fetch_data_type.enum.dart';
import 'package:fuodz/utils/sizes.dart';

class ProducsPage extends ConsumerStatefulWidget {
  const ProducsPage({
    required this.title,
    this.vendorType,
    this.type = ProductFetchDataType.RANDOM,
    this.category,
    this.showGrid = true,
    super.key,
  });

  final String title;
  final ProductFetchDataType type;
  final VendorType? vendorType;
  final Category? category;
  final bool showGrid;

  @override
  ConsumerState<ProducsPage> createState() => _ProducsPageState();
}

class _ProducsPageState extends ConsumerState<ProducsPage> {
  final _refreshController = RefreshController();

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  SeeAllProductsArgs get _args => (
        type: widget.type,
        categoryId: widget.category?.id ?? 0,
        vendorTypeId: widget.vendorType?.id ?? 0,
      );

  void _open(Product product) {
    context.pushRoute('/products/${product.id}', extra: product);
  }

  // Stub: full add-to-cart wiring akan tersedia setelah cart module
  // dimigrasi ke Riverpod. Untuk sekarang, tap qty stepper buka detail produk.
  void _qtyChanged(Product product, int qty) => _open(product);

  @override
  Widget build(BuildContext context) {
    final asyncState =
        ref.watch(seeAllProductsControllerProvider(_args));
    final notifier =
        ref.read(seeAllProductsControllerProvider(_args).notifier);

    asyncState.whenData((s) {
      if (_refreshController.isRefresh) _refreshController.refreshCompleted();
      if (_refreshController.isLoading) _refreshController.loadComplete();
    });

    final products = asyncState.valueOrNull?.products ?? const [];
    final isBusy = asyncState.isLoading && products.isEmpty;

    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: widget.title,
      body: widget.showGrid
          ? CustomDynamicHeightGridView(
              crossAxisCount: 1,
              noScrollPhysics: true,
              refreshController: _refreshController,
              canRefresh: true,
              canPullUp: true,
              onRefresh: notifier.refresh,
              onLoading: notifier.loadMore,
              isLoading: isBusy,
              itemCount: products.length,
              crossAxisSpacing: Sizes.paddingSizeDefault,
              mainAxisSpacing: Sizes.paddingSizeDefault,
              padding: EdgeInsets.all(Sizes.paddingSizeDefault),
              itemBuilder: (context, index) {
                final product = products[index];
                if (product.vendor.vendorType.isFood) {
                  return FoodCard(
                    product: product,
                    onTap: () => context.pushRoute(
                      '${AppRoutes.product}/${product.id}',
                      extra: product,
                    ),
                  );
                }
                return CardCommerce(product);
              },
              separatorBuilder: (context, index) =>
                  Sizes.paddingSizeDefault.heightBox,
              emptyWidget: EmptyProduct(),
            )
          : CustomListView(
              refreshController: _refreshController,
              canRefresh: true,
              canPullUp: true,
              padding: EdgeInsets.all(Sizes.paddingSizeDefault),
              onRefresh: notifier.refresh,
              onLoading: notifier.loadMore,
              isLoading: isBusy,
              dataSet: products,
              itemBuilder: (context, index) {
                final product = products[index];
                if (product.vendor.vendorType.isGrocery) {
                  return GroceryProductListItem(
                    product: product,
                    onPressed: _open,
                    qtyUpdated: _qtyChanged,
                  );
                } else if (product.vendor.vendorType.isCommerce) {
                  return CommerceProductListItem(product, height: 80);
                }
                return HorizontalProductListItem(
                  product,
                  onPressed: _open,
                  qtyUpdated: _qtyChanged,
                );
              },
              separatorBuilder: (context, index) =>
                  Sizes.paddingSizeDefault.heightBox,
              emptyWidget: EmptyProduct(),
            ),
    );
  }
}
