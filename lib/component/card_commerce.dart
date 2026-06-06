import 'package:flutter/material.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/extensions/string.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/services/app_currency_system.service.dart';
import 'package:fuodz/pages/product/amazon_styled_commerce_product_details.page.dart';
import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/component/currency_hstack.dart';
import 'package:fuodz/component/custom_image.view.dart';
import 'package:fuodz/component/tags/fav.positioned.dart';
import 'package:fuodz/component/tags/product_tags.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:fuodz/utils/extensions/context.dart';

class CardCommerce extends StatelessWidget {
  const CardCommerce(this.product, {this.height, this.boxFit, Key? key})
    : super(key: key);

  final Product product;
  final double? height;
  final BoxFit? boxFit;

  @override
  Widget build(BuildContext context) {
    return HStack([
          /// IMAGE
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              children: [
                CustomImage(
                      imageUrl: "${product.photo}",
                      width: 100,
                      height: 100,
                      boxFit: boxFit ?? BoxFit.contain,
                    ).box.slate100
                    .withRounded(value: 5)
                    .clip(Clip.antiAlias)
                    .make(),

                /// FAV ICON
                FavPositiedView(product),
              ],
            ),
          ),

          SizedBox(width: 10),

          /// DETAILS
          Expanded(
            child:
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    6.heightBox,

                    /// NAME
                    "${product.name}".text.medium
                        .size(14)
                        .maxLines(2)
                        .ellipsis
                        .make(),

                    /// VENDOR
                    "${product.vendor.name}".text
                        .color(context.primaryColor)
                        .make(),

                    4.heightBox,

                    /// PRICE
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        CurrencyHStack([
                          AppStrings.currentCurrencySymbol.text.base.semiBold
                              .make(),
                          product.sellPrice.convertCurrency
                              .currencyValueFormat()
                              .text
                              .base
                              .bold
                              .make(),
                        ], crossAlignment: CrossAxisAlignment.end),

                        /// DISCOUNT
                        CustomVisibilty(
                          visible: product.showDiscount,
                          child:
                              CurrencyHStack([
                                AppStrings
                                    .currentCurrencySymbol
                                    .text
                                    .lineThrough
                                    .xs
                                    .make(),
                                product.price.convertCurrency
                                    .currencyValueFormat()
                                    .text
                                    .lineThrough
                                    .xs
                                    .medium
                                    .make(),
                              ]).px4(),
                        ),
                      ],
                    ),

                    6.heightBox,

                    /// TAGS
                    ProductTags(product),

                    10.heightBox,
                  ],
                ).px8(),
          ),
        ])
        .onInkTap(() => openProductDetailsPage(context, product))
        .material(color: context.theme.colorScheme.surface)
        .box
        .clip(Clip.antiAlias)
        .color(context.theme.colorScheme.surface)
        .withRounded(value: 5)
        // .outerShadow
        .make();
  }

  openProductDetailsPage(BuildContext context, product) {
    context.push(
      (context) => AmazonStyledCommerceProductDetailsPage(product: product),
    );
  }
}
