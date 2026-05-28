import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/navigation.service.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/welcome.vm.dart';
import 'package:fuodz/views/pages/grocery/widgets/grocery_picks.view.dart';
import 'package:fuodz/views/pages/search/main_search_home.page.dart';
import 'package:fuodz/views/pages/search/service_search.page.dart';
import 'package:fuodz/views/pages/service/widgets/modern_category_gridview.list_item.dart';
import 'package:fuodz/views/pages/vendor/widgets/ads_bottom.view.dart';
import 'package:fuodz/views/pages/vendor/widgets/ads_top.view.dart';
import 'package:fuodz/views/pages/vendor/widgets/banners.view.dart';
import 'package:fuodz/views/pages/vendor/widgets/banners_botom.view.dart';
import 'package:fuodz/views/pages/vendor/widgets/banners_top.view.dart';
import 'package:fuodz/views/pages/vendor/widgets/section_products.view.dart';
import 'package:fuodz/views/pages/vendor/widgets/section_vendors.view.dart';
import 'package:fuodz/views/pages/vendor/widgets/section_vendors_home.view.dart';
import 'package:fuodz/views/pages/welcome/widgets/all_vendor.dart';
import 'package:fuodz/views/pages/welcome/widgets/flash_sales.dart';
import 'package:fuodz/views/pages/welcome/widgets/recent_activity.dart';
import 'package:fuodz/views/pages/welcome/widgets/tranding_destination.dart';
import 'package:fuodz/views/pages/welcome/widgets/travel_new_page.dart';
import 'package:fuodz/widgets/busy_indicator.dart';
import 'package:fuodz/widgets/cards/custom.visibility.dart';
import 'package:fuodz/widgets/cards/welcome_intro.view.dart';
import 'package:fuodz/widgets/category_section.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:fuodz/widgets/custom_list_view.dart';
import 'package:fuodz/widgets/custom_masonry_grid_view.dart';
import 'package:fuodz/widgets/finance/wallet_management.view.dart';
import 'package:fuodz/widgets/home_product.view.dart';
import 'package:fuodz/widgets/home_services.view.dart';
import 'package:fuodz/widgets/list_items/home_services.list_item.dart';
import 'package:fuodz/widgets/list_items/vendor_type.list_item.dart';
import 'package:fuodz/widgets/list_items/vendor_type.vertical_list_item.dart';
import 'package:fuodz/widgets/list_items/vendor_type_home_list_item.dart';
import 'package:fuodz/widgets/list_items/vendor_type_home_list_vertical_item.dart';
import 'package:fuodz/widgets/list_items/vendor_type_home_list_vertical_item_home.dart';
import 'package:fuodz/widgets/list_items/vendor_type_home_more.dart';
import 'package:fuodz/widgets/states/loading.shimmer.dart';
import 'package:fuodz/widgets/wallet_balance_card.dart';
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
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0, // 🔥 ini penting
        surfaceTintColor: Colors.transparent,
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
          SizedBox(width: 10),
          AuthServices.authenticated()
              ? CachedNetworkImage(
                imageUrl: vm.currentUser?.photo ?? "",
                progressIndicatorBuilder: (context, imageUrl, progress) {
                  return BusyIndicator();
                },
                errorWidget: (context, imageUrl, progress) {
                  return Image.asset(AppImages.user);
                },
              ).wh(50, 50).box.roundedFull.clip(Clip.antiAlias).make()
              : Image.asset(
                AppImages.appLogo,
              ).wh(50, 50).box.clip(Clip.antiAlias).roundedSM.makeCentered(),
          SizedBox(width: 6),

          AuthServices.authenticated()
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  "Hi, ${vm.currentUser?.name ?? ""}!".text
                      .fontWeight(FontWeight.bold)
                      .color(Colors.black)
                      .make(),
                  "Explore the real Bali with locals".text
                      .color(context.primaryColor)
                      .make(),
                ],
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  "My Bali Friendz".text
                      .fontWeight(FontWeight.bold)
                      .color(Colors.black)
                      .make(),
                  "Explore the real Bali with locals".text
                      .color(context.primaryColor)
                      .make(),
                ],
              ),
          Spacer(),
          // Expanded(
          //   child: InkWell(
          //     onTap: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(builder: (context) => MainSearchHomePage()),
          //       );
          //     },
          //     child: Container(
          //       height: 40,
          //       // margin: EdgeInsets.only(top: 20, left: 10, right: 10),
          //       decoration: BoxDecoration(
          //         color: Colors.white,
          //         borderRadius: BorderRadius.all(Radius.circular(20)),
          //       ),
          //       padding: EdgeInsets.only(left: 20, right: 10),
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.start,
          //         children: [
          //           Icon(Icons.search, color: Color(0xffbfbfbf)),
          //           SizedBox(width: 16),
          //           Text(
          //             'Find'.tr(),
          //             style: TextStyle(fontSize: 14, color: Color(0xffbfbfbf)),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          // SizedBox(width: 10),
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.notificationsRoute);
            },
            child: Icon(
              Icons.notifications,
              color: context.primaryColor,
              size: 28,
            ),
          ),
          // SizedBox(width: 10),
          // InkWell(
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => MainSearchHomePage()),
          //     );
          //   },
          //   child: Image.asset(AppImages.search, width: 30, height: 30),
          // ),

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
              SizedBox(height: 70),

              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainSearchHomePage(),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Color(0xffF3F9FA),
                    border: Border.all(color: Color(0xffB3D8DE)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Color(0xff879092)),
                      SizedBox(width: 10),
                      "Search experiences, services, or places".text
                          .color(Color(0xff879092))
                          .make(),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              Stack(
                children: [
                  BannerTops(
                    null,
                    padding: 10,
                    viewportFraction: 1,
                    featured: false,
                  ),
                ],
              ),

              SizedBox(height: 16),

              "Category".text.lg.bold.make().px20(),

              SizedBox(
                height: 110,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = constraints.maxWidth;

                    const double horizontalPadding = 24.0;
                    const double visibleItems = 5.5;
                    const double baseSpacing = 4.0;

                    // 🔥 itemWidth TANPA spacing (biar ada sisa space)
                    final itemWidth =
                        (screenWidth - horizontalPadding) / visibleItems;

                    // 🔥 sekarang pasti ada sisa
                    final totalItemWidth = itemWidth * visibleItems;

                    final remainingSpace =
                        screenWidth - horizontalPadding - totalItemWidth;

                    // 🔥 spacing akan BENAR-BENAR nambah
                    final dynamicSpacing =
                        baseSpacing +
                        (remainingSpace > 0
                            ? remainingSpace / (visibleItems - 1)
                            : 0);

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: vm.vendorTypes.length,
                      itemBuilder: (context, index) {
                        final vendorType = vm.vendorTypes[index];

                        return Padding(
                          padding: EdgeInsets.only(
                            right:
                                index == vm.vendorTypes.length - 1
                                    ? 0
                                    : dynamicSpacing,
                          ),
                          child: SizedBox(
                            width: itemWidth,
                            child: VendorTypeHomeListItemVerticalHome(
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
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  "Trending Now".text.lg.semiBold.make(),
                  "See all".text.lg
                      .color(Color(0xFF1B8A9E))
                      .make()
                      .onTap(() => vm.openSearchPage(vm.viewContext, null)),
                ],
              ).px12(),

              SizedBox(height: 10),

              SizedBox(
                height: 300,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  itemCount: vm.topRated.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final product = vm.topRated[index];

                    return HomeServicesListItem(
                      height: 290,
                      width: 170,
                      service: product,
                      onPressed: vm.servicePressed,
                      title: "Top Pick",
                    );
                  },
                ),
              ),

              // SizedBox(height: 8),
              // AdsTop(null, padding: 10, viewportFraction: 1, featured: false),
              // SizedBox(height: 8),

              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     "Best Selling".text.lg.semiBold.make(),
              //     "See all".text.lg
              //         .color(Color(0xFF1B8A9E))
              //         .make()
              //         .onTap(() => vm.openSearchPage(vm.viewContext, null)),
              //   ],
              // ).px12(),

              // SizedBox(height: 10),

              // SizedBox(
              //   height: 280,
              //   child: ListView.separated(
              //     scrollDirection: Axis.horizontal,
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 12,
              //       vertical: 6,
              //     ),
              //     itemCount: vm.bestSelling.length,
              //     separatorBuilder: (_, __) => const SizedBox(width: 12),
              //     itemBuilder: (context, index) {
              //       final product = vm.bestSelling[index];

              //       return HomeServicesListItem(
              //         width: 170,
              //         service: product,
              //         onPressed: vm.servicePressed,
              //         title: "Best Selling",
              //       );
              //     },
              //   ),
              // ),

              // SizedBox(height: 10),
              // "Best Selling".text.xl.semiBold.make().px12(),
              // SizedBox(height: 10),
              // CustomMasonryGridView(
              //   canRefresh: false,
              //   isLoading: vm.isBusy,
              //   onRefresh: null,
              //   crossAxisSpacing: 10,
              //   mainAxisSpacing: 10,
              //   crossAxisCount: 1,
              //   items:
              //       vm.bestSelling
              //           .map(
              //             (product) => HomeServicesListItem(
              //               service: product,
              //               onPressed: vm.servicePressed,
              //               // qtyUpdated: vm.addToCartDirectly,
              //             ),
              //           )
              //           .toList(),
              // ).px12(),

              // CustomMasonryGridView(
              //   canRefresh: false,
              //   isLoading: vm.isBusy,
              //   onRefresh: null,
              //   crossAxisSpacing: 10,
              //   mainAxisSpacing: 10,
              //   crossAxisCount: 1,
              //   items:
              //       vm.topRated
              //           .map(
              //             (product) => HomeServicesListItem(
              //               service: product,
              //               onPressed: vm.servicePressed,
              //               // qtyUpdated: vm.addToCartDirectly,
              //             ),
              //           )
              //           .toList(),
              // ).px12(),

              // Container(
              //   padding: EdgeInsets.only(bottom: 12),
              //   child: SectionVendorsHomeView(
              //     null,
              //     title: "Best selling".tr(),
              //     scrollDirection: Axis.horizontal,
              //     type: SearchFilterType.featured,
              //     itemWidth: context.percentWidth * 58,
              //     // byLocation: AppStrings.enableFatchByLocation,
              //     hideEmpty: true,
              //     titlePadding: EdgeInsets.symmetric(
              //       horizontal: 20,
              //       vertical: 12,
              //     ),
              //     itemsPadding: EdgeInsets.symmetric(horizontal: 20),
              //   ),
              // ),
              SizedBox(height: 6),

              // Container(
              //   padding: EdgeInsets.symmetric(horizontal: 0, vertical: 6),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     mainAxisAlignment: MainAxisAlignment.start,
              //     children: [
              //       const Text(
              //         "Trending Destinations",
              //         style: TextStyle(
              //           fontSize: 18,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ).px(20),
              //       const Text(
              //         "Popular destinations to kickstart your planning",
              //         style: TextStyle(fontSize: 14),
              //       ).px(20),
              //     ],
              //   ),
              // ),

              // vm.destinations.length.text.make(),
              SizedBox(height: 16),
              AdsBottom(
                null,
                padding: 10,
                viewportFraction: 1,
                featured: false,
              ),

              TravelNewsPage(
                blogs: vm.blogs,
                hasMore: vm.blogHasMore,
                onLoadMore: () => vm.getBlogs(),
                loading: vm.busy(vm.blogs),
              ),
              // TravelNewsPage(blogs: vm.blogs),
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
