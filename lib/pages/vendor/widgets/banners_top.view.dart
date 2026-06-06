import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/list/banner.list_item.dart';
import 'package:fuodz/component/states/loading.shimmer.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/providers/vendor_lists_providers.dart';
import 'package:fuodz/services/banner.helper.dart';

class BannerTops extends ConsumerStatefulWidget {
  const BannerTops(
    this.vendorType, {
    this.viewportFraction = 0.92,
    this.showIndicators = false,
    this.featured = false,
    this.disableCenter = false,
    this.padding = 12,
    this.itemRadius = 20,
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
  ConsumerState<BannerTops> createState() => _BannerTopsState();
}

class _BannerTopsState extends ConsumerState<BannerTops> {

  @override
  Widget build(BuildContext context) {
    final args = (
      vendorTypeId: widget.vendorType?.id ?? 0,
      featured: widget.featured,
    );
    final asyncBanners = ref.watch(bannersControllerProvider(args));
    final banners = asyncBanners.valueOrNull ?? const [];

    if (asyncBanners.isLoading) return LoadingShimmer().px20().h(180);

    return Visibility(
      visible: banners.isNotEmpty,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: widget.padding),
        child: CarouselSlider(
          options: CarouselOptions(
            height: 180,
            viewportFraction: widget.viewportFraction,
            autoPlay: true,
            enlargeCenterPage: true,
            enlargeStrategy: CenterPageEnlargeStrategy.height,
            autoPlayCurve: Curves.easeInOut,
            disableCenter: widget.disableCenter,
          ),
          items: banners.map((banner) {
            return GestureDetector(
              onTap: () => BannerHelper.bannerSelected(context, banner),
              child: SizedBox(
                width: double.infinity,
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(widget.itemRadius ?? 20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      BannerListItem(
                        radius: widget.itemRadius ?? 20,
                        imageUrl: banner.imageUrl ?? '',
                        onPressed: () =>
                            BannerHelper.bannerSelected(context, banner),
                      ),
                      Positioned.fill(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.black.withOpacity(0.80),
                                Colors.black.withOpacity(0.60),
                                Colors.black.withOpacity(0.40),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Travel Like a Local in Bali",
                              maxLines: 2,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Discover authentic experiences, book directly with locals.",
                              maxLines: 2,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.92),
                                fontSize: 13,
                                height: 1.5,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: context.primaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "Explore Experiences",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
