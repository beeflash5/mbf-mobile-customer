import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/extensions/string.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/services/app_currency_system.service.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/widgets/buttons/custom_steppr.view.dart';
import 'package:fuodz/widgets/cards/custom.visibility.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:fuodz/widgets/inputs/drop_down.input.dart';
import 'package:fuodz/widgets/states/product_stock.dart';
import 'package:fuodz/widgets/tags/discount.positioned.dart';
import 'package:fuodz/widgets/tags/fav.positioned.dart';
import 'package:fuodz/widgets/tags/product_tags.dart';
import 'package:velocity_x/velocity_x.dart';

class HomeProductListItem extends StatefulWidget {
  const HomeProductListItem({
    required this.product,
    required this.onPressed,
    required this.qtyUpdated,
    this.showStepper = false,
    this.height,
    this.width,
    Key? key,
  }) : super(key: key);

  final Function(Product) onPressed;
  final Function(Product, int) qtyUpdated;
  final Product product;
  final bool showStepper;
  final double? height;
  final double? width;

  @override
  State<HomeProductListItem> createState() => _HomeProductListItemState();
}

class _HomeProductListItemState extends State<HomeProductListItem> {
  @override
  Widget build(BuildContext context) {
    return VStack([
          //
          //product image
          Stack(
            children: [
              //
              Hero(
                tag: widget.product.heroTag ?? widget.product.id,
                child: CustomImage(
                  imageUrl: widget.product.photo,
                  boxFit: BoxFit.contain,
                  width: double.infinity,
                  height: Vx.dp64 * 1.25,
                ),
              ),
              //
              //discount tag
              DiscountPositiedView(widget.product),

              //fav icon
              FavPositiedView(widget.product),
            ],
          ),

          //
          VStack([
            "${widget.product.name}".text.light
                .size(14)
                .minFontSize(12)
                .maxFontSize(14)
                .maxLines(widget.product.showDiscount ? 1 : 2)
                .overflow(TextOverflow.ellipsis)
                .make()
                .expand(),

            //discounted price
            CustomVisibilty(
              visible: widget.product.showDiscount,
              child:
                  "${AppStrings.currencySymbol} ${widget.product.price}"
                      .currencyFormat()
                      .text
                      .lineThrough
                      .xs
                      .semiBold
                      .make(),
            ),
            //options
            CustomVisibilty(
              visible:
                  widget.showStepper && widget.product.optionGroups.isNotEmpty,
              child: DropdownInput(
                options:
                    widget.product.optionGroups.isNotEmpty
                        ? widget.product.optionGroups[0].options
                        : [],
                onChanged: (option) {
                  widget.product.selectedOptions = [option];
                },
              ).pOnly(top: Vx.dp4),
            ),
          ]).p8().expand(),

          VStack([
            //
            CustomVisibilty(
              visible: widget.product.hasStock,
              child:
                  HStack([
                    //price
                    "${AppStrings.currentCurrencySymbol} ${widget.product.sellPrice.convertCurrency}"
                        .currencyFormat()
                        .text
                        .base
                        .bold
                        .make()
                        .expand(),
                    UiSpacer.smHorizontalSpace(),
                  ]).p8(),
            ),

            //no stock indicator
            CustomVisibilty(
              visible: !widget.product.hasStock,
              child: ProductStockState(widget.product),
            ),
          ]).box.make().p2(),

          //
          ProductTags(widget.product),
        ])
        .h(
          widget.height != null
              ? widget.height!
              : widget.product.optionGroups.isNotEmpty
              ? 220
              : 180,
        )
        .onInkTap(() => this.widget.onPressed(this.widget.product))
        .material(color: context.theme.colorScheme.surface)
          .box
        .outerShadow
        .color(context.theme.colorScheme.surface)
        .clip(Clip.antiAlias)
        .withRounded(value: 5)
        .makeCentered()
        .w(widget.width ?? context.percentWidth * 100);
  }
}
