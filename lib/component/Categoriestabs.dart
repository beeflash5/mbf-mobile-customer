import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/button/custom_button_light.dart';
import 'package:fuodz/component/service_card.dart';
import 'package:fuodz/component/states/loading.shimmer.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/providers/service_providers.dart';
import 'package:fuodz/services/navigation.service.dart';

class CategoriesTabs extends ConsumerStatefulWidget {
  const CategoriesTabs({super.key, required this.vendorType});

  final VendorType vendorType;

  @override
  ConsumerState<CategoriesTabs> createState() => _CategoriesTabsState();
}

class _CategoriesTabsState extends ConsumerState<CategoriesTabs> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final asyncHome = ref.watch(
      serviceHomeControllerProvider(widget.vendorType.id),
    );
    final state = asyncHome.valueOrNull;
    final isLoading = asyncHome.isLoading;
    final categories = state?.serviceByCategories ?? const [];

    if (categories.isNotEmpty && selectedIndex >= categories.length) {
      selectedIndex = 0;
    }
    final category = categories.isNotEmpty ? categories[selectedIndex] : null;
    final services = category?.services ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Center(child: "Categories".text.size(14).color(Colors.grey).make()),
        const SizedBox(height: 6),
        if (!isLoading)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(categories.length, (index) {
                final cat = categories[index];
                final active = selectedIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => selectedIndex = index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        Text(
                          cat.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: active ? context.primaryColor : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          height: 2,
                          width: active ? cat.name.length * 8.0 : 0,
                          decoration: BoxDecoration(
                            color: context.primaryColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              "Popular Services".text.bold.xl.make(),
              "Top booked services around selected location".text.make(),
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
                  : Column(
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              childAspectRatio: 1.6,
                            ),
                        itemCount: services.length,
                        itemBuilder:
                            (context, index) =>
                                ServiceCard(service: services[index]),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: CustomButtonLight(
                          title: "View All".tr(),
                          onPressed:
                              () => NavigationService.openServiceSearch(
                                context,
                                category: category,
                                vendorType: widget.vendorType,
                                showVendors: false,
                                showServices: true,
                                byLocation: false,
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
