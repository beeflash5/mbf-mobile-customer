import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/card/view_all_vendors.view.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/pages/flash_sale/widgets/flash_sale.view.dart';
import 'package:fuodz/pages/pharmacy/widgets/pharmacy_categories.view.dart';
import 'package:fuodz/pages/vendor/widgets/banners.view.dart';
import 'package:fuodz/pages/vendor/widgets/best_selling_products.view.dart';
import 'package:fuodz/pages/vendor/widgets/header.view.dart';
import 'package:fuodz/pages/vendor/widgets/nearby_vendors.view.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_strings.dart';

class PharmacyPage extends ConsumerStatefulWidget {
  const PharmacyPage(this.vendorType, {super.key});

  final VendorType vendorType;

  @override
  ConsumerState<PharmacyPage> createState() => _PharmacyPageState();
}

class _PharmacyPageState extends ConsumerState<PharmacyPage>
    with AutomaticKeepAliveClientMixin<PharmacyPage> {
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
          controller: _refreshController,
          onRefresh: _reload,
          child: VStack([
            Banners(widget.vendorType),
            PharmacyCategories(widget.vendorType),
            FlashSaleView(widget.vendorType),
            BestSellingProducts(widget.vendorType),
            NearByVendors(widget.vendorType),
            ViewAllVendorsView(vendorType: widget.vendorType),
          ], spacing: 10).scrollVertical(),
        ).expand(),
      ]),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
