import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/app_images.dart';
import 'package:fuodz/constants/app_routes.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/constants/home_screen.config.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/enums/product_fetch_data_type.enum.dart';
import 'package:fuodz/extensions/string.dart';
import 'package:fuodz/models/search.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/services/navigation.service.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/welcome.vm.dart';
import 'package:fuodz/views/pages/grocery/widgets/grocery_picks.view.dart';
import 'package:fuodz/views/pages/search/main_search_home.page.dart';
import 'package:fuodz/views/pages/search/service_search.page.dart';
import 'package:fuodz/views/pages/service/widgets/modern_category_gridview.list_item.dart';
import 'package:fuodz/views/pages/vendor/widgets/banners.view.dart';
import 'package:fuodz/views/pages/vendor/widgets/banners_botom.view.dart';
import 'package:fuodz/views/pages/vendor/widgets/banners_top.view.dart';
import 'package:fuodz/views/pages/vendor/widgets/section_products.view.dart';
import 'package:fuodz/views/pages/vendor/widgets/section_vendors.view.dart';
import 'package:fuodz/views/pages/vendor/widgets/section_vendors_home.view.dart';
import 'package:fuodz/views/pages/welcome/widgets/all_vendor.dart';
import 'package:fuodz/widgets/cards/custom.visibility.dart';
import 'package:fuodz/widgets/cards/welcome_intro.view.dart';
import 'package:fuodz/widgets/category_section.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:fuodz/widgets/custom_list_view.dart';
import 'package:fuodz/widgets/finance/wallet_management.view.dart';
import 'package:fuodz/widgets/home_product.view.dart';
import 'package:fuodz/widgets/home_services.view.dart';
import 'package:fuodz/widgets/list_items/vendor_type.list_item.dart';
import 'package:fuodz/widgets/list_items/vendor_type.vertical_list_item.dart';
import 'package:fuodz/widgets/list_items/vendor_type_home_list_item.dart';
import 'package:fuodz/widgets/list_items/vendor_type_home_list_vertical_item.dart';
import 'package:fuodz/widgets/list_items/vendor_type_home_more.dart';
import 'package:fuodz/widgets/states/loading.shimmer.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:masonry_grid/masonry_grid.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:velocity_x/velocity_x.dart';

class EmptyWelcome extends StatelessWidget {
  const EmptyWelcome({required this.vm, Key? key}) : super(key: key);

  final WelcomeViewModel vm;
  @override
  Widget build(BuildContext context) {
    Widget _buildActionButton({
      required IconData icon,
      required String label,
      required VoidCallback onTap,
    }) {
      return Padding(
        padding: const EdgeInsets.only(left: 0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      // backgroundColor: context.backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: context.primaryColor,
        // backgroundColor: Colors.white.withOpacity(
        //   vm.opacity,
        // ), // context.primaryColor.withOpacity(vm.opacity),
        // elevation: vm.opacity > 0.3 ? 2 : 0,
        // backgroundColor: Colors.transparent,
        // elevation: 0,
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.vertical(
        //     bottom: Radius.circular(24), // 👈 hanya rounded bawah
        //   ),
        // ),
        // title: GestureDetector(
        //   onTap: () {
        //     // AppService().changeHomePageIndex(index: 2);
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (context) => MainSearchHomePage()),
        //     );
        //   },
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Image.asset(AppImages.appLogo)
        //           .wh(60, 60)
        //           .box
        //           .clip(Clip.antiAlias)
        //           .roundedSM
        //           .makeCentered()
        //           .py12(),
        //       Expanded(
        //         child: Container(
        //           height: 40,
        //           // margin: EdgeInsets.only(top: 20, left: 10, right: 10),
        //           decoration: BoxDecoration(
        //             color: Colors.white,
        //             borderRadius: BorderRadius.all(Radius.circular(20)),
        //           ),
        //           padding: EdgeInsets.only(left: 20, right: 10),
        //           child: Row(
        //             mainAxisAlignment: MainAxisAlignment.start,
        //             children: [
        //               Icon(Icons.search, color: Color(0xffbfbfbf)),
        //               SizedBox(width: 16),
        //               Text(
        //                 'Find'.tr(),
        //                 style: TextStyle(
        //                   fontSize: 14,
        //                   color: Color(0xffbfbfbf),
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        actions: [
          Image.asset(
            AppImages.appLogo,
          ).wh(60, 60).box.clip(Clip.antiAlias).roundedSM.makeCentered(),
          SizedBox(width: 6),
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainSearchHomePage()),
                );
              },
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
                      style: TextStyle(fontSize: 14, color: Color(0xffbfbfbf)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.notificationsRoute);
            },
            child: Icon(
              HugeIcons.strokeRoundedNotification01,
              color: Colors.white,
              size: 28,
            ),
          ),
          // Container(
          //   margin: EdgeInsets.symmetric(vertical: 8),
          //   child: MaterialButton(
          //     minWidth: 0,
          //     height: 0,
          //     padding: EdgeInsets.all(8),
          //     elevation: 0,
          //     onPressed: () {
          //       // AppService().changeHomePageIndex(index: 3);
          //     },
          //     color: Colors.white,
          //     textColor: Colors.white,
          //     child: Image.asset(
          //       AppImages.icon_user,
          //       width: 20,
          //       color: context.primaryColor,
          //     ),

