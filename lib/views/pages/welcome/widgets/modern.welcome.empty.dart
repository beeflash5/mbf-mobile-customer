import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fuodz/constants/app_images.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/constants/home_screen.config.dart';
import 'package:fuodz/enums/product_fetch_data_type.enum.dart';
import 'package:fuodz/extensions/string.dart';
import 'package:fuodz/models/search.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/services/navigation.service.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/welcome.vm.dart';
import 'package:fuodz/views/pages/vendor/widgets/banners.view.dart';
import 'package:fuodz/views/pages/vendor/widgets/banners_top.view.dart';
import 'package:fuodz/views/pages/vendor/widgets/featured_vendors.view.dart';
import 'package:fuodz/views/pages/vendor/widgets/section_products.view.dart';
import 'package:fuodz/views/pages/vendor/widgets/section_vendors.view.dart';
import 'package:fuodz/views/pages/vendor/widgets/section_vendors.view.main.dart';
import 'package:fuodz/views/pages/welcome/widgets/all_vendor.dart';
import 'package:fuodz/views/pages/welcome/widgets/welcome_header.section.dart';
import 'package:fuodz/widgets/cards/custom.visibility.dart';
import 'package:fuodz/widgets/finance/wallet_management.view.dart';
import 'package:fuodz/widgets/list_items/modern_vendor_type.vertical_list_item.dart';
import 'package:fuodz/widgets/list_items/vendor_type_home_list_item.dart';
import 'package:fuodz/widgets/list_items/vendor_type_home_more.dart';
import 'package:fuodz/widgets/states/loading.shimmer.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:masonry_grid/masonry_grid.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:velocity_x/velocity_x.dart';

class ModernEmptyWelcome extends StatelessWidget {
  const ModernEmptyWelcome({required this.vm, Key? key}) : super(key: key);

