import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/custom_image.view.dart';
import 'package:fuodz/component/list/food_horizontal_product.list_item.dart';
import 'package:fuodz/models/search.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/pages/search/search.page.dart';
import 'package:fuodz/pages/vendor/widgets/ads_bottom.view.dart';
import 'package:fuodz/pages/vendor/widgets/ads_top.view.dart';
import 'package:fuodz/pages/vendor/widgets/section_products.view.dart';
import 'package:fuodz/pages/vendor/widgets/section_vendors_foods.view.dart';
import 'package:fuodz/utils/app_images.dart';
import 'package:fuodz/utils/app_routes.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/extensions/dynamic.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/utils/product_fetch_data_type.enum.dart';
import 'package:fuodz/utils/sizes.dart';

class FoodPage extends ConsumerStatefulWidget {
  const FoodPage(this.vendorType, {super.key});

  final VendorType vendorType;

  @override
  ConsumerState<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends ConsumerState<FoodPage>
    with AutomaticKeepAliveClientMixin<FoodPage> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                widget.vendorType.name.text
                    .size(16)
                    .color(context.primaryColor)
                    .bold
                    .make(),
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
                onTap: () {
                  final search = Search(
                    vendorType: widget.vendorType,
                    showProductsTag: true,
                    showVendorsTag: true,
                    byLocation: false,
                  );
                  context.pushWidget(SearchPage(search: search));
                },
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
                vertical: 10,
              ),
              child: SectionProductsView(
                widget.vendorType,
                title: "Popular".tr().fill([widget.vendorType.name]),
                scrollDirection: Axis.horizontal,
                type: ProductFetchDataType.BEST,
                itemWidth: context.percentWidth * 60,
                itemHeight: 120,
                viewType: FoodHorizontalProductListItem,
                listHeight: 115,
                byLocation: AppStrings.enableFatchByLocation,
                separator: 0.widthBox,
                itemsPadding: const EdgeInsets.symmetric(horizontal: 0),
                spacer: 5,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
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
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
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
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}