          //     // Icon(Icons.manage_accounts_rounded,
          //     //     size: 24, color: Theme.of(context).primaryColor),
          //     shape: CircleBorder(),
          //   ),
          // ),
          SizedBox(width: 20),
        ],
      ),
      body: SingleChildScrollView(
        controller: vm.scrollController,
        child:
            VStack([
              SizedBox(height: 56),
              // BannerTops(
              //   null,
              //   padding: 0,
              //   viewportFraction: 1.1,
              //   featured: true,
              // ),
              Container(
                // margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 75,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.primaryColor,
                  // borderRadius: BorderRadius.circular(16),
                  // gradient: LinearGradient(
                  //   colors: [
                  //     Theme.of(context).primaryColor,
                  //     Theme.of(context).primaryColor.withOpacity(0.85),
                  //   ],
                  //   begin: Alignment.topLeft,
                  //   end: Alignment.bottomRight,
                  // ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // SizedBox(width: 8),

                    /// WALLET SECTION
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Wallet Balance".tr(),
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${AppStrings.currencySymbol} ${vm.wallet?.balance ?? 0.00}"
                                    .currencyFormat(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    /// ACTION BUTTONS
                    _buildActionButton(
                      icon: Icons.add_circle_rounded,
                      label: "Topup".tr(),
                      onTap:
                          !vm.isAuthenticated()
                              ? vm.openLogin
                              : vm.showAmountEntry,
                    ),

                    _buildActionButton(
                      icon: Icons.receipt_long_rounded,
                      label: "Orders".tr(),
                      onTap: () {
                        AppService().changeHomePageIndex(index: 1);
                      },
                    ),

                    _buildActionButton(
                      icon: Icons.grid_view_rounded,
                      label: "other".tr(),
                      onTap: () {
                        AppService().changeHomePageIndex(index: 3);
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(10),
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: vm.vendorTypes.length,
                  itemBuilder: (context, index) {
                    final vendorType = vm.vendorTypes[index];
                    return VendorTypeHomeListItemVertical(
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
                  },
                ),
              ),
              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 20),
              //   child: MediaQuery.removePadding(
              //     context: context,
              //     removeTop: true,
              //     child: DynamicHeightGridView(
              //       crossAxisSpacing: 10,
              //       mainAxisSpacing: 10,
              //       crossAxisCount: 5,
              //       itemCount:
              //           vm.vendorTypes.length < 8 ? vm.vendorTypes.length : 8,
              //       physics: NeverScrollableScrollPhysics(),
              //       shrinkWrap: true,
              //       builder: (context, index) {
              //         final vendorType = vm.vendorTypes[index];
              //         if (index == 7) {
              //           return VendorMore(
              //             onPressed: () {
              //               Navigator.push(
              //                 context,
              //                 MaterialPageRoute(
              //                   builder: (context) => AllVendor(vm: vm),
              //                 ),
              //               );
              //             },
              //           );
              //         } else {
              //           return VendorTypeHomeListItem(
              //             vendorType,
              //             onPressed: () {
              //               if (!vm.isAuthenticated() &&
              //                   (vendorType.slug == 'taxi' ||
              //                       vendorType.slug == 'bike')) {
              //                 vm.openLogin();
              //               } else {
              //                 NavigationService.pageSelected(
              //                   vendorType,
              //                   context: context,
              //                 );
              //               }
              //             },
              //           );
              //         }
              //       },
              //     ),
              //   ),
              // ),
              // SizedBox(height: 6),
              // Container(height: 4, color: Colors.grey.shade100),

              // "Category".tr().text.bold.make().pOnly(
              //   left: 20,
              //   right: 20,
              //   top: 10,
              // ),
              // // SizedBox(height: 10),
              // vm.vendorTypes.length == 0
              //     ? SizedBox()
              //     : Container(
              //       padding: EdgeInsets.all(10),
              //       height: 120,
              //       child: ListView.builder(
              //         scrollDirection: Axis.horizontal,
              //         itemCount: vm.categories.length,
              //         itemBuilder: (context, index) {
              //           final category = vm.categories[index];
              //           return InkWell(
              //             onTap: () {
              //               NavigationService.categorySelected(category);
              //             },
              //             child: Container(
              //               margin: EdgeInsets.all(6),
              //               padding: EdgeInsets.all(10),
              //               width: 90,
              //               decoration: BoxDecoration(
              //                 color: Colors.white,
              //                 borderRadius: BorderRadius.circular(12),
              //                 boxShadow: [
              //                   BoxShadow(
              //                     color: Colors.black.withOpacity(0.1),
              //                     blurRadius: 8,
              //                     offset: Offset(0, 1),
              //                   ),
              //                 ],
              //               ),
              //               child: Column(
              //                 children: [
              //                   CustomImage(imageUrl: category.imageUrl),
              //                   const SizedBox(height: 6),
              //                   Text(
              //                     category.name,
              //                     textAlign: TextAlign.center,
              //                     style: const TextStyle(fontSize: 11),
              //                   ),
              //                 ],
              //               ),
              //             ),
              //           );
              //         },
              //       ),
              //     ),
              // CategorySection(categories: vm.categories).px(0),
              // SizedBox(height: 10),
              BannerTops(
                null,
                padding: 10,
                viewportFraction: 1,
                featured: false,
              ),

              Container(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : Colors.grey.shade100,
                // color: Colors.grey.shade100,
                padding: EdgeInsets.only(bottom: 12),
                child: SectionVendorsHomeView(
                  null,
                  title: "Featured Vendors".tr(),
                  scrollDirection: Axis.horizontal,
                  type: SearchFilterType.featured,
                  itemWidth: context.percentWidth * 58,
                  // byLocation: AppStrings.enableFatchByLocation,
                  hideEmpty: true,
                  titlePadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  itemsPadding: EdgeInsets.symmetric(horizontal: 20),
                ),
              ),

              // Banners(null, featured: true).py12(),
              //featured products
              vm.vendorTypes.length == 0 &&
                      vm.vendorTypes.where((e) => e.id == 7).isEmpty
                  ? SizedBox()
                  : HomeService(
                    crossAxisCount: 1,
                    "New ${vm.vendorTypes.where((e) => e.id == 7).first.name}"
                            .tr() +
                        " 🔥",
                    vm.vendorTypes.where((e) => e.id == 7).first,
                    showGrid: true,
                    type: ProductFetchDataType.NEW,
                    onSeeAllPressed: () {
                      vm.openServicesSeeAllPage(
                        title: "Today Picks".tr() + " 🔥",
                        vendorType:
                            vm.vendorTypes.where((e) => e.id == 7).first,
                        type: ProductFetchDataType.NEW,
                      );
                    },
                  ).px(10),

              vm.vendorTypes.length == 0 &&
                      vm.vendorTypes.where((e) => e.id == 5).isEmpty
                  ? SizedBox()
                  : HomeService(
                    crossAxisCount: 1,
                    "New ${vm.vendorTypes.where((e) => e.id == 5).last.name}"
                            .tr() +
                        " 🔥",
                    vm.vendorTypes.where((e) => e.id == 5).last,
                    showGrid: true,
                    type: ProductFetchDataType.NEW,
                    onSeeAllPressed: () {
                      vm.openServicesSeeAllPage(
                        title: "Today Picks".tr() + " 🔥",
                        vendorType: vm.vendorTypes.where((e) => e.id == 5).last,
                        type: ProductFetchDataType.NEW,
                      );
                    },
                  ).px(10),

              //botton banner
              CustomVisibilty(
                child: BannerBottom(
                  disableCenter: false,
                  showIndicators: false,
                  viewportFraction: 1,

                  null,
                  featured: true,
                  // ).py(),
                ).py(0),
              ).px(10),

              vm.vendorTypes.length == 0 &&
                      vm.vendorTypes.where((e) => e.slug == "commerce").isEmpty
                  ? SizedBox()
                  : HomeProduct(
                    // crossAxisCount: 1,
                    "New ${vm.vendorTypes.where((e) => e.slug == "commerce").first.name}"
                            .tr() +
                        " 🔥",
                    vm.vendorTypes.where((e) => e.slug == "commerce").first,
                    showGrid: true,
                    type: ProductFetchDataType.NEW,
                    onSeeAllPressed: () {
                      vm.openProductsSeeAllPage(
                        title:
                            "New ${vm.vendorTypes.where((e) => e.slug == "commerce").first.name}"
                                .tr() +
                            " 🔥",
                        vendorType:
                            vm.vendorTypes
                                .where((e) => e.slug == "commerce")
                                .first,
                        type: ProductFetchDataType.NEW,
                      );
                    },
                  ).px(10),

              //spacing
            ]).box.color(context.backgroundColor).topRounded(value: 30).make(),
      ),
    );

    // return VStack([
    //   //
    //   SafeArea(child: WelcomeIntroView(vm)),

    //   //
    //   VStack([
    //         //finance section
    //         CustomVisibilty(
    //           visible: HomeScreenConfig.showWalletOnHomeScreen,
    //           child: WalletManagementView(),
    //         ),
    //         //
    //         //top banner
    //         CustomVisibilty(
    //           visible:
    //               HomeScreenConfig.showBannerOnHomeScreen &&
    //               HomeScreenConfig.isBannerPositionTop,
    //           child: VStack([
    //             Banners(
    //               null,
    //               featured: true,
    //               padding: 0,
    //               // ).py12(),
    //             ).py(0),
    //           ]),
    //         ),
    //         //
    //         VStack([
    //           HStack([
    //             "I want to:".tr().text.xl.medium.make().expand(),
    //             CustomVisibilty(
    //               visible: HomeScreenConfig.isVendorTypeListingBoth,
    //               child: Icon(
    //                 vm.showGrid ? FlutterIcons.grid_fea : FlutterIcons.list_fea,
    //               ).p2().onInkTap(() {
    //                 vm.showGrid = !vm.showGrid;
    //                 vm.notifyListeners();
    //               }),
    //             ),
    //           ], crossAlignment: CrossAxisAlignment.center),
    //           UiSpacer.vSpace(12),
    //           //list view
    //           CustomVisibilty(
    //             visible:
    //                 (HomeScreenConfig.isVendorTypeListingBoth &&
    //                     !vm.showGrid) ||
    //                 (!HomeScreenConfig.isVendorTypeListingBoth &&
    //                     HomeScreenConfig.isVendorTypeListingListView),
    //             child: CustomListView(
    //               noScrollPhysics: true,
    //               dataSet: vm.vendorTypes,
    //               isLoading: vm.isBusy,
    //               loadingWidget: LoadingShimmer().px20(),
    //               padding: EdgeInsets.zero,
    //               itemBuilder: (context, index) {
    //                 final vendorType = vm.vendorTypes[index];
    //                 return VendorTypeListItem(
    //                   vendorType,
    //                   onPressed: () {
    //                     NavigationService.pageSelected(
    //                       vendorType,
    //                       context: context,
    //                     );
    //                   },
    //                 );
    //               },
    //               separatorBuilder: (context, index) => UiSpacer.emptySpace(),
    //             ),
    //           ),
    //           //gridview
    //           CustomVisibilty(
    //             visible:
    //                 HomeScreenConfig.isVendorTypeListingGridView &&
    //                 vm.showGrid &&
    //                 vm.isBusy,
    //             child: LoadingShimmer().px20().centered(),
    //           ),
    //           CustomVisibilty(
    //             visible:
    //                 HomeScreenConfig.isVendorTypeListingGridView &&
    //                 vm.showGrid &&
    //                 !vm.isBusy,
    //             child: AnimationLimiter(
    //               child: MasonryGrid(
    //                 column: HomeScreenConfig.vendorTypePerRow,
    //                 crossAxisSpacing: 10,
    //                 mainAxisSpacing: 10,
    //                 children: List.generate(vm.vendorTypes.length, (index) {
    //                   final vendorType = vm.vendorTypes[index];
    //                   return VendorTypeVerticalListItem(
    //                     vendorType,
    //                     onPressed: () {
    //                       NavigationService.pageSelected(
    //                         vendorType,
    //                         context: context,
    //                       );
    //                     },
    //                   );
    //                 }),
    //               ),
    //             ),
    //           ),
    //         ]).px20(),

    //         //botton banner
    //         CustomVisibilty(
    //           visible:
    //               HomeScreenConfig.showBannerOnHomeScreen &&
    //               !HomeScreenConfig.isBannerPositionTop,
    //           child: Banners(
    //             null,
    //             featured: true,
    //             // ).py(),
    //           ).py(0),
    //         ),

    //         //featured vendors
    //         SectionVendorsView(
    //           null,
    //           title: "Featured Vendors".tr(),
    //           titlePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    //           itemsPadding: EdgeInsets.symmetric(horizontal: 20),
    //           scrollDirection: Axis.horizontal,
    //           type: SearchFilterType.featured,
    //           itemWidth: context.percentWidth * 48,
    //           byLocation: AppStrings.enableFatchByLocation,
    //           hideEmpty: true,
    //         ),
    //         //spacing
    //         40.heightBox,
    //       ], spacing: 6).box
    //       .color(context.theme.colorScheme.surface)
    //       .topRounded(value: Sizes.radiusDefault)
    //       .make(),
    // ], spacing: 15).box.color(AppColor.primaryColor).make().scrollVertical();
  }
}
