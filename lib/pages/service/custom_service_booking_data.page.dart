import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/CategoriestabsBooking.dart';
import 'package:fuodz/component/button/custom_button_light.dart';
import 'package:fuodz/component/card_vendor.dart';
import 'package:fuodz/component/list/home_services.list_item.dart';
import 'package:fuodz/component/list/home_services.list_item_tatto.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/pages/service/service_details.page.dart';
import 'package:fuodz/providers/service_providers.dart';
import 'package:fuodz/services/navigation.service.dart';
import 'package:fuodz/utils/sizes.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:fuodz/pages/vendor/widgets/ads_bottom.view.dart';

class ServicesBookingPage extends ConsumerStatefulWidget {
  const ServicesBookingPage(this.vendorType, {super.key});

  final VendorType vendorType;

  @override
  ConsumerState<ServicesBookingPage> createState() =>
      _ServicesBookingPageState();
}

class _ServicesBookingPageState
    extends ConsumerState<ServicesBookingPage> {
  @override
  Widget build(BuildContext context) {
    final asyncHome =
        ref.watch(serviceHomeControllerProvider(widget.vendorType.id));
    final state = asyncHome.valueOrNull;
    final featured = state?.featuredProviders ?? const [];
    final trending = state?.trendingServices ?? const [];

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: context.textTheme.bodyLarge!.color!,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: widget.vendorType.name.text
                .size(16)
                .color(Colors.black)
                .bold
                .make(),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: Sizes.paddingSizeDefault),
          ),
          SliverToBoxAdapter(
            child: InkWell(
              onTap: () => NavigationService.openServiceSearch(
                context,
                vendorType: widget.vendorType,
                showVendors: true,
                showServices: true,
                byLocation: false,
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xffF3F9FA),
                  border: Border.all(color: const Color(0xffB3D8DE)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Color(0xff879092)),
                    const SizedBox(width: 10),
                    "Search experiences, services, or places"
                        .text
                        .color(const Color(0xff879092))
                        .make(),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: CategoriesTabsBooking(vendorType: widget.vendorType),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Sizes.paddingSizeDefault,
                vertical: 20,
              ),
              child: AdsBottom(
                null,
                padding: 0,
                viewportFraction: 1,
                featured: false,
                height: 140,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Sizes.paddingSizeDefault,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            "Recommended for You".text.bold.xl.make(),
                            "See All"
                                .text
                                .lg
                                .color(const Color(0xFF1B8A9E))
                                .make()
                                .onTap(() =>
                                    NavigationService.openServiceSearch(
                                      context,
                                      vendorType: widget.vendorType,
                                      showVendors: false,
                                      showServices: true,
                                      byLocation: false,
                                    )),
                          ],
                        ),
                        const SizedBox(height: 4),
                        "Your kind of stays, all in one place".text.make(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: widget.vendorType.id == 13 ? 360 : 300,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      itemCount: trending.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final service = trending[index];
                        void open(s) => context.pushWidget(ServiceDetailsPage(s));
                        if (widget.vendorType.id == 13) {
                          return HomeServicesListItemTatto(
                            height: 360,
                            width: 170,
                            service: service,
                            onPressed: open,
                            title: "Recommended",
                          );
                        }
                        return HomeServicesListItem(
                          height: 290,
                          width: 170,
                          service: service,
                          onPressed: open,
                          title: "Recommended",
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (featured.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Sizes.paddingSizeDefault,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    "Top Rated Providers".tr().text.bold.xl.make(),
                    "Rate generally by community base on finished orders"
                        .tr()
                        .text
                        .make(),
                    Column(
                      children: featured
                          .map(
                            (provider) => CardVendor(
                              vendor: provider,
                              onPressed: (val) =>
                                  NavigationService.openVendorDetailsPage(
                                provider,
                                context: context,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    CustomButtonLight(
                      title: "View All".tr(),
                      onPressed: () => NavigationService.openServiceSearch(
                        context,
                        vendorType: widget.vendorType,
                        showVendors: true,
                        showServices: false,
                        byLocation: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}
