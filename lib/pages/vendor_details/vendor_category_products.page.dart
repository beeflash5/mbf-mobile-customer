import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/list/horizontal_product.list_item.dart';
import 'package:fuodz/models/category.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/pages/product/product_details.page.dart';
import 'package:fuodz/providers/vendor_category_products_providers.dart';
import 'package:fuodz/services/cart.helper.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class VendorCategoryProductsPage extends ConsumerStatefulWidget {
  const VendorCategoryProductsPage({
    required this.category,
    required this.vendor,
    super.key,
  });

  final Category category;
  final Vendor vendor;

  @override
  ConsumerState<VendorCategoryProductsPage> createState() =>
      _VendorCategoryProductsPageState();
}

class _VendorCategoryProductsPageState
    extends ConsumerState<VendorCategoryProductsPage>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  final Map<int, RefreshController> _refreshControllers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.category.subcategories.length,
      vsync: this,
    );
    for (final s in widget.category.subcategories) {
      _refreshControllers[s.id] = RefreshController();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final c in _refreshControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = (category: widget.category, vendor: widget.vendor);
    final asyncState =
        ref.watch(vendorCategoryProductsControllerProvider(args));
    final notifier =
        ref.read(vendorCategoryProductsControllerProvider(args).notifier);
    final s = asyncState.valueOrNull;

    asyncState.whenData((_) {
      for (final c in _refreshControllers.values) {
        if (c.isRefresh) c.refreshCompleted();
        if (c.isLoading) c.loadComplete();
      }
    });

    return BasePage(
      title: widget.category.name,
      showAppBar: true,
      showLeadingAction: true,
      showCart: true,
      body: NestedScrollView(
        headerSliverBuilder: (context, value) {
          return [
            SliverAppBar(
              backgroundColor: context.theme.primaryColor,
              title: "".text.make(),
              floating: true,
              pinned: true,
              snap: true,
              primary: false,
              automaticallyImplyLeading: false,
              flexibleSpace: TabBar(
                isScrollable: true,
                indicatorColor: Colors.white,
                indicatorWeight: 2,
                controller: _tabController,
                tabs: widget.category.subcategories
                    .map((sub) => Tab(text: sub.name))
                    .toList(),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: widget.category.subcategories.map((sub) {
            final products = s?.productsBySubcategory[sub.id] ?? const [];
            final loading = asyncState.isLoading && products.isEmpty;
            return CustomListView(
              noScrollPhysics: false,
              refreshController: _refreshControllers[sub.id],
              canPullUp: true,
              canRefresh: true,
              padding: const EdgeInsets.symmetric(vertical: 10),
              dataSet: products,
              isLoading: loading,
              onLoading: () => notifier.loadMore(sub.id),
              onRefresh: () => notifier.refreshSubcategory(sub.id),
              itemBuilder: (context, index) {
                final product = products[index];
                return HorizontalProductListItem(
                  product,
                  onPressed: (p) => context.pushWidget(ProductDetailsPage(product: p)),
                  qtyUpdated: (p, q) =>
                      CartHelper.addToCartDirectly(context, p, q),
                );
              },
              separatorBuilder: (context, index) =>
                  UiSpacer.verticalSpace(space: 5),
            );
          }).toList(),
        ),
      ),
    );
  }
}
