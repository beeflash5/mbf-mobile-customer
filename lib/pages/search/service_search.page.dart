import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/bottom_sheet/search_filter.bottomsheet.dart';
import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/component/card_vendor.dart';
import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/custom_masonry_grid_view.dart';
import 'package:fuodz/component/list/grid_view_service.list_item.dart';
import 'package:fuodz/component/list/home_services.list_item.dart';
import 'package:fuodz/component/list/home_services.list_item_tatto.dart';
import 'package:fuodz/component/list/vendor.list_item.dart';
import 'package:fuodz/component/states/service_search.empty.dart';
import 'package:fuodz/models/category.dart';
import 'package:fuodz/models/search.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/pages/search/widget/search.header.dart';
import 'package:fuodz/pages/search/widget/vendor_search_header.view.dart';
import 'package:fuodz/pages/service/service_details.page.dart';
import 'package:fuodz/pages/vendor_details/vendor_details.page.dart';
import 'package:fuodz/providers/search_providers.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class ServiceSearchPage extends ConsumerStatefulWidget {
  const ServiceSearchPage({
    super.key,
    this.category,
    this.vendorType,
    this.showCancel = true,
    this.showVendors = true,
    this.showServices = true,
    this.byLocation = true,
  });

  final bool showCancel;
  final bool showVendors;
  final bool showServices;
  final bool byLocation;
  final Category? category;
  final VendorType? vendorType;

  @override
  ConsumerState<ServiceSearchPage> createState() =>
      _ServiceSearchPageState();
}

class _ServiceSearchPageState extends ConsumerState<ServiceSearchPage> {
  final TextEditingController _searchTEC = TextEditingController();
  final RefreshController _refreshController = RefreshController();
  late final Search _initialSearch;

  @override
  void initState() {
    super.initState();
    _initialSearch = Search(
      category: widget.category,
      vendorType: widget.vendorType ?? widget.category?.vendorType,
      byLocation: widget.byLocation,
    );
    final initialTag = widget.showServices ? 3 : (widget.showVendors ? 1 : 2);
    _initialSearch.genApiType(initialTag);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier =
          ref.read(serviceSearchControllerProvider(_initialSearch).notifier);
      notifier.setSelectedTag(initialTag);
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
    final asyncState =
        ref.watch(serviceSearchControllerProvider(_initialSearch));
    final notifier =
        ref.read(serviceSearchControllerProvider(_initialSearch).notifier);
    final state = asyncState.valueOrNull;
    final results = state?.results ?? const [];
    final selectTagId = state?.selectedTagId ?? 3;
    final isLoading = asyncState.isLoading;

    asyncState.whenData((_) {
      if (_refreshController.isRefresh) _refreshController.refreshCompleted();
      if (_refreshController.isLoading) _refreshController.loadComplete();
    });

    return BasePage(
      backgroundColor: Colors.white,
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
                search: state?.search ?? _initialSearch,
                onSubmitted: notifier.updateSearch,
              ),
            ),
          ),
          Visibility(
            visible: (widget.byLocation ||
                    (state?.search?.byLocation ?? false)) &&
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Visibility(
              visible: widget.showServices && widget.showVendors,
              child: VendorSearchHeaderview(
                selectedTagId: selectTagId,
                onSelectTag: notifier.setSelectedTag,
                showServices: widget.showServices,
                showProviders: widget.showVendors,
                padding: 0,
                defaultIndex: 3,
              ),
            ),
          ),
          CustomVisibilty(
            visible: widget.showVendors && selectTagId == 1,
            child: CustomListView(
              refreshController: _refreshController,
              canRefresh: true,
              canPullUp: true,
              onRefresh: notifier.startSearch,
              onLoading: () =>
                  notifier.startSearch(initialLoading: false),
              isLoading: isLoading,
              dataSet: results,
              itemBuilder: (context, index) {
                final r = results[index];
                if (r is Service) {
                  return GridViewServiceListItem(
                    service: r,
                    onPressed: (s) => context.pushWidget(ServiceDetailsPage(s)),
                  );
                }
                return CardVendor(
                  vendor: r as Vendor,
                  onPressed: (v) => context.pushWidget(VendorDetailsPage(vendor: v)),
                );
              },
              separatorBuilder: (context, index) =>
                  UiSpacer.verticalSpace(space: 10),
              emptyWidget: EmptyServiceSearch(),
            ).expand(),
          ),
          CustomVisibilty(
            visible: widget.showServices && selectTagId != 1,
            child: VStack([
              CustomMasonryGridView(
                refreshController: _refreshController,
                canRefresh: true,
                canPullUp: true,
                onRefresh: notifier.startSearch,
                onLoading: () =>
                    notifier.startSearch(initialLoading: false),
                isLoading: isLoading,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                items: results.map((r) {
                  if (r is Service) {
                    void open(s) => context.pushWidget(ServiceDetailsPage(s));
                    if (r.vendor_type_id == 13 ||
                        (r.vendor_type_id == null &&
                            r.vendor.vendorTypeId == 13)) {
                      return HomeServicesListItemTatto(
                        height: 360,
                        width: double.infinity,
                        service: r,
                        onPressed: open,
                      );
                    }
                    return HomeServicesListItem(
                      height: 290,
                      width: double.infinity,
                      service: r,
                      onPressed: open,
                    );
                  }
                  return VendorListItem(
                    vendor: r as Vendor,
                    onPressed: (v) => context.pushWidget(VendorDetailsPage(vendor: v)),
                  );
                }).toList(),
                emptyWidget: EmptyServiceSearch(),
              ).expand(),
            ]).expand(),
          ),
        ]).pSymmetric(h: 12),
      ),
    );
  }
}
