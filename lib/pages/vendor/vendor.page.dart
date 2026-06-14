import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/card/view_all_vendors.view.dart';
import 'package:fuodz/component/vendor_type_categories.view.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/pages/vendor/widgets/banners.view.dart';
import 'package:fuodz/pages/vendor/widgets/best_selling_products.view.dart';
import 'package:fuodz/pages/vendor/widgets/for_you_products.view.dart';
import 'package:fuodz/pages/vendor/widgets/header.view.dart';
import 'package:fuodz/pages/vendor/widgets/nearby_vendors.view.dart';
import 'package:fuodz/pages/vendor/widgets/top_vendors.view.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class VendorPage extends ConsumerStatefulWidget {
  const VendorPage(this.vendorType, {super.key});

  final VendorType vendorType;

  @override
  ConsumerState<VendorPage> createState() => _VendorPageState();
}

class _VendorPageState extends ConsumerState<VendorPage>
    with AutomaticKeepAliveClientMixin<VendorPage> {
  GlobalKey pageKey = GlobalKey<State>();
  final RefreshController _refreshController = RefreshController();

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() => pageKey = GlobalKey<State>());
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
          onRefresh: () {
            _refreshController.refreshCompleted();
            _reload();
          },
          child:
              VStack([
                Banners(widget.vendorType),
                VendorTypeCategories(
                  widget.vendorType,
                  showTitle: false,
                  description: "Categories".tr(),
                  childAspectRatio: 1.4,
                ),
                AppStrings.enableSingleVendor
                    ? UiSpacer.emptySpace()
                    : NearByVendors(widget.vendorType),
                BestSellingProducts(widget.vendorType),
                ForYouProducts(widget.vendorType),
                AppStrings.enableSingleVendor
                    ? UiSpacer.verticalSpace()
                    : TopVendors(widget.vendorType),
                ViewAllVendorsView(vendorType: widget.vendorType),
              ]).scrollVertical(),
        ).expand(),
      ]),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
