import 'package:flutter/material.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/view_models/vendor/banners.vm.dart';
import 'package:fuodz/widgets/list_items/banner.list_item.dart';
import 'package:fuodz/widgets/states/loading.shimmer.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:carousel_slider/carousel_slider.dart';

class BannerTops extends StatelessWidget {
  const BannerTops(
    this.vendorType, {
    this.viewportFraction = 0.92,
    this.showIndicators = false,
    this.featured = false,
    this.disableCenter = false,
    this.padding = 12,
    this.itemRadius = 20,
    Key? key,
  }) : super(key: key);

  final VendorType? vendorType;
  final double viewportFraction;
  final bool showIndicators;
  final bool featured;
  final bool disableCenter;
  final double padding;
  final double? itemRadius;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<BannersViewModel>.reactive(
      viewModelBuilder:
          () => BannersViewModel(context, vendorType, featured: featured),

      onViewModelReady: (model) => model.initialise(),

      builder: (context, model, child) {
        return model.isBusy
            ? LoadingShimmer().px20().h(180)
            : Visibility(
              visible: model.banners.isNotEmpty,

              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),

                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 180,
                    viewportFraction: viewportFraction,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    enlargeStrategy: CenterPageEnlargeStrategy.height,
                    autoPlayCurve: Curves.easeInOut,
                    disableCenter: disableCenter,

                    onPageChanged: (index, reason) {
                      model.currentIndex = index;
                      model.notifyListeners();
                    },
                  ),

                  items:
                      model.banners.map((banner) {
                        return GestureDetector(
                          onTap: () => model.bannerSelected(banner),

                          child: Container(
                            width: double.infinity,

                            // decoration: BoxDecoration(
                            //   borderRadius: BorderRadius.circular(
                            //     itemRadius ?? 20,
                            //   ),

                            //   boxShadow: [
                            //     BoxShadow(
                            //       blurRadius: 18,
                            //       spreadRadius: 0,
                            //       offset: Offset(0, 10),
                            //       color: Colors.black.withOpacity(0.12),
                            //     ),
                            //   ],
                            // ),

                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                itemRadius ?? 20,
                              ),

                              child: Stack(
                                fit: StackFit.expand,

                                children: [
                                  // IMAGE
                                  BannerListItem(
                                    radius: itemRadius ?? 20,
                                    imageUrl: banner.imageUrl ?? "",
                                    onPressed:
                                        () => model.bannerSelected(banner),
                                  ),

                                  // DARK OVERLAY
                                  Positioned.fill(
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
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

                                  // CONTENT
                                  Positioned(
                                    left: 20,
                                    right: 20,
                                    bottom: 20,

                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                      children: [
                                        Text(
                                          "Travel Like a Local in Bali",

                                          maxLines: 2,

                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                            height: 1.2,
                                          ),
                                        ),

                                        SizedBox(height: 8),

                                        Text(
                                          "Discover authentic experiences, book directly with locals.",

                                          maxLines: 2,

                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.92,
                                            ),
                                            fontSize: 13,
                                            height: 1.5,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),

                                        SizedBox(height: 16),

                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 18,
                                            vertical: 12,
                                          ),

                                          decoration: BoxDecoration(
                                            color: context.primaryColor,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),

                                          child: Text(
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
      },
    );
  }
}
