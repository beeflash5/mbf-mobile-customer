import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/card/view_all_vendors.view.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/pages/flash_sale/widgets/flash_sale.view.dart';
import 'package:fuodz/pages/grocery/widgets/grocery_categories.view.dart';
import 'package:fuodz/pages/grocery/widgets/grocery_categories_products.view.dart';
import 'package:fuodz/pages/grocery/widgets/grocery_picks.view.dart';
import 'package:fuodz/pages/shared/widgets/section_coupons.view.dart';
import 'package:fuodz/pages/vendor/widgets/banners.view.dart';
import 'package:fuodz/pages/vendor/widgets/header.view.dart';
import 'package:fuodz/pages/vendor/widgets/nearby_vendors.view.dart';
import 'package:fuodz/services/product_search.helper.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/product_fetch_data_type.enum.dart';

class GroceryPage extends ConsumerStatefulWidget {
  const GroceryPage(this.vendorType, {super.key});

  final VendorType vendorType;

  @override
  ConsumerState<GroceryPage> createState() => _GroceryPageState();
}

class _GroceryPageState extends ConsumerState<GroceryPage>
    with AutomaticKeepAliveClientMixin<GroceryPage> {
  GlobalKey pageKey = GlobalKey<State>();
  final RefreshController _refreshController = RefreshController();

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() => pageKey = GlobalKey<State>());
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BasePage(
      showAppBar: true,
      showLeadingAction: !AppStrings.isSingleVendorMode,
      elevation: 0,
      title: widget.vendorType.name,
      appBarColor: context.theme.colorScheme.surface,
      appBarItemColor: AppColor.primaryColor,
      showCart: true,
      key: pageKey,
      body: VStack([
        VendorHeader(vendorType: widget.vendorType, onrefresh: _reload),
        SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          controller: _refreshController,
          onRefresh: _reload,
          child:
              VStack([
                Banners(widget.vendorType, viewportFraction: 0.98).px20(),
                GroceryCategories(widget.vendorType),
                SectionCouponsView(
                  widget.vendorType,
                  title: "Coupons".tr(),
                  scrollDirection: Axis.horizontal,
                  itemWidth: context.percentWidth * 70,
                  height: 90,
                  itemsPadding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                ),
                FlashSaleView(widget.vendorType),
                GroceryProductsSectionView(
                  "Today Picks".tr() + " 🔥",
                  widget.vendorType,
                  showGrid: true,
                  type: ProductFetchDataType.RANDOM,
                  onSeeAllPressed:
                      () => ProductSearchHelper.openProductsSeeAllPage(
                        title: "Today Picks".tr() + " 🔥",
                        vendorType: widget.vendorType,
                        type: ProductFetchDataType.RANDOM,
                      ),
                ),
                NearByVendors(widget.vendorType),
                GroceryCategoryProducts(widget.vendorType, length: 6),
                ViewAllVendorsView(vendorType: widget.vendorType),
              ], spacing: 12).scrollVertical(),
        ).expand(),
      ]),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
