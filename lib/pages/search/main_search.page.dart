import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/bottom_sheet/search_filter.bottomsheet.dart';
import 'package:fuodz/models/search.dart';
import 'package:fuodz/providers/main_search_providers.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';

import 'widget/product_search_result.view.dart';
import 'widget/search.header.dart';
import 'widget/service_search_result.view.dart';
import 'widget/vendor_search_result.view.dart';

class MainSearchPage extends ConsumerStatefulWidget {
  const MainSearchPage({super.key});

  @override
  ConsumerState<MainSearchPage> createState() => _MainSearchPageState();
}

class _MainSearchPageState extends ConsumerState<MainSearchPage> {
  final TextEditingController _searchTEC = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mainSearchControllerProvider.notifier).startSearch();
    });
  }

  @override
  void dispose() {
    _searchTEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(mainSearchControllerProvider);
    final notifier = ref.read(mainSearchControllerProvider.notifier);
    // Preserve previous state values during loading so tabs don't disappear
    final state = asyncState.valueOrNull;
    final isLoading = asyncState.isLoading || asyncState.isRefreshing;
    final showVendors = state?.showVendors ?? false;
    final showProducts = state?.showProducts ?? false;
    final showServices = state?.showServices ?? false;

    final tabCount = [
      if (showVendors) 1,
      if (showProducts) 1,
      if (showServices) 1,
    ].length;

    return BasePage(
      body: VStack([
        UiSpacer.verticalSpace(),
        SearchHeader(
          searchTEC: _searchTEC,
          showCancel: false,
          onSubmitted: (keyword) {
            notifier.setKeyword(keyword);
            notifier.startSearch();
          },
          onFilterPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => SearchFilterBottomSheet(
              search: state?.search ?? Search(),
              onSubmitted: notifier.updateSearch,
            ),
          ),
        ),
        if (isLoading) const LinearProgressIndicator(minHeight: 3),
        Expanded(
          child: tabCount == 0
              ? const Center(child: CircularProgressIndicator())
              : Theme(
                  data: Theme.of(context).copyWith(
                    tabBarTheme: const TabBarThemeData(
                      dividerColor: Colors.transparent,
                    ),
                  ),
                  child: DefaultTabController(
                    length: tabCount,
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                          ),
                          child: TabBar(
                            isScrollable: false,
                            tabAlignment: TabAlignment.fill,
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicator: UnderlineTabIndicator(
                              borderSide: BorderSide(
                                color: context.theme.primaryColor,
                                width: 3,
                              ),
                            ),
                            labelColor: AppColor.primaryColor,
                            unselectedLabelColor: Utils.textColorByTheme(true),
                            labelStyle: context.textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            tabs: [
                              if (showVendors) Tab(text: "Vendors".tr()),
                              if (showProducts) Tab(text: "Products".tr()),
                              if (showServices) Tab(text: "Services".tr()),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              if (showVendors) const VendorSearchResultView(),
                              if (showProducts) const ProductSearchResultView(),
                              if (showServices) const ServiceSearchResultView(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ]).px(16),
    );
  }
}
