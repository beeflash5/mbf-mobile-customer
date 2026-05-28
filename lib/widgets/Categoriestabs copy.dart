import 'package:flutter/material.dart';
import 'package:fuodz/view_models/service.vm.dart';
import 'package:fuodz/widgets/buttons/custom_button_light.dart';
import 'package:fuodz/widgets/service_card.dart';
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

    /// CHECK LOADING
    final isLoading = vm.busy(vm.categories);

    /// SAFE INDEX
    if (vm.categories.isNotEmpty && selectedIndex >= vm.categories.length) {
      selectedIndex = 0;
    }

    /// SERVICES LIST
    final services =
        vm.categories.isNotEmpty ? vm.categories[selectedIndex].services : [];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          /// TITLE
          Center(child: "Categories".text.size(14).color(Colors.grey).make()),

          const SizedBox(height: 6),

          /// TABS
          if (!isLoading)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(vm.categories.length, (index) {
                  final category = vm.categories[index];
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
                            category.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color:
                                  active ? context.primaryColor : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 6),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            height: 2,
                            width: active ? category.name.length * 8.0 : 0,
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

          /// POPULAR TITLE
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

          /// SERVICES GRID
          if (isLoading)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 1.5,
                crossAxisSpacing: 0.5,
                mainAxisSpacing: 0.5,
              ),
              itemCount: 3,
              itemBuilder: (context, index) {
                return _loadingCard();
              },
            )
          else if (vm.categories.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  "No categories available",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          else if (services.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  "No services available",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          else
            Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 0.5,
                    mainAxisSpacing: 0.5,
                  ),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    return ServiceCard(service: services[index]);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: CustomButtonLight(
                    title: "View All".tr(),
                    onPressed: () {},
                  ),
                ),
              ],
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// LOADING CARD
  Widget _loadingCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
