import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/vendor_type_categories.view.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/pages/service/widgets/categories_services.view.dart';
import 'package:fuodz/pages/service/widgets/popular_services.view.dart';
import 'package:fuodz/pages/vendor/widgets/complex_header.view.dart';
import 'package:fuodz/pages/vendor/widgets/simple_styled_banners.view.dart';
import 'package:fuodz/providers/service_providers.dart';
import 'package:fuodz/services/navigation.service.dart';
import 'package:fuodz/utils/app_strings.dart';

import 'widgets/top_service_vendors.view.dart';

class ServicePage extends ConsumerStatefulWidget {
  const ServicePage(this.vendorType, {super.key});

  final VendorType vendorType;

  @override
  ConsumerState<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends ConsumerState<ServicePage>
    with AutomaticKeepAliveClientMixin<ServicePage> {
  GlobalKey pageKey = GlobalKey<State>();
  final RefreshController _refreshController = RefreshController();

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    await ref
        .read(serviceHomeControllerProvider(widget.vendorType.id).notifier)
        .refresh();
    _refreshController.refreshCompleted();
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
      showCart: false,
      key: pageKey,
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _reload,
        enablePullDown: true,
        child: VStack([
          10.heightBox,
          ComplexVendorHeader(
                onrefresh: _reload,
                onSearchPressed:
                    () => NavigationService.openServiceSearch(
                      context,
                      vendorType: widget.vendorType,
                    ),
              ).box
              .color(context.theme.colorScheme.surface)
              .roundedSM
              .outerShadowSm
              .make()
              .px(10),
          VStack([
            SimpleStyledBanners(
              widget.vendorType,
              height: AppStrings.bannerHeight,
              withPadding: false,
              viewportFraction: 0.92,
              hideEmpty: true,
            ),
            VendorTypeCategories(
              widget.vendorType,
              title: "Categories",
              childAspectRatio: 1.4,
              crossAxisCount: 4,
            ),
            PopularServicesView(widget.vendorType),
            TopServiceVendors(widget.vendorType),
            CategoriesServicesView(
              widget.vendorType,
              showTitle: true,
              maxCategories: 5,
            ),
            20.heightBox,
          ], spacing: 12).scrollVertical().expand(),
        ]),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
