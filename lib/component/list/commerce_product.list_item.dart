import 'package:flutter/material.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/extensions/string.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/services/app_currency_system.service.dart';
import 'package:fuodz/pages/product/amazon_styled_commerce_product_details.page.dart';
// import 'package:fuodz/pages/product/commerce_product_details.page.dart';
import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/component/currency_hstack.dart';
import 'package:fuodz/component/custom_image.view.dart';
import 'package:fuodz/component/tags/fav.positioned.dart';
import 'package:fuodz/component/tags/product_tags.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:fuodz/utils/extensions/context.dart';

class CommerceProductListItem extends StatelessWidget {
  const CommerceProductListItem(
    this.product, {
    this.height,
    this.boxFit,
    Key? key,
  }) : super(key: key);

  final Product product;
  final double? height;
  final BoxFit? boxFit;

  @override
  Widget build(BuildContext context) {
    return VStack([
          //image and fav icon
          Stack(
            children: [
              //prouct first image
              CustomImage(
                imageUrl: "${product.photo}",
                width: double.infinity,
                height: height,
                boxFit: boxFit ?? BoxFit.contain,
              ).box.slate100.withRounded(value: 5).clip(Clip.antiAlias).make(),

              //fav icon
              FavPositiedView(product),
            ],
          ),

          //details
          6.heightBox,
          VStack([
            //name
            "${product.name}".text.medium
                .size(14)
                // .maxLines(2)
                .minFontSize(14)
                .maxFontSize(14)
                .ellipsis
                .make(),

            // "${product.vendor.name}".text.make(),

            // price
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                //price
                CurrencyHStack([
                  AppStrings.currentCurrencySymbol.text.base.semiBold.make(),
                  product.sellPrice.convertCurrency
                      .currencyValueFormat()
                      .text
                      .base
                      .bold
                      .make(),
                ], crossAlignment: CrossAxisAlignment.end),
                //discount
                CustomVisibilty(
                  visible: product.showDiscount,
                  child:
                      CurrencyHStack([
                        AppStrings.currentCurrencySymbol.text.lineThrough.xs
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
          ]).px8(),

          //
          ProductTags(product),
          10.heightBox,
        ])
        .onInkTap(() => openProductDetailsPage(context, product))
        .material(color: context.theme.colorScheme.surface)
        .box
        .clip(Clip.antiAlias)
        // .border(
        //   color: context.theme.colorScheme.surface,
        //   width: 2,
        // )
        .color(context.theme.colorScheme.surface)
        .withRounded(value: 5)
        .outerShadow
        .make();
  }

  openProductDetailsPage(BuildContext context, product) {
    context.push(
      (context) => AmazonStyledCommerceProductDetailsPage(product: product),
    );
  }
}
