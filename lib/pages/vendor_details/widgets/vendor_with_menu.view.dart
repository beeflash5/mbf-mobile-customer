import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/bottom_sheet/cart.bottomsheet.dart';
import 'package:fuodz/component/busy_indicator.dart';
import 'package:fuodz/component/button/custom_rounded_leading.dart';
import 'package:fuodz/component/button/share.btn.dart';
import 'package:fuodz/component/cart_page_action.dart';
import 'package:fuodz/component/custom_easy_refresh_view.dart';
import 'package:fuodz/component/custom_image.view.dart';
import 'package:fuodz/component/list/vendor_menu_product.list_item.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/pages/product/product_details.page.dart';
import 'package:fuodz/pages/vendor_details/widgets/vendor_details_header.view.dart';
import 'package:fuodz/pages/vendor_details/widgets/vendor_fav.btn.dart';
import 'package:fuodz/providers/vendor_menu_details_providers.dart';
import 'package:fuodz/services/cart.helper.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';

class VendorDetailsWithMenuPage extends ConsumerStatefulWidget {
  const VendorDetailsWithMenuPage({required this.vendor, super.key});

  final Vendor vendor;

  @override
  ConsumerState<VendorDetailsWithMenuPage> createState() =>
      _VendorDetailsWithMenuPageState();
}

class _VendorDetailsWithMenuPageState
    extends ConsumerState<VendorDetailsWithMenuPage>
    with TickerProviderStateMixin {
  TabController? _tabController;
  int _lastTabLength = -1;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _ensureTabController(int length) {
    if (_lastTabLength == length) return;
    _tabController?.dispose();
    _tabController = TabController(length: length, vsync: this);
    _lastTabLength = length;
  }

  @override
  Widget build(BuildContext context) {
    final asyncState =
        ref.watch(vendorMenuDetailsControllerProvider(widget.vendor.id));
    final notifier =
        ref.read(vendorMenuDetailsControllerProvider(widget.vendor.id).notifier);
    final state = asyncState.valueOrNull;
    final vendor = state?.vendor ?? widget.vendor;
    final menus = state?.vendor.menus ?? const [];
    _ensureTabController(menus.length);

    double featureImageHeight = context.percentHeight * 20;
    if (featureImageHeight > 250) featureImageHeight = 250;

    return Scaffold(
      backgroundColor: context.theme.colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool scrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: featureImageHeight,
              floating: false,
              pinned: true,
              leading: CustomRoundedLeading(),
              backgroundColor: context.backgroundColor,
              actions: [
                VendorFavButton(vendor: vendor),
                SizedBox(
                  width: 50,
                  height: 50,
                  child: FittedBox(child: ShareButton(vendor: vendor)),
                ),
                UiSpacer.hSpace(10),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  child: PageCartAction(),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                background: CustomImage(
                  imageUrl: vendor.featureImage,
                  height: featureImageHeight,
                  canZoom: true,
                ).wFull(context),
              ),
            ),
            SliverToBoxAdapter(
              child: VendorDetailsHeader(
                vendor,
                showFeatureImage: false,
                featureImageHeight: featureImageHeight,
                showPrescription: true,
              ),
            ),
            if (menus.isNotEmpty && _tabController != null)
              SliverAppBar(
                title: "".text.make(),
                floating: false,
                pinned: true,
                snap: false,
                primary: false,
                automaticallyImplyLeading: false,
                flexibleSpace: TabBar(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  isScrollable: true,
                  labelColor: Utils.primaryOrTheme,
                  unselectedLabelColor: Utils.textColorByBrightness(),
                  indicatorWeight: 4,
                  indicator: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: context.theme.primaryColor,
                        width: 3,
                      ),
                    ),
                  ),
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabAlignment: TabAlignment.start,
                  dividerHeight: 0,
                  tabs: menus
                      .map((menu) => Tab(
                            text: menu.name,
                            iconMargin: EdgeInsets.zero,
                          ))
                      .toList(),
                ),
              ),
          ];
        },
        body: asyncState.isLoading || _tabController == null
            ? BusyIndicator().p20().centered()
            : TabBarView(
                controller: _tabController,
                children: menus.map((menu) {
                  final products = state?.menuProducts[menu.id] ?? const [];
                  final loading = state?.loadingMore[menu.id] ?? false;
                  return CustomEasyRefreshView(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    onRefresh: () => notifier.refreshMenu(menu.id),
                    onLoad: () => notifier.loadMore(menu.id),
                    loading: loading,
                    dataset: products,
                    separator: 5.heightBox,
                    listView: products
                        .map(
                          (product) => VendorMenuProductListItem(
                            product,
                            onPressed: (p) => context.pushWidget(ProductDetailsPage(product: p)),
                            qtyUpdated: (p, q) =>
                                CartHelper.addToCartDirectly(context, p, q),
                          ),
                        )
                        .toList(),
                  );
                }).toList(),
              ),
      ),
      bottomSheet: CartViewBottomSheet(),
    );
  }
}
