import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/custom_image.view.dart';
import 'package:fuodz/models/search.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/pages/commerce/widgets/products_new_arival.view.dart';
import 'package:fuodz/pages/search/search.page.dart';
import 'package:fuodz/pages/vendor/widgets/ads_bottom.view.dart';
import 'package:fuodz/pages/vendor/widgets/ads_top.view.dart';
import 'package:fuodz/services/product_search.helper.dart';
import 'package:fuodz/utils/app_images.dart';
import 'package:fuodz/utils/app_routes.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/utils/product_fetch_data_type.enum.dart';
import 'package:fuodz/utils/sizes.dart';

class CommercePage extends ConsumerStatefulWidget {
  const CommercePage(this.vendorType, {super.key});

  final VendorType vendorType;

  @override
  ConsumerState<CommercePage> createState() => _CommercePageState();
}

class _CommercePageState extends ConsumerState<CommercePage>
    with AutomaticKeepAliveClientMixin<CommercePage> {
  @override
  bool get wantKeepAlive => true;

  GlobalKey pageKey = GlobalKey<State>();

  void _showSearchPage() {
    final search = Search(
      vendorType: widget.vendorType,
      showProductsTag: true,
      showVendorsTag: true,
      byLocation: false,
    );
    context.pushWidget(SearchPage(search: search));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    String pageTitle = '';
    if (!AppStrings.isSingleVendorMode) {
      pageTitle = widget.vendorType.name;
    }
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
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
                pageTitle.text.size(16).color(context.primaryColor).bold.make(),
            actions: [
              InkWell(
                onTap: () => context.pushRoute(AppRoutes.notificationsRoute),
                child: Icon(
                  Icons.notifications,
                  color: context.primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: _showSearchPage,
                child: Image.asset(AppImages.search, width: 30, height: 30),
              ),
              const SizedBox(width: 10),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
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
                  const SizedBox(height: 20),
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Sizes.paddingSizeDefault,
              ),
              child: ProductsNewArival(
                "New Arrivals".tr(),
                "New products with updated stocks.".tr(),
                titleCapitalize: false,
                vendorType: widget.vendorType,
                type: ProductFetchDataType.NEW,
                onSeeAllPressed:
                    () => ProductSearchHelper.openProductsSeeAllPage(
                      title: "New Arrivals".tr(),
                      vendorType: widget.vendorType,
                      type: ProductFetchDataType.NEW,
                    ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Sizes.paddingSizeDefault,
                vertical: 18,
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Sizes.paddingSizeDefault,
              ),
              child: ProductsNewArival(
                "Best Selling".tr(),
                "Best selling products around selected location".tr(),
                titleCapitalize: false,
                vendorType: widget.vendorType,
                type: ProductFetchDataType.BEST,
                scrollDirection: Axis.horizontal,
                showGrid: false,
                itemBottomPadding: 5,
                onSeeAllPressed:
                    () => ProductSearchHelper.openProductsSeeAllPage(
                      title: "Best Selling".tr(),
                      vendorType: widget.vendorType,
                      type: ProductFetchDataType.BEST,
                    ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}
