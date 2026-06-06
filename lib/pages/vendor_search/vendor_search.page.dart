import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/bottom_sheet/search_filter.bottomsheet.dart';
import 'package:fuodz/component/busy_indicator.dart';
import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/list/grid_view_service.list_item.dart';
import 'package:fuodz/component/list/horizontal_product.list_item.dart';
import 'package:fuodz/component/states/search.empty.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/models/search.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/pages/product/product_details.page.dart';
import 'package:fuodz/pages/search/widget/search.header.dart';
import 'package:fuodz/pages/service/service_details.page.dart';
import 'package:fuodz/providers/search_providers.dart';
import 'package:fuodz/services/cart.helper.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class VendorSearchPage extends ConsumerStatefulWidget {
  const VendorSearchPage(this.vendor, {super.key});

  final Vendor vendor;

  @override
  ConsumerState<VendorSearchPage> createState() => _VendorSearchPageState();
}

class _VendorSearchPageState extends ConsumerState<VendorSearchPage> {
  final TextEditingController _searchTEC = TextEditingController();
  final RefreshController _refreshController = RefreshController();
  late final Search _search;

  @override
  void initState() {
    super.initState();
    _search = Search(
      vendorId: widget.vendor.id,
      vendorType: widget.vendor.vendorType.isService
          ? widget.vendor.vendorType
          : null,
      type: widget.vendor.vendorType.isService ? 'service' : 'product',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchControllerProvider(_search).notifier).startSearch();
    });
  }

  @override
  void dispose() {
    _searchTEC.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(searchControllerProvider(_search));
    final notifier = ref.read(searchControllerProvider(_search).notifier);
    final state = asyncState.valueOrNull;
    final results = state?.results ?? const [];
    final isLoading = asyncState.isLoading;

    asyncState.whenData((_) {
      if (_refreshController.isRefresh) _refreshController.refreshCompleted();
      if (_refreshController.isLoading) _refreshController.loadComplete();
    });

    return BasePage(
      showCartView: true,
      body: SafeArea(
        bottom: false,
        child: VStack([
          SearchHeader(
            searchTEC: _searchTEC,
            subtitle: "",
            showCancel: true,
            onSubmitted: (keyword) {
              notifier.setKeyword(keyword);
              notifier.startSearch();
            },
            onFilterPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => SearchFilterBottomSheet(
                search: state?.search ?? _search,
                onSubmitted: notifier.updateSearch,
              ),
            ),
          ),
          isLoading ? BusyIndicator().centered() : UiSpacer.emptySpace(),
          CustomListView(
            refreshController: _refreshController,
            canRefresh: true,
            canPullUp: true,
            onRefresh: notifier.startSearch,
            onLoading: () => notifier.startSearch(initialLoading: false),
            isLoading: isLoading,
            dataSet: results,
            itemBuilder: (context, index) {
              final r = results[index];
              if (r is Product) {
                return HorizontalProductListItem(
                  r,
                  onPressed: (p) => context.pushWidget(ProductDetailsPage(product: p)),
                  qtyUpdated: (p, q) =>
                      CartHelper.addToCartDirectly(context, p, q),
                );
              }
              return GridViewServiceListItem(
                service: r as Service,
                onPressed: (s) => context.pushWidget(ServiceDetailsPage(s)),
              );
            },
            separatorBuilder: (context, index) =>
                UiSpacer.verticalSpace(space: 0),
            emptyWidget: EmptySearch(),
          ).py12().expand(),
        ]).pOnly(top: Vx.dp16, left: Vx.dp16, right: Vx.dp16),
      ),
    );
  }
}
