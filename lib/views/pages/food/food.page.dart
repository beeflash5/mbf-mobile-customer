import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/app_images.dart';
import 'package:fuodz/constants/app_routes.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/enums/product_fetch_data_type.enum.dart';
import 'package:fuodz/extensions/dynamic.dart';
import 'package:fuodz/models/search.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/services/navigation.service.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/vendor.vm.dart';
import 'package:fuodz/views/pages/flash_sale/widgets/flash_sale.view.dart';
import 'package:fuodz/views/pages/vendor/widgets/ads_bottom.view.dart';
import 'package:fuodz/views/pages/vendor/widgets/ads_top.view.dart';
import 'package:fuodz/views/pages/vendor/widgets/banners.view.dart';
import 'package:fuodz/views/pages/vendor/widgets/header.view.dart';
import 'package:fuodz/views/pages/vendor/widgets/section_products.view.dart';
import 'package:fuodz/views/pages/vendor/widgets/section_products_food.view.dart';
import 'package:fuodz/views/pages/vendor/widgets/section_vendors.view.dart';
import 'package:fuodz/views/pages/vendor/widgets/section_vendors_food.view.dart';
import 'package:fuodz/views/pages/vendor/widgets/section_vendors_foods.view.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/cards/custom.visibility.dart';
import 'package:fuodz/widgets/cards/view_all_vendors.view.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:fuodz/widgets/inputs/search_bar.input.dart';
import 'package:fuodz/widgets/list_items/food_horizontal_product.list_item.dart';
import 'package:fuodz/widgets/list_items/grid_view_product.list_item.dart';
import 'package:fuodz/widgets/list_items/horizontal_product.list_item.dart';
import 'package:fuodz/widgets/list_items/horizontal_vendor.list_item.dart';
import 'package:fuodz/widgets/vendor_type_categories.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class FoodPage extends StatefulWidget {
  const FoodPage(this.vendorType, {Key? key}) : super(key: key);

  final VendorType vendorType;
  @override
  _FoodPageState createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage>
    with AutomaticKeepAliveClientMixin<FoodPage> {
  GlobalKey pageKey = GlobalKey<State>();
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ViewModelBuilder<VendorViewModel>.reactive(
      viewModelBuilder: () => VendorViewModel(context, widget.vendorType),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: context.backgroundColor,
          body: CustomScrollView(
            slivers: [
              // Custom App Bar with Search and Location
              SliverAppBar(
                // expandedHeight: 160 + Sizes.paddingSizeDefault,
                floating: false,
                pinned: true,
                backgroundColor:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white,
                elevation: 0,

                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: context.textTheme.bodyLarge!.color!,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title:
                    widget.vendorType.name.text
                        .size(16)
                        .color(context.primaryColor)
                        .bold
                        .make(),
                actions: [
                  InkWell(
                    onTap: () {
                      Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.notificationsRoute);
                    },
                    child: Icon(
                      Icons.notifications,
                      color: context.primaryColor,
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      final search = Search(
                        vendorType: widget.vendorType,
                        showProductsTag: true,
                        showVendorsTag: true,
                        byLocation: false,
                        // showType: 4,
                      );
                      //
                      final page = NavigationService().searchPageWidget(search);
                      Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (context) => page));
                    },
                    child: Image.asset(AppImages.search, width: 30, height: 30),
                  ),
                  SizedBox(width: 10),
                ],
              ),

              // SliverToBoxAdapter(child: Sizes.paddingSizeDefault.heightBox),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Sizes.paddingSizeDefault,
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(20),
                            ),
                            child: CustomImage(
                              width: MediaQuery.of(context).size.width,
                              height: 200,
                              imageUrl: widget.vendorType.website_header,
                            ),
                          ),

                          Positioned.fill(
                            child: Center(
                              child:
                                  widget.vendorType.name.text
                                      .size(30)
                                      .color(Colors.white)
                                      .bold
                                      .make(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      AdsTop(
                        null,
                        padding: 0,
                        viewportFraction: 1,
                        featured: false,
                        height: 80,
                      ),
                    ],
                  ),
                ),
              ),

              // Categories Grid
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Sizes.paddingSizeDefault,
                    vertical: 10,
                  ),
                  child: SectionProductFoodsView(
                    widget.vendorType,
                    title: "Popular".tr().fill([widget.vendorType.name]),
                    scrollDirection: Axis.horizontal,
                    type: ProductFetchDataType.BEST,
                    itemWidth: context.percentWidth * 60,
                    itemHeight: 120,
                    viewType: FoodHorizontalProductListItem,
                    listHeight: 115,
                    byLocation: AppStrings.enableFatchByLocation,
                    // new otpions
                    separator: 0.widthBox,
                    itemsPadding: EdgeInsets.symmetric(horizontal: 0),
                    spacer: 5,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 10)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Sizes.paddingSizeDefault,
                  ),
                  child: AdsBottom(
                    null,
                    padding: 0,
                    viewportFraction: 1,
                    featured: false,
                    height: 80,
                  ),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 10)),

              SliverToBoxAdapter(
                child: SectionVendorsHomeViewFoods(
                  widget.vendorType,
                  title: "Popular vendors".tr(),
                  scrollDirection: Axis.vertical,
                  type: SearchFilterType.sales,
                  itemWidth: context.percentWidth * 40,
                  byLocation: AppStrings.enableFatchByLocation,
                  spacer: 0,
                ),
              ),

              // Featured Providers
              // if (vm.busy(vm.featuredProviders) ||
              //     (!vm.busy(vm.featuredProviders) &&
              //         vm.featuredProviders.isNotEmpty)) ...[
              //   SliverToBoxAdapter(child: Sizes.paddingSizeDefault.heightBox),
              //   SliverToBoxAdapter(
              //     child: Padding(
              //       padding: EdgeInsets.symmetric(
              //         horizontal: Sizes.paddingSizeDefault,
              //       ),
              //       child: _buildFeaturedProviders(vm),
              //     ),
              //   ),
              // ],
              SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        );
        return BasePage(
          showAppBar: true,
          showLeadingAction: !AppStrings.isSingleVendorMode,
          elevation: 0,
          title: "${widget.vendorType.name}",
          appBarColor: context.theme.colorScheme.surface,
          appBarItemColor: AppColor.primaryColor,
          showCart: true,
          key: model.pageKey,
          body: VStack([
            //location setion
            VendorHeader(
              model: model,
              showSearch: false,
              onrefresh: model.reloadPage,
            ),

            SmartRefresher(
              enablePullDown: true,
              enablePullUp: false,
              controller: model.refreshController,
              onRefresh: model.reloadPage,
              child:
                  VStack(
                    [
                      //search bar
                      SearchBarInput(
                        hintText:
                            "Search for your desired foods or restaurants".tr(),
                        readOnly: true,
                        search: Search(
                          vendorType: widget.vendorType,
                          showProductsTag: true,
                          showVendorsTag: true,
                          // viewType: SearchType.vendorProducts,
                        ),
                      ).px12(),

                      //banners
                      Banners(widget.vendorType, viewportFraction: 0.96),

                      //categories
                      // Categories(
                      //   widget.vendorType,
                      // ),
                      //categories
                      VendorTypeCategories(
                        widget.vendorType,
                        title: "Categories".tr(),
                        childAspectRatio: 1.4,
                        crossAxisCount: AppStrings.categoryPerRow,
                      ),
                      //flash sales products
                      FlashSaleView(widget.vendorType),
                      //popular vendors
                      SectionVendorsView(
                        widget.vendorType,
                        title: "Popular vendors".tr(),
                        scrollDirection: Axis.horizontal,
                        type: SearchFilterType.sales,
                        itemWidth: context.percentWidth * 60,
                        byLocation: AppStrings.enableFatchByLocation,
                        spacer: 0,
                      ),
                      //campain vendors
                      SectionProductsView(
                        widget.vendorType,
                        title: "Campaigns".tr(),
                        scrollDirection: Axis.horizontal,
                        type: ProductFetchDataType.FLASH,
                        itemWidth: context.percentWidth * 38,
                        viewType: GridViewProductListItem,
                        byLocation: AppStrings.enableFatchByLocation,
                        // new otpions
                        separator: 0.widthBox,
                        itemsPadding: EdgeInsets.symmetric(horizontal: 0),
                        spacer: 0,
                      ),
                      //popular foods
                      SectionProductsView(
                        widget.vendorType,
                        title: "Popular %s Nearby".tr().fill([
                          widget.vendorType.name,
                        ]),
                        scrollDirection: Axis.horizontal,
                        type: ProductFetchDataType.BEST,
                        itemWidth: context.percentWidth * 60,
                        itemHeight: 120,
                        viewType: FoodHorizontalProductListItem,
                        listHeight: 115,
                        byLocation: AppStrings.enableFatchByLocation,
                        // new otpions
                        separator: 0.widthBox,
                        itemsPadding: EdgeInsets.symmetric(horizontal: 0),
                        spacer: 0,
                      ),
                      //new vendors
                      CustomVisibilty(
                        visible: !AppStrings.enableSingleVendor,
                        child: SectionVendorsView(
                          widget.vendorType,
                          title: "New on".tr() + " ${AppStrings.appName}",
                          scrollDirection: Axis.horizontal,
                          type: SearchFilterType.fresh,
                          itemWidth: context.percentWidth * 60,
                          byLocation: AppStrings.enableFatchByLocation,
                          spacer: 0,
                        ),
                      ),
                      //all vendor
                      CustomVisibilty(
                        visible: !AppStrings.enableSingleVendor,
                        child: SectionVendorsView(
                          widget.vendorType,
                          title: "All Vendors/Restaurants".tr(),
                          scrollDirection: Axis.vertical,
                          type: SearchFilterType.best,
                          viewType: HorizontalVendorListItem,
                          separator: UiSpacer.verticalSpace(space: 0),
                          byLocation: AppStrings.enableFatchByLocation,
                          spacer: 0,
                        ),
                      ),
                      //all products
                      CustomVisibilty(
                        visible: AppStrings.enableSingleVendor,
                        child: SectionProductsView(
                          widget.vendorType,
                          title: "All Products".tr(),
                          scrollDirection: Axis.vertical,
                          type: ProductFetchDataType.BEST,
                          viewType: HorizontalProductListItem,
                          separator: UiSpacer.verticalSpace(space: 0),
                          listHeight: null,
                          byLocation: AppStrings.enableFatchByLocation,
                        ),
                      ),
                      //view all vendors
                      ViewAllVendorsView(vendorType: widget.vendorType),
                      UiSpacer.verticalSpace(),
                    ],
                    // key: model.pageKey,
                    spacing: 12,
                  ).scrollVertical(),
            ).expand(),
          ]),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
