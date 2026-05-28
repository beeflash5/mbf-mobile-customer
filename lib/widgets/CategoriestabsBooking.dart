import 'package:flutter/material.dart';
import 'package:fuodz/services/navigation.service.dart';
import 'package:fuodz/view_models/service.vm.dart';
import 'package:fuodz/widgets/buttons/custom_button_light.dart';
import 'package:fuodz/widgets/list_items/home_services.list_item.dart';
import 'package:fuodz/widgets/list_items/home_services.list_item_tatto.dart';
import 'package:fuodz/widgets/service_card.dart';
import 'package:fuodz/widgets/states/loading.shimmer.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class CategoriesTabsBooking extends StatefulWidget {
  final ServiceViewModel vm;

  const CategoriesTabsBooking({super.key, required this.vm});

  @override
  State<CategoriesTabsBooking> createState() => _CategoriesTabsBookingState();
}

class _CategoriesTabsBookingState extends State<CategoriesTabsBooking> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;

    final isLoading = vm.busy(vm.serviceByCategories);

    if (vm.serviceByCategories.isNotEmpty &&
        selectedIndex >= vm.serviceByCategories.length) {
      selectedIndex = 0;
    }

    final category =
        vm.serviceByCategories.isNotEmpty
            ? vm.serviceByCategories[selectedIndex]
            : null;

    final services = category?.services ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),

        /// TITLE
        // Center(child: "Categories".text.size(14).color(Colors.grey).make()),
        const SizedBox(height: 6),

        /// CATEGORY TABS
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
                children: List.generate(vm.serviceByCategories.length, (index) {
                  final cat = vm.serviceByCategories[index];
                  final active = selectedIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
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

        /// TITLE SERVICES
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  "Best ${category?.name ?? ""} Deals".text.bold.xl.make(),
                  "See All".text.lg.color(Color(0xFF1B8A9E)).make().onTap(() {
                    NavigationService.openServiceSearch(
                      context,
                      category: category,
                      vendorType: vm.vendorType,
                      showVendors: false,
                      showServices: true,
                      byLocation: false,
                    );
                  }),
                ],
              ),
              SizedBox(height: 4),

              "Find great stays at the best prices, updated daily".text.make(),
            ],
          ),
        ),

        const SizedBox(height: 16),

        /// SERVICES WITH SHIMMER
        LoadingShimmer(
          loading: category == null ? true : vm.busy(category.id),
          child:
              services.isEmpty
                  ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: Text("No services available")),
                  )
                  : Column(
                    children: [
                      SizedBox(
                        height: vm.vendorType?.id == 13 ? 360 : 300,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          itemCount: services.length.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final product = services[index];

                            if (vm.vendorType?.id == 13) {
                              return HomeServicesListItemTatto(
                                height: 300,
                                width: 170,
                                service: product,
                                onPressed: vm.servicePressed,
                                title: "Top Pick",
                              );
                            }

                            return HomeServicesListItem(
                              height: 290,
                              width: 170,
                              service: product,
                              onPressed: vm.servicePressed,
                              title: "Top Pick",
                            );
                          },
                        ),
                      ),

                      /// VIEW ALL
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 16),
                      //   child: CustomButtonLight(
                      //     title: "View All".tr(),
                      //     onPressed: () {
                      //       NavigationService.openServiceSearch(
                      //         context,
                      //         category: category,
                      //         vendorType: vm.vendorType,
                      //         showVendors: false,
                      //         showServices: true,
                      //         byLocation: false,
                      //       );
                      //     },
                      //   ),
                      // ),
                      // SizedBox(height: 16),
                    ],
                  ),
        ),

        // const SizedBox(height: 20),
      ],
    );
  }
}
