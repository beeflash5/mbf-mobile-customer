
import 'package:flutter/material.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/component/button/route.button.dart';
import 'package:fuodz/component/custom_image.view.dart';
import 'package:fuodz/component/tags/time.tag.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class CardVendor extends StatelessWidget {
  const CardVendor({required this.vendor, required this.onPressed, Key? key})
    : super(key: key);

  final Vendor vendor;
  final Function(Vendor) onPressed;
  @override
  Widget build(BuildContext context) {
    return VStack([
          //
          Stack(
            children: [
              //
              Hero(
                tag: vendor.heroTag ?? vendor.id,
                child: CustomImage(
                  imageUrl: vendor.featureImage,
                  height: 202,
                  boxFit: BoxFit.cover,
                  width: context.screenWidth,
                ),
              ),
              //location routing
              (!vendor.latitude.isEmptyOrNull &&
                      !vendor.longitude.isEmptyOrNull)
                  ? Positioned(
                    child: RouteButton(vendor, size: 12),
                    bottom: 10,
                    right: 10,
                  )
                  : UiSpacer.emptySpace(),
              Positioned(
                top: 10,
                right: 10,
                child: Visibility(
                  visible: !vendor.isOpen,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: "Closed".tr().text.medium.white.bold.makeCentered(),
                  ),
                  // VxBox(
                  //   child: "Closed".tr().text.lg.white.bold.makeCentered(),
                  // ).color(AppColor.closeColor.withOpacity(0.6)).make(),
                ),
              ),
              //
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ClipRRect(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: const BoxDecoration(color: Colors.white),
                    child: HStack([
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                vendor.name.text.bold
                                    .size(16)
                                    .overflow(TextOverflow.ellipsis)
                                    .color(Colors.black)
                                    .make(),

                                HStack([
                                  "${vendor.rating.numCurrency} ".text
                                      .minFontSize(6)
                                      .size(14)
                                      .color(AppColor.ratingColor)
                                      .medium
                                      .make(),
                                  Icon(
                                    Icons.star,
                                    color: AppColor.ratingColor,
                                    size: 14,
                                  ),
                                ]),
                              ],
                            ),

                            1.heightBox,

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Visibility(
                                //   visible: vendor.maxOrder != null,
                                //   child:
                                //       "${vendor.maxOrder.currencyValueFormat()} "
                                //           .text
                                //           .size(14)
                                //           .color(context.primaryColor)
                                //           .medium
                                //           .maxLines(1)
                                //           .make(),
                                // ),
                                HStack([
                                  TimeTag(
                                    "${vendor.prepareTime} ${vendor.prepareTimeUnit}",
                                    iconData: Icons.access_time,
                                  ),
                                  SizedBox(width: 10),
                                  TimeTag(
                                    "${vendor.deliveryTime} ${vendor.deliveryTimeUnit}",
                                    iconData: Icons.directions_bike,
                                  ),
                                ]),

                                Wrap(
                                  spacing: Vx.dp12,
                                  children: [
                                    // HStack([
                                    //   "${vendor.rating.numCurrency} ".text
                                    //       .minFontSize(6)
                                    //       .size(14)
                                    //       .color(AppColor.ratingColor)
                                    //       .medium
                                    //       .make(),
                                    //   Icon(
                                    //     Icons.star,
                                    //     color: AppColor.ratingColor,
                                    //     size: 14,
                                    //   ),
                                    // ]),
                                    Visibility(
                                      visible: vendor.distance != null,
                                      child: HStack([
                                        Icon(
                                          Icons.directions,
                                          color: AppColor.primaryColor,
                                          size: 10,
                                        ),
                                        " ${vendor.distance?.numCurrency}km"
                                            .text
                                            .minFontSize(16)
                                            .size(10)
                                            .make(),
                                      ]),
                                    ),
                                  ],
                                ).px8(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              ),

              //closed
            ],
          ),

          //name
          // vendor.name.text
          //     .size(AppTextSizes.base)
          //     .maxLines(1)
          //     .overflow(TextOverflow.ellipsis)
          //     .make()
          //     .px8()
          //     .pOnly(top: Vx.dp8),

          //
          // //description
          // "${vendor.description}".text.gray400
          //     .minFontSize(9)
          //     .size(9)
          //     .maxLines(1)
          //     .overflow(TextOverflow.ellipsis)
          //     .make()
          //     .px8(),
          //words
          // SizedBox(height: 4),
          // Wrap(
          //   spacing: Vx.dp12,
          //   children: [
          //     //rating
          //     HStack([
          //       "${vendor.rating.numCurrency} ".text
          //           .minFontSize(6)
          //           .size(14)
          //           .color(AppColor.ratingColor)
          //           .medium
          //           .make(),
          //       Icon(
          //         Icons.star,
          //         color: AppColor.ratingColor,
          //         size: 14,
          //       ),
          //     ]),

          //     //
          //     //
          //     Visibility(
          //       visible: vendor.distance != null,
          //       child: HStack([
          //         Icon(
          //           Icons.directions,
          //           color: AppColor.primaryColor,
          //           size: 14,
          //         ),
          //         " ${vendor.distance?.numCurrency}km".text
          //             .minFontSize(16)
          //             .size(14)
          //             .make(),
          //       ]),
          //     ),
          //   ],
          // ).px8(),

          // Wrap(
          //   spacing: Vx.dp12,
          //   children: [
          //     //
          //     Visibility(
          //       visible: vendor.minOrder != null,
          //       child: CurrencyHStack([
          //         "${AppStrings.currencySymbol}".text
          //             .minFontSize(6)
          //             .size(10)
          //             .gray600
          //             .medium
          //             .maxLines(1)
          //             .make(),
          //         //
          //         Visibility(
          //           visible: vendor.minOrder != null,
          //           child:
          //               "${vendor.minOrder}".text
          //                   .minFontSize(6)
          //                   .size(10)
          //                   .gray600
          //                   .medium
          //                   .maxLines(1)
          //                   .make(),
          //         ),
          //         //
          //         Visibility(
          //           visible: vendor.minOrder != null && vendor.maxOrder != null,
          //           child:
          //               " - ".text
          //                   .minFontSize(6)
          //                   .size(10)
          //                   .gray600
          //                   .medium
          //                   .maxLines(1)
          //                   .make(),
          //         ),
          //         //
          //         Visibility(
          //           visible: vendor.maxOrder != null,
          //           child:
          //               "${vendor.maxOrder} ".text
          //                   .minFontSize(6)
          //                   .size(10)
          //                   .gray600
          //                   .medium
          //                   .maxLines(1)
          //                   .make(),
          //         ),
          //       ]),
          //     ),
          //   ],
          // ).px8(),

          //
          // HStack([
          //   //can deliver
          //   vendor.delivery == 1
          //       ? DeliveryTag().pOnly(right: 10)
          //       : UiSpacer.emptySpace(),

          //   //can pickup
          //   vendor.pickup == 1
          //       ? PickupTag().pOnly(right: 10)
          //       : UiSpacer.emptySpace(),
          // ], crossAlignment: CrossAxisAlignment.end).p8(),
        ])
        .onInkTap(() => this.onPressed(this.vendor))
        // .w(175)
        .box
        .outerShadow
        .color(context.theme.colorScheme.surface)
        .clip(Clip.antiAlias)
        .withRounded(value: 10)
        .make()
        .pOnly(bottom: Vx.dp24);
  }
}
