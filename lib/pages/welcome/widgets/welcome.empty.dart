import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/states/loading.shimmer.dart';
import 'package:fuodz/component/bottom_sheet/location_picker.bottomsheet.dart';
import 'package:fuodz/component/busy_indicator.dart';
import 'package:fuodz/component/list/home_services.list_item.dart';
import 'package:fuodz/component/list/vendor_type_home_list_vertical_item_home.dart';
import 'package:fuodz/pages/auth/login.page.dart';
import 'package:fuodz/pages/search/main_search_home.page.dart';
import 'package:fuodz/pages/service/service_details.page.dart';
import 'package:fuodz/pages/vendor/widgets/ads_bottom.view.dart';
import 'package:fuodz/pages/vendor/widgets/banners_top.view.dart';
import 'package:fuodz/pages/welcome/widgets/travel_new_page.dart';
import 'package:fuodz/providers/welcome_providers.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/location.service.dart';
import 'package:fuodz/services/navigation.service.dart';
import 'package:fuodz/utils/app_images.dart';
import 'package:fuodz/utils/app_routes.dart';
import 'package:fuodz/utils/extensions/router.dart';

class EmptyWelcome extends ConsumerStatefulWidget {
  const EmptyWelcome({super.key});

  @override
  ConsumerState<EmptyWelcome> createState() => _EmptyWelcomeState();
}

class _EmptyWelcomeState extends ConsumerState<EmptyWelcome> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(welcomeControllerProvider);
    final state = asyncState.valueOrNull;
    final currentUser = state?.currentUser;
    final vendorTypes = state?.vendorTypes ?? const [];
    final topRated = state?.topRated ?? const [];
    final blogs = state?.blogs ?? const [];

    if (asyncState.isLoading && state == null) {
      return const Scaffold(
        body: LoadingShimmer(),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          const SizedBox(width: 10),
          AuthServices.authenticated()
              ? CachedNetworkImage(
                imageUrl: currentUser?.photo ?? "",
                progressIndicatorBuilder:
                    (context, imageUrl, progress) => BusyIndicator(),
                errorWidget:
                    (context, imageUrl, progress) =>
                        Image.asset(AppImages.user),
              ).wh(50, 50).box.roundedFull.clip(Clip.antiAlias).make()
              : Image.asset(
                AppImages.appLogo,
              ).wh(50, 50).box.clip(Clip.antiAlias).roundedSM.makeCentered(),
          const SizedBox(width: 6),
          AuthServices.authenticated()
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  "Hi, ${currentUser?.name ?? ""}!".text
                      .fontWeight(FontWeight.bold)
                      .color(Colors.black)
                      .make(),
                  "Explore the real Bali with locals".text
                      .color(context.primaryColor)
                      .make(),
                ],
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  "My Bali Friendz".text
                      .fontWeight(FontWeight.bold)
                      .color(Colors.black)
                      .make(),
                  "Explore the real Bali with locals".text
                      .color(context.primaryColor)
                      .make(),
                ],
              ),
          const Spacer(),
          InkWell(
            onTap: () => context.pushRoute(AppRoutes.notificationsRoute),
            child: Icon(
              Icons.notifications,
              color: context.primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 5),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child:
            VStack([
              const SizedBox(height: 70),
              InkWell(
                onTap: () => context.pushWidget(MainSearchHomePage()),
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
                      "Search experiences, services, or places".text
                          .color(const Color(0xff879092))
                          .make(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // ── Location chip (mirrors Next.js SearchBar) ──────────────────
              const SizedBox(height: 12),
              Stack(
                children: [
                  BannerTops(
                    null,
                    padding: 10,
                    viewportFraction: 1,
                    featured: false,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              "Category".text.lg.bold.make().px20(),
              SizedBox(
                height: 110,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = constraints.maxWidth;
                    const double horizontalPadding = 24.0;
                    const double visibleItems = 5.5;
                    const double baseSpacing = 4.0;
                    final itemWidth =
                        (screenWidth - horizontalPadding) / visibleItems;
                    final totalItemWidth = itemWidth * visibleItems;
                    final remainingSpace =
                        screenWidth - horizontalPadding - totalItemWidth;
                    final dynamicSpacing =
                        baseSpacing +
                        (remainingSpace > 0
                            ? remainingSpace / (visibleItems - 1)
                            : 0);
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: vendorTypes.length,
                      itemBuilder: (context, index) {
                        final vendorType = vendorTypes[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            right:
                                index == vendorTypes.length - 1
                                    ? 0
                                    : dynamicSpacing,
                          ),
                          child: SizedBox(
                            width: itemWidth,
                            child: VendorTypeHomeListItemVerticalHome(
                              vendorType,
                              onPressed: () {
                                if (!AuthServices.authenticated() &&
                                    (vendorType.slug == 'taxi' ||
                                        vendorType.slug == 'bike')) {
                                  context.pushWidget(LoginPage());
                                } else {
                                  NavigationService.pageSelected(
                                    vendorType,
                                    context: context,
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  "Trending Now".text.lg.semiBold.make(),
                  "See all".text.lg
                      .color(const Color(0xFF1B8A9E))
                      .make()
                      .onTap(
                        () => NavigationService.openServiceSearch(
                          context,
                          showServices: true,
                          showVendors: false,
                        ),
                      ),
                ],
              ).px12(),
              const SizedBox(height: 10),
              SizedBox(
                height: 300,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  itemCount: topRated.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final service = topRated[index];
                    return HomeServicesListItem(
                      height: 290,
                      width: 170,
                      service: service,
                      onPressed:
                          (s) => context.pushWidget(ServiceDetailsPage(s)),
                      title: "Top Pick",
                    );
                  },
                ),
              ),
              const SizedBox(height: 6),
              const SizedBox(height: 16),
              AdsBottom(
                null,
                padding: 10,
                viewportFraction: 1,
                featured: false,
              ),
              TravelNewsPage(
                blogs: blogs,
                hasMore: true,
                onLoadMore:
                    () =>
                        ref
                            .read(welcomeControllerProvider.notifier)
                            .loadMoreBlogs(),
                loading: asyncState.isLoading,
              ),
            ]).box.color(context.backgroundColor).topRounded(value: 30).make(),
      ),
    );
  }
}

/// Location chip shown below the search bar.
/// Tapping it opens the location picker bottom sheet (mirrors Next.js SearchBar).
class _LocationChip extends StatefulWidget {
  const _LocationChip({required this.ref});
  final WidgetRef ref;

  @override
  State<_LocationChip> createState() => _LocationChipState();
}

class _LocationChipState extends State<_LocationChip> {
  String _label = 'Set location';

  @override
  void initState() {
    super.initState();
    _updateLabel();
    // Re-render when address changes
    LocationService.currenctAddressSubject.listen((_) {
      if (mounted) _updateLabel();
    });
  }

  void _updateLabel() {
    final addr = LocationService.currenctAddress;
    if (addr == null) {
      setState(() => _label = 'Set location');
      return;
    }
    final label =
        addr.locality?.isNotEmpty == true
            ? addr.locality!
            : addr.subLocality?.isNotEmpty == true
            ? addr.subLocality!
            : addr.featureName?.isNotEmpty == true
            ? addr.featureName!
            : addr.addressLine ?? 'Set location';
    setState(() => _label = label);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => showLocationPickerSheet(context, widget.ref),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xffF3F9FA),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xffB3D8DE)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on,
                size: 15,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  _label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
