import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/view_models/main_search.vm.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/states/loading_indicator.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';

import 'widget/product_search_result.view.dart';
import 'widget/search.header.dart';
import 'widget/service_search_result.view.dart';
import 'widget/vendor_search_result.view.dart';

class MainSearchPage extends StatelessWidget {
  const MainSearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MainSearchViewModel>.reactive(
      viewModelBuilder: () => MainSearchViewModel(context),
      onViewModelReady: (vm) => vm.initialise(),
      disposeViewModel: false,
      builder: (context, vm, child) {
        return BasePage(
          body: VStack([
            //header
            UiSpacer.verticalSpace(),
            SearchHeader(vm, showCancel: false),
            //if by location is enabled and results are empty, show a disclaimer
            Visibility(
              visible:
                  (vm.search?.byLocation ?? true) &&
                  vm.searchResults.isEmpty &&
                  !vm.isBusy,
              child:
                  "Results are currently based on your location. You can disable this in the filter section."
                      .tr()
                      .text
                      .center
                      .gray500
                      .makeCentered()
                      .py(10),
            ),
            //tab-
            LoadingIndicator(
              loading: vm.isBusy,
              child: Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    tabBarTheme: const TabBarThemeData(
                      dividerColor: Colors.transparent,
                    ),
                  ),
                  child: DefaultTabController(
                    length:
                        [
                          if (vm.showVendors) 1,
                          if (vm.showProducts) 1,
                          if (vm.showServices) 1,
                        ].length,

                    child: Column(
                      children: [
                        // TAB
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
                              if (vm.showVendors)  Tab(text: "Vendors".tr()),

                              if (vm.showProducts)  Tab(text: "Products".tr()),

                              if (vm.showServices)  Tab(text: "Services".tr()),
                            ],
                          ),
                        ),

                        // CONTENT
                        Expanded(
                          child: TabBarView(
                            children: [
                              if (vm.showVendors) VendorSearchResultView(vm),

                              if (vm.showProducts) ProductSearchResultView(vm),

                              if (vm.showServices) ServiceSearchResultView(vm),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ContainedTabBarView(
              //   callOnChangeWhileIndexIsChanging: true,
              //   tabBarProperties: TabBarProperties(
              //     alignment: TabBarAlignment.start,
              //     isScrollable: true,
              //     labelPadding: EdgeInsets.symmetric(
              //       horizontal: 10,
              //       vertical: 0,
              //     ),

              //     //
              //     // padding: EdgeInsets.all(0),
              //     labelColor: AppColor.primaryColor,
              //     unselectedLabelColor: Utils.textColorByTheme(true),
              //     labelStyle: context.textTheme.bodyLarge!.copyWith(
              //       fontWeight: FontWeight.bold,
              //     ),
              //     // unselectedLabelStyle:
              //     //     context.textTheme.bodyLarge!.copyWith(),
              //     indicatorWeight: 4,
              //     indicator: BoxDecoration(
              //       // color: Colors.red,
              //       border: Border(
              //         bottom: BorderSide(
              //           color: context.theme.primaryColor,
              //           width: 3,
              //         ),
              //       ),
              //     ),
              //   ),
              //   tabs: [
              //     //
              //     if (vm.showVendors) Tab(child: "Vendors".tr().text.make()),
              //     //
              //     if (vm.showProducts)
              //       Tab(child: "Products".tr().text.make()),
              //     //
              //     if (vm.showServices)
              //       Tab(child: "Services".tr().text.make()),
              //   ],
              //   views: [
              //     if (vm.showVendors) VendorSearchResultView(vm),
              //     //
              //     if (vm.showProducts) ProductSearchResultView(vm),
              //     //
              //     if (vm.showServices) ServiceSearchResultView(vm),
              //   ],
              //   // onChange: vm.onTabChange,
              // ).expand(),
            ),
          ]).px(16),
        );
      },
    );
  }
}
