import 'package:flutter/material.dart';
import 'package:fuodz/services/navigation.service.dart';
import 'package:fuodz/view_models/service.vm.dart';
import 'package:fuodz/widgets/buttons/custom_button_light.dart';
import 'package:fuodz/widgets/service_card.dart';
import 'package:fuodz/widgets/states/loading.shimmer.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class CategoriesTabs extends StatefulWidget {
  final ServiceViewModel vm;

  const CategoriesTabs({super.key, required this.vm});

  @override
  State<CategoriesTabs> createState() => _CategoriesTabsState();
}

class _CategoriesTabsState extends State<CategoriesTabs> {
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
        Center(child: "Categories".text.size(14).color(Colors.grey).make()),

        const SizedBox(height: 6),

        /// CATEGORY TABS
        if (!isLoading)
          SingleChildScrollView(
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

        /// TITLE SERVICES
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
                        itemBuilder: (context, index) {
                          return ServiceCard(service: services[index]);
                        },
                      ),

                      /// VIEW ALL
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: CustomButtonLight(
                          title: "View All".tr(),
                          onPressed: () {
                            NavigationService.openServiceSearch(
                              context,
                              category: category,
                              vendorType: vm.vendorType,
                              showVendors: false,
                              showServices: true,
                              byLocation: false,
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 16),
                    ],
                  ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}
