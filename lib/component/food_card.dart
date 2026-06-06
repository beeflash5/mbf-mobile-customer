import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/sizes.dart';
import 'package:fuodz/utils/extensions/string.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/services/app_currency_system.service.dart';

import 'package:fuodz/component/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class FoodCard extends StatelessWidget {
  FoodCard({super.key, required this.product, this.onTap});
  final Product product;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        child: VStack([
          //
          Stack(
                children: [
                  //
                  Hero(
                    tag: product.id,
                    child: CustomImage(
                      imageUrl:
                          product.photos.isNotEmpty ? product.photos.first : "",
                      height: 180,
                      boxFit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width,
                    ),
                  ),

                  //
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        // bottomLeft: Radius.circular(16),
                        // bottomRight: Radius.circular(16),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.0),
                                Colors.black.withOpacity(0.05),
                              ],
                            ),
                          ),
                          child: Row(
                            children: [
                              VStack([
                                "${product.name}".text.white.bold
                                    .size(14)
                                    .overflow(TextOverflow.ellipsis)
                                    .textStyle(
                                      const TextStyle(
                                        shadows: [
                                          Shadow(
                                            offset: Offset(0, 1),
                                            blurRadius: 2,
                                            color: Colors.black54,
                                          ),
                                        ],
                                      ),
                                    )
                                    .make(),

                                1.heightBox,
                                "${product.vendor.name}".text.white.bold
                                    .size(14)
                                    .overflow(TextOverflow.ellipsis)
                                    .textStyle(
                                      const TextStyle(
                                        shadows: [
                                          Shadow(
                                            offset: Offset(0, 1),
                                            blurRadius: 2,
                                            color: Colors.black54,
                                          ),
                                        ],
                                      ),
                                    )
                                    .make(),
                              ]),
                              Spacer(),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// PRICE
                                  '${AppStrings.currentCurrencySymbol} ${product.sellPrice.convertCurrency}'
                                      .currencyFormat()
                                      .text
                                      .semiBold
                                      .overflow(TextOverflow.ellipsis)
                                      .size(AppTextSizes.xs)
                                      .color(Colors.white)
                                      .make(),

                                  /// DURATION
                                  // if (product.durationText.isNotEmpty)
                                  //   " ${product.durationText}".text
                                  //       .size(AppTextSizes.xs)
                                  //       .overflow(TextOverflow.ellipsis)
                                  //       .color(Colors.white)
                                  //       .make(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
              // .w(260)
              .box
              .outerShadow
              .color(context.theme.colorScheme.surface)
              .clip(Clip.antiAlias)
              .withRounded(value: 10)
              .make()
              .pOnly(bottom: Vx.dp16),
        ]),
      ),
    );
  }
}
