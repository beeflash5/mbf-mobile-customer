import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/app_images.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/extensions/dynamic.dart';
import 'package:fuodz/extensions/string.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/services/app_currency_system.service.dart';
import 'package:fuodz/services/navigation.service.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/widgets/buttons/custom_steppr.view.dart';
import 'package:fuodz/widgets/cards/custom.visibility.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:fuodz/widgets/inputs/drop_down.input.dart';
import 'package:fuodz/widgets/states/product_stock.dart';
import 'package:fuodz/widgets/tags/discount.positioned.dart';
import 'package:fuodz/widgets/tags/fav.positioned.dart';
import 'package:fuodz/widgets/tags/product_tags.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class HomeServicesListItem extends StatefulWidget {
  const HomeServicesListItem({
    required this.service,
    required this.onPressed,
    // required this.qtyUpdated,
    this.showStepper = false,
    this.height,
    this.width,
    Key? key,
  }) : super(key: key);

  final Function(Service) onPressed;
  // final Function(Service, int) qtyUpdated;
  final Service service;
  final bool showStepper;
  final double? height;
  final double? width;

  @override
  State<HomeServicesListItem> createState() => _HomeServicesListItemState();
}

class _HomeServicesListItemState extends State<HomeServicesListItem> {
  @override
  Widget build(BuildContext context) {
    final Service service = widget.service;

    Widget _buildServiceFeatures() {
      Widget _buildFeatureChip(IconData icon, String label) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 8, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (widget.service.location)
              _buildFeatureChip(Icons.location_on, 'On-site Service'.tr()),

            if (widget.service.isActive == 1)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: _buildFeatureChip(
                  Icons.check_circle,
                  'Active Service'.tr(),
                ),
              ),

            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _buildFeatureChip(Icons.schedule, 'Fixed Duration'.tr()),
            ),

            if (!widget.service.ageRestricted)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: _buildFeatureChip(
                  Icons.family_restroom,
                  'All Ages'.tr(),
                ),
              ),
          ],
        ),
      );
    }

    return Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Sizes.radiusSmall),
                  child:
                      service.photos.length > 0
                          ? CustomImage(
                            imageUrl: service.photos.first,
                            width: 120,
                            height: 120,
                            boxFit: BoxFit.cover,
                          )
                          : Image.asset(
                            AppImages.noImage,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                ),
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(10),
                    ),

                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        SizedBox(width: 4),
                        Text(
                          "${service.vendor.rating}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(width: 6),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                service.name.text
                    .maxLines(1)
                    .ellipsis
                    .semiBold
                    .size(AppTextSizes.base)
                    .make(),
                Text(
                  '%s'.tr().fill([service.vendor.name]),
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                SizedBox(height: 6),
                ((service.hasOptions ? "From".tr() : "") +
                        "" +
                        "${AppStrings.currentCurrencySymbol} ${service.sellPrice.convertCurrency}"
                            .currencyFormat() +
                        " ${service.durationText}")
                    .text
                    .size(AppTextSizes.base)
                    .align(TextAlign.end)
                    .make(),

                Spacer(),

                _buildServiceFeatures(),
              ],
            ).p(10).expand(),
          ],
        )
        .h(120)
        .onInkTap(() => this.widget.onPressed(this.widget.service))
        .material(color: context.theme.colorScheme.surface)
        .box
        .roundedSM
        .color(context.theme.colorScheme.surface)
        .clip(Clip.antiAlias)
        // .outerShadowSm
        .makeCentered()
        .w(widget.width ?? context.percentWidth * 100);

    return VStack([
          ClipRRect(
            borderRadius: BorderRadius.circular(Sizes.radiusSmall),
            child: CustomImage(
              imageUrl: service.photos.first,
              width: double.infinity,
              height: 80,
              boxFit: BoxFit.cover,
            ),
          ),
          //
          VStack([
            ClipRRect(
              borderRadius: BorderRadius.circular(Sizes.radiusSmall),
              child: CustomImage(
                imageUrl: service.photos.first,
                width: double.infinity,
                height: 80,
                boxFit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 12),
            service.name.text
                .maxLines(2)
                .ellipsis
                .semiBold
                .size(AppTextSizes.sm)
                .make(),
            service.description.text
                .maxLines(2)
                .ellipsis
                .semiBold
                .size(AppTextSizes.sm)
                .make(),

            SizedBox(height: 4),
            Text(
              '%s'.tr().fill([service.vendor.name]),
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            // Spacer(),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 14),
                SizedBox(width: 4),
                Text(
                  "${service.vendor.rating}",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                Spacer(),
                Text(
                  "${AppStrings.currentCurrencySymbol} ${service.sellPrice.convertCurrency}"
                      .currencyFormat(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ]).p8().expand(),
        ])
        .h(200)
        // .onInkTap(() => this.widget.onPressed(this.widget.product))
        .material(color: context.theme.colorScheme.surface)
        .box
        .roundedSM
        .color(context.theme.colorScheme.surface)
        .clip(Clip.antiAlias)
        .outerShadowSm
        .makeCentered()
        .w(widget.width ?? context.percentWidth * 100);
    // .w( context.percentWidth * 40);
  }

  //
  // void updateProductQty({int value = 1}) {
  //   bool required = widget.product.optionGroupRequirementCheck();
  //   if (!required) {
  //     //add to cart/update cart
  //     widget.qtyUpdated(widget.product, value);
  //     //
  //     setState(() {
  //       widget.product.selectedQty = value;
  //     });
  //   } else {
  //     //open the product details page
  //     widget.onPressed(widget.product);
  //   }
  // }
}
