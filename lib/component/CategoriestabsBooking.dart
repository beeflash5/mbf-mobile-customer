import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/list/home_services.list_item.dart';
import 'package:fuodz/component/list/home_services.list_item_tatto.dart';
import 'package:fuodz/component/states/loading.shimmer.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/pages/service/service_details.page.dart';
import 'package:fuodz/providers/service_providers.dart';
import 'package:fuodz/services/navigation.service.dart';

class CategoriesTabsBooking extends ConsumerStatefulWidget {
  const CategoriesTabsBooking({super.key, required this.vendorType});

  final VendorType vendorType;

  @override
  ConsumerState<CategoriesTabsBooking> createState() =>
      _CategoriesTabsBookingState();
}

class _CategoriesTabsBookingState extends ConsumerState<CategoriesTabsBooking> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final asyncHome = ref.watch(
      serviceHomeControllerProvider(widget.vendorType.id),
    );
    final isLoading = asyncHome.isLoading;
    final state = asyncHome.valueOrNull;
    final cats = state?.serviceByCategories ?? const [];
    if (cats.isNotEmpty && selectedIndex >= cats.length) {
      selectedIndex = 0;
    }
    final category = cats.isNotEmpty ? cats[selectedIndex] : null;
    final services = category?.services ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const SizedBox(height: 6),
        if (!isLoading)
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(cats.length, (index) {
                  final cat = cats[index];
                  final active = selectedIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => selectedIndex = index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 24),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color:
                                active
                                    ? context.primaryColor
                                    : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                      ),
                      child: Text(
                        cat.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w500,
                          color: active ? context.primaryColor : Colors.grey,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  "Best ${category?.name ?? ""} Deals".text.bold.xl.make(),
                  "See All".text.lg
                      .color(const Color(0xFF1B8A9E))
                      .make()
                      .onTap(
                        () => NavigationService.openServiceSearch(
                          context,
                          category: category,
                          vendorType: widget.vendorType,
                          showVendors: false,
                          showServices: true,
                          byLocation: false,
                        ),
                      ),
                ],
              ),
              const SizedBox(height: 4),
              "Find great stays at the best prices, updated daily".text.make(),
            ],
          ),
        ),
        const SizedBox(height: 16),
        LoadingShimmer(
          loading: category == null || isLoading,
          child:
              services.isEmpty
                  ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: Text("No services available")),
                  )
                  : SizedBox(
                    height: widget.vendorType.id == 13 ? 360 : 300,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      itemCount: services.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final service = services[index];
                        void open(s) =>
                            context.pushWidget(ServiceDetailsPage(s));
                        if (widget.vendorType.id == 13) {
                          return HomeServicesListItemTatto(
                            height: 300,
                            width: 170,
                            service: service,
                            onPressed: open,
                            title: "Top Pick",
                          );
                        }
                        return HomeServicesListItem(
                          height: 290,
                          width: 170,
                          service: service,
                          onPressed: open,
                          title: "Top Pick",
                        );
                      },
                    ),
                  ),
        ),
      ],
    );
  }
}
