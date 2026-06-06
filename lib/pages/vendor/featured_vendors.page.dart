import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/list/featured_vendor.list_item.dart';
import 'package:fuodz/pages/vendor_details/vendor_details.page.dart';
import 'package:fuodz/providers/vendor_sections_providers.dart';

class FeaturedVendorsPage extends ConsumerStatefulWidget {
  const FeaturedVendorsPage({super.key});

  @override
  ConsumerState<FeaturedVendorsPage> createState() =>
      _FeaturedVendorsPageState();
}

class _FeaturedVendorsPageState extends ConsumerState<FeaturedVendorsPage> {
  final RefreshController _refreshController = RefreshController();

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(featuredVendorsControllerProvider);
    final notifier = ref.read(featuredVendorsControllerProvider.notifier);
    final s = asyncState.valueOrNull;
    final vendors = s?.vendors ?? const [];

    asyncState.whenData((_) {
      if (_refreshController.isRefresh) _refreshController.refreshCompleted();
      if (_refreshController.isLoading) _refreshController.loadComplete();
    });

    return BasePage(
      showAppBar: true,
      title: "Featured Vendors".tr(),
      showLeadingAction: true,
      body: CustomListView(
        isLoading: asyncState.isLoading && vendors.isEmpty,
        refreshController: _refreshController,
        canPullUp: true,
        canRefresh: true,
        onRefresh: () => notifier.refresh(),
        onLoading: () => notifier.loadMore(),
        padding: const EdgeInsets.all(12),
        dataSet: vendors,
        itemBuilder: (context, index) {
          final vendor = vendors[index];
          return FeaturedVendorListItem(
            vendor: vendor,
            onPressed: (v) => context.pushWidget(VendorDetailsPage(vendor: v)),
          );
        },
        separatorBuilder: (_, __) => 6.heightBox,
      ),
    );
  }
}
