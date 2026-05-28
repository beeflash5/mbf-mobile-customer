import 'package:flutter/material.dart';
import 'package:fuodz/enums/product_fetch_data_type.enum.dart';
import 'package:fuodz/models/category.dart';
import 'package:fuodz/models/search.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/home_products.vm.dart';
import 'package:fuodz/view_models/home_services.vm.dart';
import 'package:fuodz/view_models/products.vm.dart';
import 'package:fuodz/views/pages/search/search.page.dart';
import 'package:fuodz/widgets/cards/custom.visibility.dart';
import 'package:fuodz/widgets/custom_list_view.dart';
import 'package:fuodz/widgets/custom_masonry_grid_view.dart';
import 'package:fuodz/widgets/list_items/grocery_product.list_item.dart';
import 'package:fuodz/widgets/list_items/home_product.list_item.dart';
import 'package:fuodz/widgets/list_items/home_services.list_item.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:fuodz/extensions/context.dart';

class HomeService extends StatelessWidget {
  const HomeService(
    this.title,
    this.vendorType, {
    this.type = ProductFetchDataType.RANDOM,
    this.category,
    this.showGrid = true,
    this.crossAxisCount = 2,
    this.onSeeAllPressed,
    Key? key,
  }) : super(key: key);

  final String title;
  final bool showGrid;
  final int crossAxisCount;
  final VendorType vendorType;
  final ProductFetchDataType type;
  final Category? category;
  final Function? onSeeAllPressed;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeServicesViewModel>.reactive(
      viewModelBuilder:
          () => HomeServicesViewModel(
            context,
            vendorType,
            type,
            categoryId: category?.id,
          ),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return CustomVisibilty(
          visible: vm.services.isNotEmpty && !vm.isBusy,
          child:
              VStack([
                //
                HStack([
                  "$title".text.xl.semiBold.make().expand(),
                  UiSpacer.smHorizontalSpace(),
                  "See all"
                      .tr()
                      .text
                      .color(context.primaryColor)
                      .make()
                      .onInkTap(() {
                        if (onSeeAllPressed != null) {
                          onSeeAllPressed!();
                        } else {
                          //
                          final search = Search(
                            category: category,
                            vendorType: vendorType,
                            showProductsTag: true,
                            // showType: 2,
                          );
                          //open search page
                          context.push((context) {
                            return SearchPage(search: search);
                          });
                        }
                      }),
                ]).p12(),
                // if (!showGrid)
                //   CustomListView(
                //     isLoading: vm.isBusy,
                //     dataSet: vm.services,
                //     scrollDirection: Axis.horizontal,
                //     padding: EdgeInsets.symmetric(horizontal: Vx.dp12),
                //     itemBuilder: (context, index) {
                //       return HomeServicesListItem(
                //         service: vm.services.elementAt(index),
                //         // onPressed: vm.productSelected,
                //         // qtyUpdated: vm.addToCartDirectly,
                //       );
                //     },
                //   ).h(vm.anyProductWithOptions ? 220 : 180),

                if (showGrid)
                  CustomMasonryGridView(
                    isLoading: vm.isBusy,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    crossAxisCount: crossAxisCount,
                    items:
                        vm.services
                            .map(
                              (product) => HomeServicesListItem(
                                service: product,
                                onPressed: vm.servicePressed,
                                // qtyUpdated: vm.addToCartDirectly,
                              ),
                            )
                            .toList(),
                  ).px12(),
              ]).py12(),
        );
      },
    );
  }
}
