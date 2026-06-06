import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/component/custom_masonry_grid_view.dart';
import 'package:fuodz/component/list/home_services.list_item.dart';
import 'package:fuodz/models/category.dart';
import 'package:fuodz/models/search.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/pages/service/service_details.page.dart';
import 'package:fuodz/providers/products_listing_providers.dart';
import 'package:fuodz/utils/app_routes.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/utils/product_fetch_data_type.enum.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class HomeService extends ConsumerWidget {
  const HomeService(
    this.title,
    this.vendorType, {
    this.type = ProductFetchDataType.RANDOM,
    this.category,
    this.showGrid = true,
    this.crossAxisCount = 2,
    this.onSeeAllPressed,
    super.key,
  });

  final String title;
  final bool showGrid;
  final int crossAxisCount;
  final VendorType vendorType;
  final ProductFetchDataType type;
  final Category? category;
  final Function? onSeeAllPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncServices =
        ref.watch(homeBestServicesControllerProvider(vendorType.id));
    final services = asyncServices.valueOrNull ?? const [];
    final isLoading = asyncServices.isLoading;

    return CustomVisibilty(
      visible: services.isNotEmpty && !isLoading,
      child: VStack([
        HStack([
          title.text.xl.semiBold.make().expand(),
          UiSpacer.smHorizontalSpace(),
          "See all".tr().text.color(context.primaryColor).make().onInkTap(() {
            if (onSeeAllPressed != null) {
              onSeeAllPressed!();
            } else {
              final search = Search(
                category: category,
                vendorType: vendorType,
                showProductsTag: true,
              );
              context.pushRoute(AppRoutes.search, extra: search);
            }
          }),
        ]).p12(),
        if (showGrid)
          CustomMasonryGridView(
            isLoading: isLoading,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: crossAxisCount,
            items: services
                .map(
                  (service) => HomeServicesListItem(
                    service: service,
                    onPressed: (s) => context.pushWidget(ServiceDetailsPage(s)),
                  ),
                )
                .toList(),
          ).px12(),
      ]).py12(),
    );
  }
}
