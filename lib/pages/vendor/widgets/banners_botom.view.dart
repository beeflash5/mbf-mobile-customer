import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/component/list/banner.list_item.dart';
import 'package:fuodz/component/states/loading.shimmer.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/providers/vendor_lists_providers.dart';
import 'package:fuodz/services/banner.helper.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/utils.dart';

class BannerBottom extends ConsumerStatefulWidget {
  const BannerBottom(
    this.vendorType, {
    this.viewportFraction = 0.8,
    this.showIndicators = false,
    this.featured = false,
    this.disableCenter = false,
    this.padding = 5,
    this.itemRadius = 10,
    super.key,
  });

  final VendorType? vendorType;
  final double viewportFraction;
  final bool showIndicators;
  final bool featured;
  final bool disableCenter;
  final double padding;
  final double? itemRadius;

  @override
  ConsumerState<BannerBottom> createState() => _BannerBottomState();
}

class _BannerBottomState extends ConsumerState<BannerBottom> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final args = (
      vendorTypeId: widget.vendorType?.id ?? 0,
      featured: widget.featured,
    );
    final asyncBanners = ref.watch(bannersControllerProvider(args));
    final banners = asyncBanners.valueOrNull ?? const [];

    if (asyncBanners.isLoading) return LoadingShimmer().px20().h(150);

    return Visibility(
      visible: banners.isNotEmpty,
      child: Padding(
        padding: EdgeInsets.all(widget.padding),
        child: VStack([
          CarouselSlider(
            options: CarouselOptions(
              autoPlayCurve: Curves.easeInOutBack,
              clipBehavior: Clip.antiAlias,
              viewportFraction: widget.viewportFraction,
              autoPlay: true,
              initialPage: 1,
              height: banners.isNotEmpty ? AppStrings.bannerHeight : 0.0,
              disableCenter: widget.disableCenter,
              onPageChanged:
                  (index, reason) => setState(() => _currentIndex = index),
            ),
            items:
                banners
                    .map(
                      (banner) => BannerListItem(
                        radius: widget.itemRadius ?? 0.0,
                        imageUrl: banner.imageUrl ?? '',
                        onPressed:
                            () => BannerHelper.bannerSelected(context, banner),
                      ),
                    )
                    .toList(),
          ),
          CustomVisibilty(
            visible: banners.length <= 10 || widget.showIndicators,
            child:
                AnimatedSmoothIndicator(
                  activeIndex: _currentIndex,
                  count: banners.length,
                  textDirection:
                      Utils.isArabic ? TextDirection.rtl : TextDirection.ltr,
                  effect: ExpandingDotsEffect(
                    dotHeight: 6,
                    dotWidth: 10,
                    activeDotColor: context.primaryColor,
                  ),
                ).centered().py8(),
          ),
        ]),
      ),
    );
  }
}
