import 'dart:ui';
import 'package:fuodz/utils/extensions/router.dart';

import 'package:flutter/material.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/sizes.dart';
import 'package:fuodz/utils/extensions/string.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/services/app_currency_system.service.dart';
import 'package:fuodz/pages/service/service_details.page.dart';
import 'package:fuodz/component/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class ServiceCard extends StatelessWidget {
  ServiceCard({super.key, required this.service});
  final Service service;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.pushWidget(ServiceDetailsPage(service));
      },
      child: Container(
        child: VStack([
          //
          Stack(
                children: [
                  //
                  Hero(
                    tag: service.id,
                    child: CustomImage(
                      imageUrl:
                          service.photos.isNotEmpty ? service.photos.first : "",
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
                                "${service.name}".text.white.bold
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
                                "${service.vendor.name}".text.white.bold
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
                                  '${AppStrings.currentCurrencySymbol} ${service.sellPrice.convertCurrency}'
                                      .currencyFormat()
                                      .text
                                      .semiBold
                                      .overflow(TextOverflow.ellipsis)
                                      .size(AppTextSizes.xs)
                                      .color(Colors.white)
                                      .make(),

                                  /// DURATION
                                  if (service.durationText.isNotEmpty)
                                    " ${service.durationText}".text
                                        .size(AppTextSizes.xs)
                                        .overflow(TextOverflow.ellipsis)
                                        .color(Colors.white)
                                        .make(),
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
              .pOnly(bottom: Vx.dp8),
        ]),
      ),
    );
  }
}
