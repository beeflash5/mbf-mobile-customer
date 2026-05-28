import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fuodz/models/destination.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/views/pages/service/service_details.page.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class TrendingDestinations extends StatefulWidget {
  final List<Destination> destinations;

  const TrendingDestinations({super.key, required this.destinations});

  @override
  State<TrendingDestinations> createState() => _TrendingDestinationsState();
}

class _TrendingDestinationsState extends State<TrendingDestinations> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Destination selectedDestination = widget.destinations[selectedIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// TITLE
        const Text(
          "Trending Destinations",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ).px(16),

        const SizedBox(height: 4),

        const Text(
          "Popular Destinations To Kickstart Your Planning",
          style: TextStyle(color: Colors.grey),
        ).px(16),

        const SizedBox(height: 16),

        /// DESTINATION TAB
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.destinations.length,
            itemBuilder: (context, index) {
              bool isSelected = selectedIndex == index;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(right: 10, left: index == 0 ? 16 : 0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? context.primaryColor
                            : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.destinations[index].name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 20),
        selectedDestination.services.length > 0
            ?
            /// SERVICE CARD LIST
            SizedBox(
              height: 210,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: selectedDestination.services.length,
                itemBuilder: (context, index) {
                  Service service = selectedDestination.services[index];

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ServiceDetailsPage(service),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                        left: index == 0 ? 16 : 0,
                        right: 16,
                      ),

                      child: VStack([
                        //
                        Stack(
                              children: [
                                //
                                Hero(
                                  tag: service.id,
                                  child: CustomImage(
                                    imageUrl:
                                        service.photos.isNotEmpty
                                            ? service.photos.first
                                            : "",
                                    height: 202,
                                    boxFit: BoxFit.cover,
                                    width: context.screenWidth,
                                  ),
                                ),
                                //location routing
                                // (!vendor.latitude.isEmptyOrNull &&
                                //         !vendor.longitude.isEmptyOrNull)
                                //     ? Positioned(
                                //       child: RouteButton(vendor, size: 12),
                                //       bottom: 10,
                                //       right: 10,
                                //     )
                                //     : UiSpacer.emptySpace(),

                                //
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      // bottomLeft: Radius.circular(16),
                                      // bottomRight: Radius.circular(16),
                                    ),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 15,
                                        sigmaY: 15,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.black.withOpacity(0.0),
                                              Colors.black.withOpacity(0.05),
                                            ],
                                          ),
                                        ),
                                        child: VStack([
                                          "${selectedDestination.name}, ${selectedDestination.province}"
                                              .text
                                              .white
                                              .bold
                                              .size(16)
                                              .overflow(TextOverflow.ellipsis)
                                              .textStyle(
                                                const TextStyle(
                                                  shadows: [
                                                    Shadow(
                                                      offset: Offset(0, 1),
                                                      blurRadius: 2,
                                                      color: Colors.black54,
                                                    ),
                                                  ],
                                                ),
                                              )
                                              .make(),
                                          1.heightBox,
                                          "${service.name}".text.white.bold
                                              .size(16)
                                              .overflow(TextOverflow.ellipsis)
                                              .textStyle(
                                                const TextStyle(
                                                  shadows: [
                                                    Shadow(
                                                      offset: Offset(0, 1),
                                                      blurRadius: 2,
                                                      color: Colors.black54,
                                                    ),
                                                  ],
                                                ),
                                              )
                                              .make(),
                                        ]),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                            .w(260)
                            .box
                            .outerShadow
                            .color(context.theme.colorScheme.surface)
                            .clip(Clip.antiAlias)
                            .withRounded(value: 10)
                            .make()
                            .pOnly(bottom: Vx.dp8),
                      ]),
                    ),
                  );
                  // .w(175)
                },
              ),
            )
            : SizedBox(),
      ],
    );
  }
}
