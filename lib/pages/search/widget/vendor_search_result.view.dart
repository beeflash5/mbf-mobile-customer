import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import 'package:fuodz/component/card_vendor.dart';
import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/custom_masonry_grid_view.dart';
import 'package:fuodz/component/list/dynamic_vendor.list_item.dart';
import 'package:fuodz/component/states/search.empty.dart';
import 'package:fuodz/pages/vendor_details/vendor_details.page.dart';
import 'package:fuodz/providers/main_search_providers.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class VendorSearchResultView extends ConsumerStatefulWidget {
  const VendorSearchResultView({super.key});

  @override
  ConsumerState<VendorSearchResultView> createState() =>
      _VendorSearchResultViewState();
}

class _VendorSearchResultViewState
    extends ConsumerState<VendorSearchResultView> {
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
    final vendors = state?.vendors ?? const [];
    final isLoading = asyncState.isLoading;
    final layout = state?.search?.layoutType;

    asyncState.whenData((_) {
      if (_refreshController.isRefresh) _refreshController.refreshCompleted();
      if (_refreshController.isLoading) _refreshController.loadComplete();
    });

    void openVendor(vendor) =>
        context.pushWidget(VendorDetailsPage(vendor: vendor));

    if (layout == null || layout == 'grid') {
      return CustomMasonryGridView(
        crossAxisCount: 1,
        padding: const EdgeInsets.symmetric(vertical: 12),
        refreshController: _refreshController,
        canPullUp: true,
        canRefresh: true,
        onRefresh: () => notifier.startSearch(),
        onLoading: notifier.loadMoreVendors,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        isLoading: isLoading,
        emptyWidget: EmptySearch(type: 'vendor'),
        items:
            vendors
                .map((v) => CardVendor(vendor: v, onPressed: openVendor))
                .toList(),
      );
    }
    return CustomListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      refreshController: _refreshController,
      canPullUp: true,
      canRefresh: true,
      onRefresh: () => notifier.startSearch(),
      onLoading: notifier.loadMoreVendors,
      dataSet: vendors,
      isLoading: isLoading,
      emptyWidget: EmptySearch(type: 'vendor'),
      itemBuilder: (ctx, index) {
        final vendor = vendors[index];
        return DynamicVendorListItem(
          vendor,
          onPressed: openVendor,
          width: double.infinity,
        );
      },
      separatorBuilder: (_, __) => UiSpacer.vSpace(10),
    );
  }
}