  final WelcomeViewModel vm;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(
          vm.opacity,
        ), // context.primaryColor.withOpacity(vm.opacity),
        elevation: vm.opacity > 0.3 ? 2 : 0,
        // backgroundColor: Colors.transparent,
        // elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24), // 👈 hanya rounded bawah
          ),
        ),
        title: GestureDetector(
          onTap: () {
            AppService().changeHomePageIndex(index: 2);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  // margin: EdgeInsets.only(top: 20, left: 10, right: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  padding: EdgeInsets.only(left: 20, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.search, color: Color(0xffbfbfbf)),
                      SizedBox(width: 16),
                      Text(
                        'Find'.tr(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xffbfbfbf),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            child: MaterialButton(
              minWidth: 0,
              height: 0,
              padding: EdgeInsets.all(8),
              elevation: 0,
              onPressed: () {
                AppService().changeHomePageIndex(index: 3);
              },
              color: Colors.white,
              textColor: Colors.white,
              child: Image.asset(
                AppImages.icon_user,
                width: 20,
                color: context.primaryColor,
              ),

              // Icon(Icons.manage_accounts_rounded,
              //     size: 24, color: Theme.of(context).primaryColor),
              shape: CircleBorder(),
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        controller: vm.refreshController,
        onRefresh: vm.reloadPage,
        scrollController: vm.scrollController,
        child:
            VStack([
              BannerTops(
                null,
                padding: 0,
                viewportFraction: 1.1,
                featured: true,
              ),

              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                height: 60,
                width: MediaQuery.of(context).size.width - 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  color:
                      context.backgroundColor, //Theme.of(context).primaryColor,
                  border: Border.all(color: Colors.white),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(1, 1),
                      blurRadius: 2,
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset(AppImages.icon_wallet, width: 40),
                          SizedBox(width: 10),
                          "${AppStrings.currencySymbol} ${vm.wallet != null ? vm.wallet?.balance : 0.00}"
                              .currencyFormat()
                              .text
                              // .color(Colors.white)
                              .sm
                              .semiBold
                              .makeCentered(),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap:
                          !vm.isAuthenticated()
                              ? vm.openLogin
                              : vm.showAmountEntry,
                      child: Container(
                        margin: EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              AppImages.icon_topup,
                              width: 20,
                              height: 20,
                            ),
                            SizedBox(height: 2),
                            "Top up".text
                                .color(Color(0xffA8A8A8))
                                .sm
                                .semiBold
                                .makeCentered(),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        AppService().changeHomePageIndex(index: 1);
                        //pop until home page
                        if (context != null) {
                          // context.navigator.popUntil(
                          //   (route) {
                          //     return route == AppRoutes.homeRoute ||
                          //         route.isFirst;
                          //   },
                          // );
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              AppImages.icon_order,
                              width: 20,
                              height: 20,
                            ),
                            SizedBox(height: 2),
                            "Order".text
                                .color(Color(0xffA8A8A8))
                                .sm
                                .semiBold
                                .makeCentered(),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        AppService().changeHomePageIndex(index: 3);
                      },
                      child: Container(
                        margin: EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              AppImages.icon_more,
                              width: 20,
                              height: 20,
                            ),
                            SizedBox(height: 2),
                            "Lainnya".text
                                .color(Color(0xffA8A8A8))
                                .sm
                                .semiBold
                                .makeCentered(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: DynamicHeightGridView(
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    crossAxisCount: 4,
                    itemCount:
                        vm.vendorTypes.length < 8 ? vm.vendorTypes.length : 8,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    builder: (context, index) {
                      final vendorType = vm.vendorTypes[index];
                      if (index == 7) {
                        return VendorMore(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AllVendor(vm: vm),
                              ),
                            );
                          },
                        );
                      } else {
                        return VendorTypeHomeListItem(
                          vendorType,
                          onPressed: () {
                            if (!vm.isAuthenticated() &&
                                (vendorType.slug == 'taxi' ||
                                    vendorType.slug == 'bike')) {
                              vm.openLogin();
                            } else {
                              NavigationService.pageSelected(
                                vendorType,
                                context: context,
                              );
                            }
                          },
                        );
                      }
                    },
                  ),
                ),
              ),

              SizedBox(height: 10),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.primaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    "Diskon s.d.10rb/transaksi. Yuk, langga...".text
                        .color(Colors.white)
                        .make(),
                    Icon(Icons.arrow_circle_right, color: Colors.white),
                  ],
                ),
              ).onTap(() {
                final vendor = vm.vendorTypes.firstWhere(
                  (element) => element.slug == 'food',
                );
                if (vendor != null)
                  NavigationService.pageSelected(vendor, context: context);
              }),
              SizedBox(height: 20),
              Container(height: 10, color: Color(0xffF1F2F4)),

              Banners(null, featured: true).py12(),

              SectionVendorsView(
                null,
                title: "Featured Vendors".tr(),
                scrollDirection: Axis.horizontal,
                type: SearchFilterType.featured,
                itemWidth: context.percentWidth * 48,
                byLocation: AppStrings.enableFatchByLocation,
                hideEmpty: true,
                titlePadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                itemsPadding: EdgeInsets.symmetric(horizontal: 20),
              ),
              //featured products
              SectionProductsView(
                null,
                title: "Featured Products".tr(),
                scrollDirection: Axis.horizontal,
                type: ProductFetchDataType.featured,
                itemWidth: context.percentWidth * 42,
                byLocation: AppStrings.enableFatchByLocation,
                hideEmpty: true,
                itemsPadding: EdgeInsets.fromLTRB(20, 0, 20, 5),
                titlePadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                listHeight: context.percentHeight * 20,
              ),

              //spacing
            ]).box.color(context.backgroundColor).topRounded(value: 30).make(),
      ),
    );
  }

  // Widget build(BuildContext context) {
  //   return VStack([
  //     //
  //     WelcomeHeaderSection(vm),
  //     VStack([
  //           //finance section
  //           if (HomeScreenConfig.showWalletOnHomeScreen && vm.isAuthenticated())
  //             WalletManagementView(),

  //           //top banner
  //           if ((HomeScreenConfig.showBannerOnHomeScreen &&
  //               HomeScreenConfig.isBannerPositionTop))
  //             Banners(null, featured: true, padding: 0),
  //           //
  //           VStack([
  //             //gridview
  //             if (HomeScreenConfig.isVendorTypeListingGridView &&
  //                 vm.showGrid &&
  //                 vm.isBusy)
  //               LoadingShimmer().px20().centered(),

  //             CustomVisibilty(
  //               visible:
  //                   HomeScreenConfig.isVendorTypeListingGridView &&
  //                   vm.showGrid &&
  //                   !vm.isBusy,
  //               child: AnimationLimiter(
  //                 child: MasonryGrid(
  //                   column: HomeScreenConfig.vendorTypePerRow,
  //                   crossAxisSpacing: 15,
  //                   mainAxisSpacing: 15,
  //                   children: List.generate(vm.vendorTypes.length, (index) {
  //                     final vendorType = vm.vendorTypes[index];
  //                     return ModernVendorTypeVerticalListItem(
  //                       vendorType,
  //                       onPressed: () {
  //                         NavigationService.pageSelected(
  //                           vendorType,
  //                           context: context,
  //                         );
  //                       },
  //                     );
  //                   }),
  //                 ),
  //               ),
  //             ),
  //           ]).px20(),

  //           //botton banner
  //           if (HomeScreenConfig.showBannerOnHomeScreen &&
  //               !HomeScreenConfig.isBannerPositionTop)
  //             Banners(null, featured: true),

  //           //featured vendors
  //           // FeaturedVendorsView(
  //           //   title: "Featured Vendors".tr(),
  //           //   scrollDirection: Axis.horizontal,
  //           //   itemWidth: context.percentWidth * 48,
  //           //   listViewPadding: Vx.mSymmetric(h: 20),
  //           //   titlePadding: Vx.(h: 20, v: 6),
  //           //   onSeeAllPressed: () {
  //           //     vm.openFeaturedVendors();
  //           //   },
  //           //   onVendorSelected: (vendor) {
  //           //     NavigationService.openVendorDetailsPage(
  //           //       vendor,
  //           //       context: context,
  //           //     );
  //           //   },
  //           // ),
  //           SectionVendorsView(
  //             null,
  //             title: "Featured Vendors".tr(),
  //             scrollDirection: Axis.horizontal,
  //             type: SearchFilterType.featured,
  //             itemWidth: context.percentWidth * 48,
  //             byLocation: AppStrings.enableFatchByLocation,
  //             hideEmpty: true,
  //             titlePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  //             itemsPadding: EdgeInsets.symmetric(horizontal: 20),
  //           ),
  //           //featured products
  //           SectionProductsView(
  //             null,
  //             title: "Featured Products".tr(),
  //             scrollDirection: Axis.horizontal,
  //             type: ProductFetchDataType.featured,
  //             itemWidth: context.percentWidth * 42,
  //             byLocation: AppStrings.enableFatchByLocation,
  //             hideEmpty: true,
  //             itemsPadding: EdgeInsets.fromLTRB(20, 0, 20, 5),
  //             titlePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  //             listHeight: context.percentHeight * 20,
  //           ),
  //           //spacing
  //           100.heightBox,
  //         ], spacing: 16)
  //         .scrollVertical()
  //         .box
  //         .color(context.theme.colorScheme.surface)
  //         .make()
  //         .expand(),
  //   ]);
  // }
}
