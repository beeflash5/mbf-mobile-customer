import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/busy_indicator.dart';
import 'package:fuodz/component/list/banner.list_item.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/providers/vendor_lists_providers.dart';
import 'package:fuodz/services/banner.helper.dart';

class SimpleStyledBanners extends ConsumerWidget {
  const SimpleStyledBanners(
    this.vendorType, {
    this.height,
    this.radius,
    this.withPadding = true,
    this.hideEmpty = false,
    this.viewportFraction = 1,
    super.key,
  });

  final VendorType vendorType;
  final double? height;
  final double? radius;
  final bool withPadding;
  final double viewportFraction;
  final bool hideEmpty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = (vendorTypeId: vendorType.id, featured: false);
    final asyncBanners = ref.watch(bannersControllerProvider(args));
    final banners = asyncBanners.valueOrNull ?? const [];
    final isLoading = asyncBanners.isLoading;

    if (hideEmpty && banners.isEmpty && !isLoading) {
      return const SizedBox.shrink();
    }

    if (isLoading) return BusyIndicator().centered().h(150);

    return Padding(
      padding: withPadding
          ? const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
          : EdgeInsets.zero,
      child: CarouselSlider(
        options: CarouselOptions(
          autoPlay: true,
          initialPage: 1,
          height: banners.isNotEmpty ? (height ?? 250.0) : 0.0,
          disableCenter: true,
          enlargeCenterPage: true,
          viewportFraction: viewportFraction,
        ),
        items: banners
            .map(
              (banner) => BannerListItem(
                imageUrl: banner.imageUrl ?? '',
                radius: radius ?? 7.5,
                noMargin: true,
                onPressed: () => BannerHelper.bannerSelected(context, banner),
              ),
            )
            .toList(),
      ).box.clip(Clip.antiAlias).withRounded(value: radius ?? 7.5).make(),
    );
  }
}
