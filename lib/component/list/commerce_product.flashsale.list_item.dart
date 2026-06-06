import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/extensions/string.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/services/app_currency_system.service.dart';
import 'package:fuodz/pages/product/amazon_styled_commerce_product_details.page.dart';
import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/component/currency_hstack.dart';
import 'package:fuodz/component/custom_image.view.dart';
import 'package:fuodz/component/tags/product_tags.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:fuodz/utils/extensions/context.dart';

class CommerceProductListItemFlashSale extends StatefulWidget {
  const CommerceProductListItemFlashSale(
    this.product, {
    this.height,
    this.boxFit,
    Key? key,
  }) : super(key: key);

  final Product product;
  final double? height;
  final BoxFit? boxFit;

  @override
  State<CommerceProductListItemFlashSale> createState() =>
      _CommerceProductListItemFlashSaleState();
}

class _CommerceProductListItemFlashSaleState
    extends State<CommerceProductListItemFlashSale> {
  late DateTime endTime;
  Timer? timer;
  @override
  void initState() {
    super.initState();

    /// 🔥 SAFE PARSE (anti null + anti error)
    final expiresAt = widget.product.expires_at;

    if (expiresAt != null && expiresAt.toString().isNotEmpty) {
      endTime =
          DateTime.tryParse(expiresAt.toString()) ??
          DateTime.now().add(const Duration(hours: 1));
    } else {
      /// fallback kalau null → kasih 1 jam
      endTime = DateTime.now().add(const Duration(hours: 1));
    }

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Duration get remaining {
    final diff = endTime.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  String format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}";
  }

  @override
  Widget build(BuildContext context) {
    final time = remaining;

    return VStack([
          /// IMAGE
          Stack(
            children: [
              CustomImage(
                imageUrl: "${widget.product.photo}",
                width: double.infinity,
                height: 100,
                boxFit: widget.boxFit ?? BoxFit.contain,
              ),

              Positioned(
                top: 0,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    time.inSeconds == 0 ? "Ended" : format(time),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          /// DETAILS
          6.heightBox,

          VStack([
            /// NAME
            "${widget.product.name}".text.medium
                .size(14)
                .minFontSize(14)
                .maxFontSize(14)
                .ellipsis
                .make(),

            /// PRICE
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                CurrencyHStack([
                  AppStrings.currentCurrencySymbol.text.base.semiBold.make(),
                  widget.product.sellPrice.convertCurrency
                      .currencyValueFormat()
                      .text
                      .base
                      .bold
                      .make(),
                ], crossAlignment: CrossAxisAlignment.end),

                CustomVisibilty(
                  visible: widget.product.showDiscount,
                  child:
                      CurrencyHStack([
                        AppStrings.currentCurrencySymbol.text.lineThrough.xs
                            .make(),
                        widget.product.price.convertCurrency
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

          6.heightBox,

          /// 🔥 COUNTDOWN TOP RIGHT

          /// TAGS
          ProductTags(widget.product),

          10.heightBox,
        ])
        .onInkTap(() => openProductDetailsPage(context, widget.product))
        .material(color: context.theme.colorScheme.surface)
        .box
        .clip(Clip.antiAlias)
        .px12
        .py16
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
