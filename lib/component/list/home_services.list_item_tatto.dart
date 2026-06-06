import 'package:flutter/material.dart';
import 'package:fuodz/utils/app_images.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/extensions/string.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/services/app_currency_system.service.dart';
import 'package:fuodz/component/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class HomeServicesListItemTatto extends StatefulWidget {
  const HomeServicesListItemTatto({
    required this.service,
    required this.onPressed,
    this.showStepper = false,
    this.height,
    this.width,
    this.title,
    Key? key,
  }) : super(key: key);

  final Function(Service) onPressed;
  final Service service;
  final bool showStepper;
  final double? height;
  final double? width;
  final String? title;

  @override
  State<HomeServicesListItemTatto> createState() =>
      _HomeServicesListItemTattoState();
}

class _HomeServicesListItemTattoState
    extends State<HomeServicesListItemTatto> {
  @override
  Widget build(BuildContext context) {
    final Service service = widget.service;

    return Container(
      width: widget.width ?? 185,
      height: widget.height ?? 360,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          /// IMAGE PORTRAIT STATIC
          Stack(
            children: [
              SizedBox(
                height: 230,
                width: double.infinity,
                child: service.photos.isNotEmpty
                    ? CustomImage(
                        imageUrl:
                            service.photos.first,
                        width: double.infinity,
                        boxFit: BoxFit.cover,
                      )
                    : Image.asset(
                        AppImages.noImage,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),

              /// TOP LABEL
              if (widget.title != null)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration:
                        const BoxDecoration(
                      color: Color(0xFFECC85C),
                      borderRadius:
                          BorderRadius.only(
                        bottomRight:
                            Radius.circular(14),
                      ),
                    ),
                    child: Text(
                      widget.title ?? "",
                      style:
                          const TextStyle(
                        fontSize: 10,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Colors.black87,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          /// CONTENT
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                12,
                10,
                12,
                12,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  /// RATING
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color:
                            Color(0xffEEC860),
                        size: 14,
                      ),

                      const SizedBox(
                          width: 3),

                      Text(
                        "${service.vendor.rating}",
                        style:
                            const TextStyle(
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w700,
                          color:
                              Colors.black87,
                        ),
                      ),

                      Expanded(
                        child: Text(
                          " (${service.vendor.reviews_count} reviews)",
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              const TextStyle(
                            fontSize: 12,
                            color:
                                Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                      height: 10),

                  /// TITLE
                  Text(
                    service.name,
                    maxLines: 1,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w700,
                      height: 1.3,
                      color:
                          Colors.black,
                    ),
                  ),

                  const SizedBox(
                      height: 6),

                  /// PARTNER
                  Text(
                    service.vendor.name,
                    maxLines: 1,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        const TextStyle(
                      fontSize: 13,
                      color:
                          Colors.grey,
                    ),
                  ),

                  const Spacer(),

                  /// PRICE
                  Text(
                    "${AppStrings.currentCurrencySymbol} ${service.sellPrice.convertCurrency}"
                        .currencyFormat(),
                    maxLines: 1,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        const TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Color(0xFF1B8A9E),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).onInkTap(() {
      widget.onPressed(widget.service);
    });
  }
}