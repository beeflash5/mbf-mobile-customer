import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/bottom_sheet/search_filter.bottomsheet.dart';
import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/component/custom_dynamic_grid_view.dart';
import 'package:fuodz/component/custom_easy_refresh_view.dart';
import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/list/commerce_product.list_item.dart';
import 'package:fuodz/component/list/grid_view_service.list_item.dart';
import 'package:fuodz/component/list/grocery_product.list_item.dart';
import 'package:fuodz/component/list/horizontal_product.list_item.dart';
import 'package:fuodz/component/list/vendor.list_item.dart';
import 'package:fuodz/component/states/search.empty.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/models/search.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/pages/product/product_details.page.dart';
import 'package:fuodz/pages/search/widget/search.header.dart';
import 'package:fuodz/pages/search/widget/vendor_search_header.view.dart';
import 'package:fuodz/pages/service/service_details.page.dart';
import 'package:fuodz/pages/vendor_details/vendor_details.page.dart';
import 'package:fuodz/providers/search_providers.dart';
import 'package:fuodz/services/cart.helper.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key, required this.search, this.showCancel = true});

  final Search search;
  final bool showCancel;

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchTEC = TextEditingController();
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier =
          ref.read(searchControllerProvider(widget.search).notifier);
      notifier.setSelectedTag(2);
      notifier.startSearch();
    });
  }

  @override
  void dispose() {
    _searchTEC.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void _openProduct(Product p) => context.pushWidget(ProductDetailsPage(product: p));
  void _openService(Service s) => context.pushWidget(ServiceDetailsPage(s));
  void _openVendor(Vendor v) => context.pushWidget(VendorDetailsPage(vendor: v));

  @override
  Widget build(BuildContext context) {
    final asyncState =
        ref.watch(searchControllerProvider(widget.search));
    final notifier =
        ref.read(searchControllerProvider(widget.search).notifier);
    final state = asyncState.valueOrNull;
    final results = state?.results ?? const [];
    final selectTagId = state?.selectedTagId ?? 2;
    final showGrid = state?.showGrid ?? false;
    final isLoading = asyncState.isLoading;

    asyncState.whenData((_) {
      if (_refreshController.isRefresh) _refreshController.refreshCompleted();
      if (_refreshController.isLoading) _refreshController.loadComplete();
    });

    return BasePage(
      showCartView: widget.showCancel,
      body: SafeArea(
        bottom: false,
        child: VStack([
          UiSpacer.verticalSpace(),
          SearchHeader(
            searchTEC: _searchTEC,
            showCancel: widget.showCancel,
            onSubmitted: (keyword) {
              notifier.setKeyword(keyword);
              notifier.startSearch();
            },
            onFilterPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => SearchFilterBottomSheet(
                search: state?.search ?? widget.search,
                onSubmitted: notifier.updateSearch,
              ),
            ),
          ),
          Visibility(
            visible: (state?.search?.byLocation ?? true) &&
                results.isEmpty &&
                !isLoading,
            child: "Results are currently based on your location. You can disable this in the filter section."
                .tr()
                .text
                .center
                .gray500
                .makeCentered()
                .py(10),
          ),
          VendorSearchHeaderview(
            selectedTagId: selectTagId,
            onSelectTag: notifier.setSelectedTag,
            showProducts: true,
            showVendors: true,
          ),
          if (selectTagId == 1)
            CustomEasyRefreshView(
              onRefresh: notifier.startSearch,
              onLoad: () => notifier.startSearch(initialLoading: false),
              loading: isLoading,
              dataset: results,
              padding: const EdgeInsets.all(12),
              listView: results.map((r) {
                if (r is Product) {
                  if (r.vendor.vendorType.isGrocery) {
                    return GroceryProductListItem(
                      product: r,
                      onPressed: _openProduct,
                      qtyUpdated: (p, q) =>
                          CartHelper.addToCartDirectly(context, p, q),
                    );
                  } else if (r.vendor.vendorType.isCommerce) {
                    return CommerceProductListItem(r, height: 80);
                  }
                  return HorizontalProductListItem(
                    r,
                    onPressed: _openProduct,
                    qtyUpdated: (p, q) =>
                        CartHelper.addToCartDirectly(context, p, q),
                    padding: 0,
                  );
                } else if (r is Service) {
                  return GridViewServiceListItem(
                    service: r,
                    onPressed: _openService,
                  );
                }
                return VendorListItem(
                  vendor: r as Vendor,
                  onPressed: _openVendor,
                );
              }).toList(),
            ).expand(),
          CustomVisibilty(
            visible: selectTagId != 1,
            child: VStack([
              CustomVisibilty(
                visible: !showGrid,
                child: CustomListView(
                  refreshController: _refreshController,
                  canRefresh: true,
                  canPullUp: true,
                  onRefresh: notifier.startSearch,
                  onLoading: () =>
                      notifier.startSearch(initialLoading: false),
                  isLoading: isLoading,
                  padding: const EdgeInsets.all(12),
                  dataSet: results,
                  itemBuilder: (context, index) {
                    final r = results[index];
                    if (r is Product) {
                      if (r.vendor.vendorType.isGrocery) {
                        return GroceryProductListItem(
                          product: r,
                          onPressed: _openProduct,
                          qtyUpdated: (p, q) =>
                              CartHelper.addToCartDirectly(context, p, q),
                        );
                      } else if (r.vendor.vendorType.isCommerce) {
                        return CommerceProductListItem(r, height: 80);
                      }
                      return HorizontalProductListItem(
                        r,
                        onPressed: _openProduct,
                        qtyUpdated: (p, q) =>
                            CartHelper.addToCartDirectly(context, p, q),
                        padding: 0,
                      );
                    } else if (r is Service) {
                      return GridViewServiceListItem(
                        service: r,
                        onPressed: _openService,
                      );
                    }
                    return VendorListItem(
                      vendor: r as Vendor,
                      onPressed: _openVendor,
                    );
                  },
                  separatorBuilder: (context, index) => 10.heightBox,
                  emptyWidget: EmptySearch(),
                ).expand(),
              ),
              CustomVisibilty(
                visible: showGrid,
                child: CustomDynamicHeightGridView(
                  noScrollPhysics: true,
                  refreshController: _refreshController,
                  canRefresh: true,
                  canPullUp: true,
                  onRefresh: notifier.startSearch,
                  onLoading: () =>
                      notifier.startSearch(initialLoading: false),
                  isLoading: isLoading,
                  itemCount: results.length,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (context, index) {
                    final r = results[index];
                    if (r is Product) {
                      return CommerceProductListItem(r, height: 80);
                    } else if (r is Service) {
                      return GridViewServiceListItem(
                        service: r,
                        onPressed: _openService,
                      );
                    }
                    return VendorListItem(
                      vendor: r as Vendor,
                      onPressed: _openVendor,
                    );
                  },
                  separatorBuilder: (context, index) =>
                      UiSpacer.verticalSpace(space: 10),
                  emptyWidget: EmptySearch(),
                ).expand(),
              ),
            ]).expand(),
          ),
        ]).pOnly(left: Vx.dp16, right: Vx.dp16),
      ),
    );
  }
}
