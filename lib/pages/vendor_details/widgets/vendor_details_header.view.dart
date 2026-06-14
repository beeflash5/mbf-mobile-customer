import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/component/custom_image.view.dart';
import 'package:fuodz/component/input/search_bar.input.dart';
import 'package:fuodz/component/tags/close.tag.dart';
import 'package:fuodz/component/tags/delivery.tag.dart';
import 'package:fuodz/component/tags/fav_vendor.tag.dart';
import 'package:fuodz/component/tags/open.tag.dart';
import 'package:fuodz/component/tags/pickup.tag.dart';
import 'package:fuodz/component/tags/time.tag.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/pages/vendor_details/widgets/bottomsheets/vendor_full_profie.bottomsheet.dart';
import 'package:fuodz/pages/vendor_details/widgets/upload_prescription.btn.dart';
import 'package:fuodz/pages/vendor_search/vendor_search.page.dart';
import 'package:fuodz/utils/app_ui_settings.dart';
import 'package:fuodz/utils/sizes.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';

class VendorDetailsHeader extends StatelessWidget {
  const VendorDetailsHeader(
    this.vendor, {
    this.showFeatureImage = true,
    this.featureImageHeight = 220,
    this.showPrescription = false,
    this.showSearch = true,
    super.key,
  });

  final Vendor vendor;
  final bool showFeatureImage;
  final double featureImageHeight;
  final bool showPrescription;
  final bool showSearch;

  void _openSearch(BuildContext context) {
    context.pushWidget(VendorSearchPage(vendor));
  }

  @override
  Widget build(BuildContext context) {
    return VStack([
      VStack([
        CustomVisibilty(
          visible: showFeatureImage,
          child: CustomImage(
            imageUrl: vendor.featureImage,
            height: featureImageHeight,
            canZoom: true,
          ).wFull(context),
        ),
        VStack([
          HStack([
            CustomImage(
              imageUrl: vendor.logo,
              width: Vx.dp56,
              height: Vx.dp56,
              canZoom: true,
            ).box.clip(Clip.antiAlias).withRounded(value: 5).make(),
            VStack([
              vendor.name.text.semiBold.lg.make(),
              CustomVisibilty(
                visible:
                    vendor.address.isNotEmptyAndNotNull &&
                    AppUISettings.showVendorAddress,
                child: "${vendor.address}".text.light.sm.maxLines(1).make(),
              ),
              Visibility(
                visible: AppUISettings.showVendorPhone,
                child: vendor.phone.text.light.sm.make(),
              ),
              HStack([
                RatingBar(
                  itemSize: 12,
                  initialRating: vendor.rating.toDouble(),
                  ignoreGestures: true,
                  ratingWidget: RatingWidget(
                    full: Icon(Icons.star, size: 12, color: Colors.yellow[800]),
                    half: Icon(
                      Icons.star_half,
                      size: 12,
                      color: Colors.yellow[800],
                    ),
                    empty: Icon(
                      Icons.star,
                      size: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  onRatingUpdate: (value) {},
                ).pOnly(right: 2),
                "(${vendor.reviews_count} ${'Reviews'.tr()})".text.sm.thin
                    .make(),
              ]).py2().onTap(() {
                context.pushRoute(
                  '/vendors/${vendor.id}/reviews',
                  extra: vendor,
                );
              }),
            ]).pOnly(left: Vx.dp12).expand(),
            HStack([
              FavVendorTag(vendor),
              Icon(
                Icons.info,
                size: 22,
                color: context.theme.primaryColor,
              ).p(Sizes.paddingSizeSmall).onTap(() {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => VendorFullProfileBottomSheet(vendor),
                );
              }),
            ], spacing: 5).pOnly(left: Vx.dp12),
          ]),
        ]).p8().card.color(Utils.systemGreyColor()).make().p12(),
      ]),
      VStack([
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            vendor.isOpen ? OpenTag() : CloseTag(),
            if (vendor.delivery == 1) DeliveryTag(),
            if (vendor.pickup == 1) PickupTag(),
            TimeTag(
              "${vendor.prepareTime} ${vendor.prepareTimeUnit}",
              iconData: Icons.access_time,
            ),
            TimeTag(
              "${vendor.deliveryTime} ${vendor.deliveryTimeUnit}",
              iconData: Icons.directions_bike,
            ),
          ],
        ),
        UiSpacer.verticalSpace(space: 10),
      ]).px20().py(0),
      UiSpacer.divider(),
      10.heightBox,
      if (showSearch)
        SearchBarInput(
          onTap: () => _openSearch(context),
          showFilter: false,
        ).px20(),
      10.heightBox,
      if (showPrescription) UploadPrescriptionFab(vendor).centered(),
      10.heightBox,
      if (showPrescription || showSearch) UiSpacer.divider(),
    ]);
  }
}
