import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/list/banner.list_item.dart';
import 'package:fuodz/component/states/loading.shimmer.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/providers/vendor_lists_providers.dart';
import 'package:fuodz/services/banner.helper.dart';

class AdsBottom extends ConsumerStatefulWidget {
  const AdsBottom(
    this.vendorType, {
    this.viewportFraction = 0.8,
    this.showIndicators = false,
    this.featured = false,
    this.disableCenter = false,
    this.padding = 5,
    this.itemRadius = 10,
    this.height = 120,
    super.key,
  });

  final VendorType? vendorType;
  final double viewportFraction;
  final bool showIndicators;
  final bool featured;
  final bool disableCenter;
  final double padding;
  final double? itemRadius;
  final double? height;

  @override
  ConsumerState<AdsBottom> createState() => _AdsBottomState();
}

class _AdsBottomState extends ConsumerState<AdsBottom> {
  @override
  Widget build(BuildContext context) {
    final args = (vendorTypeId: widget.vendorType?.id ?? 0, slot: 2);
    final asyncAds = ref.watch(adsControllerProvider(args));
    final ads = asyncAds.valueOrNull ?? const [];

    if (asyncAds.isLoading) return LoadingShimmer().px20().h(150);

    return Visibility(
      visible: ads.isNotEmpty,
      child: Padding(
        padding: EdgeInsets.all(widget.padding),
        child: CarouselSlider(
          options: CarouselOptions(
            autoPlayCurve: Curves.easeInOutBack,
            clipBehavior: Clip.antiAlias,
            viewportFraction: widget.viewportFraction,
            autoPlay: true,
            initialPage: 1,
            height: widget.height,
            disableCenter: widget.disableCenter,
          ),
          items: ads
              .map(
                (banner) => BannerListItem(
                  radius: widget.itemRadius ?? 0.0,
                  imageUrl: banner.imageUrl ?? '',
                  onPressed: () =>
                      BannerHelper.bannerSelected(context, banner),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
