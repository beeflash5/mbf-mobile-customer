import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/list/dynamic_product.list_item.dart';
import 'package:fuodz/component/list/vendor.list_item.dart';
import 'package:fuodz/component/states/error.state.dart';
import 'package:fuodz/component/states/product.empty.dart';
import 'package:fuodz/component/states/vendor.empty.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/providers/favourites_providers.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_routes.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/utils/sizes.dart';
import 'package:fuodz/utils/utils.dart';

class FavouritesPage extends ConsumerWidget {
  const FavouritesPage({super.key});

  Future<void> _confirmRemoveProduct(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) async {
    final confirmed = await AlertService.confirm(
      title: 'Remove Product From Favourite'.tr(),
      text:
          'Are you sure you want to remove this product from your favourite list?'
              .tr(),
      confirmBtnText: 'Remove'.tr(),
    );
    if (!confirmed) return;
    final res = await ref
        .read(favouriteProductsControllerProvider.notifier)
        .remove(product);
    AlertService.dynamic(
      type: res.ok ? AlertType.success : AlertType.error,
      title: 'Remove Product From Favourite'.tr(),
      text: res.message,
    );
  }

  Future<void> _confirmRemoveVendor(
    BuildContext context,
    WidgetRef ref,
    Vendor vendor,
  ) async {
    final confirmed = await AlertService.confirm(
      title: 'Remove Vendor From Favourite'.tr(),
      text:
          'Are you sure you want to remove this vendor from your favourite list?'
              .tr(),
      confirmBtnText: 'Remove'.tr(),
    );
    if (!confirmed) return;
    final res = await ref
        .read(favouriteVendorsControllerProvider.notifier)
        .remove(vendor);
    AlertService.dynamic(
      type: res.ok ? AlertType.success : AlertType.error,
      title: 'Remove Vendor From Favourite'.tr(),
      text: res.message,
    );
  }

  Future<void> _openProductDetails(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) async {
    await context.pushRoute(
      '${AppRoutes.product}/${product.id}',
      extra: product,
    );
    await ref.read(favouriteProductsControllerProvider.notifier).refresh();
  }

  Future<void> _openVendorDetails(
    BuildContext context,
    WidgetRef ref,
    Vendor vendor,
  ) async {
    await context.pushRoute(
      '${AppRoutes.vendorDetails}/${vendor.id}',
      extra: vendor,
    );
    await ref.read(favouriteVendorsControllerProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(favouriteProductsControllerProvider);
    final vendorsAsync = ref.watch(favouriteVendorsControllerProvider);
    final themeTextColor = Utils.textColorByPrimaryColor();

    return DefaultTabController(
      length: 2,
      child: BasePage(
        showAppBar: true,
        showLeadingAction: true,
        title: 'Favourites'.tr(),
        isLoading: productsAsync.isLoading && vendorsAsync.isLoading,
        body: ContainedTabBarView(
          tabBarProperties: TabBarProperties(
            isScrollable: true,
            alignment: TabBarAlignment.center,
            padding:
                EdgeInsets.symmetric(horizontal: Sizes.paddingSizeDefault),
            labelPadding: EdgeInsets.symmetric(
              horizontal: Sizes.paddingSizeLarge,
              vertical: 0,
            ),
            labelColor: themeTextColor,
            unselectedLabelColor: themeTextColor.withOpacity(0.85),
            labelStyle: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(fontWeight: FontWeight.bold),
            background: Container(color: AppColor.primaryColor),
            indicatorWeight: 4,
            indicator: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: themeTextColor, width: 3),
              ),
            ),
          ),
          tabs: [
            Tab(text: 'Proucts'.tr()),
            Tab(text: 'Vendors'.tr()),
          ],
          views: [
            // PRODUCTS TAB
            CustomListView(
              padding: EdgeInsets.all(Sizes.paddingSizeDefault),
              dataSet: productsAsync.valueOrNull ?? const [],
              isLoading: productsAsync.isLoading,
              emptyWidget: EmptyProduct(
                description:
                    'Your favorite products/items will appear here. Start exploring and add products/items to your favorites!'
                        .tr(),
              ).p(Sizes.paddingSizeLarge),
              errorWidget: LoadingError(
                onrefresh: ref
                    .read(favouriteProductsControllerProvider.notifier)
                    .refresh,
              ),
              itemBuilder: (context, index) {
                final list = productsAsync.valueOrNull ?? const [];
                final product = list[index];
                return Stack(
                  children: [
                    DynamicProductListItem(
                      product,
                      padding: EdgeInsets.zero,
                      onPressed: (p) => _openProductDetails(context, ref, p),
                    ).onLongPress(
                      () => _confirmRemoveProduct(context, ref, product),
                      GlobalKey(),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmRemoveProduct(context, ref, product),
                      ).box.color(context.theme.colorScheme.surface).roundedFull.outerShadow.make().p4(),
                    ),
                  ],
                );
              },
              separatorBuilder: (_, __) => 10.heightBox,
            ),
            // VENDORS TAB
            CustomListView(
              padding: EdgeInsets.all(Sizes.paddingSizeDefault),
              dataSet: vendorsAsync.valueOrNull ?? const [],
              isLoading: vendorsAsync.isLoading,
              emptyWidget: EmptyVendor(
                description:
                    'Your favorite vendors will appear here. Start exploring and add vendors to your favorites!'
                        .tr(),
              ).p(Sizes.paddingSizeLarge),
              errorWidget: LoadingError(
                onrefresh: ref
                    .read(favouriteVendorsControllerProvider.notifier)
                    .refresh,
              ),
              itemBuilder: (context, index) {
                final list = vendorsAsync.valueOrNull ?? const [];
                final vendor = list[index];
                return Stack(
                  children: [
                    VendorListItem(
                      vendor: vendor,
                      onPressed: (v) => _openVendorDetails(context, ref, v),
                    ).onLongPress(
                      () => _confirmRemoveVendor(context, ref, vendor),
                      GlobalKey(),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmRemoveVendor(context, ref, vendor),
                      ).box.color(context.theme.colorScheme.surface).roundedFull.outerShadow.make().p4(),
                    ),
                  ],
                ).centered();
              },
              separatorBuilder: (_, __) => 10.heightBox,
            ),
          ],
        ),
      ),
    );
  }
}
