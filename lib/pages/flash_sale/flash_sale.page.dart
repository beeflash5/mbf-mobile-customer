import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/custom_dynamic_grid_view.dart';
import 'package:fuodz/models/flash_sale.dart';
import 'package:fuodz/pages/flash_sale/widgets/flash_sale.item_view.dart';
import 'package:fuodz/providers/flash_sale_providers.dart';

class FlashSaleItemsPage extends ConsumerStatefulWidget {
  const FlashSaleItemsPage(this.flashSale, {super.key});

  final FlashSale flashSale;

  @override
  ConsumerState<FlashSaleItemsPage> createState() =>
      _FlashSaleItemsPageState();
}

class _FlashSaleItemsPageState extends ConsumerState<FlashSaleItemsPage> {
  final RefreshController _refreshController = RefreshController();

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flashSaleId = widget.flashSale.id ?? 0;
    final asyncState =
        ref.watch(flashSaleItemsControllerProvider(flashSaleId));
    final notifier =
        ref.read(flashSaleItemsControllerProvider(flashSaleId).notifier);

    // selesaikan RefreshController saat data baru sampai
    asyncState.whenData((s) {
      if (_refreshController.isRefresh) _refreshController.refreshCompleted();
      if (_refreshController.isLoading) _refreshController.loadComplete();
    });

    final items = asyncState.valueOrNull?.items ?? const [];
    final isBusy = asyncState.isLoading && items.isEmpty;

    return BasePage(
      title: widget.flashSale.name,
      showAppBar: true,
      showLeadingAction: true,
      body: CustomDynamicHeightGridView(
        refreshController: _refreshController,
        canPullUp: true,
        canRefresh: true,
        onRefresh: notifier.refresh,
        onLoading: notifier.loadMore,
        noScrollPhysics: true,
        padding: const EdgeInsets.all(15),
        loading: isBusy,
        itemCount: items.length,
        itemBuilder: (ctx, index) {
          return FlashSaleItemListItem(items[index], fullPage: true);
        },
      ),
    );
  }
}
