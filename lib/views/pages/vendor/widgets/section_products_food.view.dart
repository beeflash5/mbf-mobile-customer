import 'package:flutter/material.dart';
import 'package:fuodz/enums/product_fetch_data_type.enum.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/view_models/products.vm.dart';
import 'package:fuodz/widgets/buttons/custom_button_light.dart';
import 'package:fuodz/widgets/cards/custom.visibility.dart';
import 'package:fuodz/widgets/custom_list_view.dart';
import 'package:fuodz/widgets/food_card.dart';
import 'package:fuodz/widgets/list_items/commerce_product.list_item.dart';
import 'package:fuodz/widgets/list_items/food_horizontal_product.list_item.dart';
import 'package:fuodz/widgets/list_items/grid_view_product.list_item.dart';
import 'package:fuodz/widgets/list_items/grocery_product.list_item.dart';
import 'package:fuodz/widgets/list_items/horizontal_product.list_item.dart';
import 'package:fuodz/widgets/section.title.dart';
import 'package:fuodz/widgets/states/vendor.empty.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class SectionProductFoodsView extends StatelessWidget {
  const SectionProductFoodsView(
    this.vendorType, {
    this.title = "",
    this.scrollDirection = Axis.vertical,
    this.type = ProductFetchDataType.BEST,
    this.itemWidth,
    this.itemHeight,
    this.viewType,
    this.listHeight = 195,
    this.separator,
    this.byLocation = false,
    this.hideEmpty = false,
    this.itemsPadding,
    this.titlePadding,
    this.spacer,
    Key? key,
  }) : super(key: key);

  final VendorType? vendorType;
  final Axis scrollDirection;
  final ProductFetchDataType type;
  final String title;
  final double? itemWidth;
  final double? itemHeight;
  final dynamic viewType;
  final double? listHeight;
  final Widget? separator;
  final bool byLocation;
  final EdgeInsets? itemsPadding;
  final EdgeInsets? titlePadding;
  final double? spacer;
  final bool hideEmpty;

  @override
  Widget build(BuildContext context) {
    return CustomVisibilty(
      // visible: !AppStrings.enableSingleVendor,
      child: ViewModelBuilder<ProductsViewModel>.reactive(
        viewModelBuilder:
            () => ProductsViewModel(
              context,
              vendorType,
              type,
              byLocation: byLocation,
            ),
        onViewModelReady: (model) => model.initialise(),
        builder: (context, model, child) {
          //if not busy and list is empty && hideEmpty == true
          if (!model.isBusy && model.products.isEmpty && hideEmpty) {
            return 0.widthBox;
          }
          //listview
          Widget listView = CustomListView(
            noScrollPhysics: true,
            scrollDirection: Axis.vertical,
            padding: itemsPadding ?? EdgeInsets.symmetric(horizontal: 10),
            dataSet: model.products,
            isLoading: model.isBusy,
            itemBuilder: (context, index) {
              //
              final product = model.products[index];
              Widget itemView;

              itemView = FoodCard(
                product: product,
                onTap: () => model.productSelected(product),
              );
              //
              if (itemWidth != null) {
                return itemView.w(itemWidth!);
              }
              return itemView;
            },
            emptyWidget: EmptyVendor(),
            separatorBuilder:
                separator != null ? (ctx, index) => separator! : null,
          );
          //
          return CustomVisibilty(
            visible: !model.isBusy && !model.products.isEmpty,
            child: VStack([
              //
              SizedBox(height: 16),

              Padding(
                padding: titlePadding ?? EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    "Popular Foods Nearby".tr().text.bold.xl.make(),
                    "Best selling products around selected location"
                        .tr()
                        .text
                        .make(),
                  ],
                ),
              ),
              SizedBox(height: 16),
              //
              listView,
              SizedBox(height: 10),
              model.products.length > 0
                  ? CustomButtonLight(
                    title: "View All".tr(),
                    onPressed: () {
                      model.openProductsSeeAllPage(
                        title: "Popular".tr(),
                        vendorType: model.vendorType,
                        type: ProductFetchDataType.BEST,
                      );
                    },
                  )
                  : SizedBox(),
            ], spacing: spacer ?? 5),
          );

          //
        },
      ),
    );
  }
}
