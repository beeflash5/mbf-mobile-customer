import 'package:flutter/material.dart';
import 'package:fuodz/models/category.dart';
import 'package:fuodz/services/navigation.service.dart';
import 'package:fuodz/component/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class CategorySection extends StatefulWidget {
  CategorySection({super.key, required this.categories});
  final List<Category> categories;

  @override
  State<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection> {
  final PageController _pageController = PageController();
  int currentIndex = 0;

  final int itemsPerPage = 10;

  @override
  Widget build(BuildContext context) {
    final int totalPages = (widget.categories.length / itemsPerPage).ceil();

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            itemCount: totalPages,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (context, pageIndex) {
              final startIndex = pageIndex * itemsPerPage;
              final endIndex =
                  (startIndex + itemsPerPage) > widget.categories.length
                      ? widget.categories.length
                      : startIndex + itemsPerPage;

              final pageItems = widget.categories.sublist(startIndex, endIndex);

              return buildGrid(pageItems);
            },
          ),
        ),

        const SizedBox(height: 8),

        // Dot Indicator Dynamic
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            totalPages,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: currentIndex == index ? 12 : 8,
              height: currentIndex == index ? 12 : 8,
              decoration: BoxDecoration(
                color:
                    currentIndex == index
                        ? context.primaryColor
                        : Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildGrid(List<Category> list) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 8,
        crossAxisSpacing: 16,
        childAspectRatio: 0.6,
      ),
      itemBuilder: (context, index) {
        final item = list[index];

        return InkWell(
          onTap: () {
            NavigationService.categorySelected(item);
          },
          child: Column(
            children: [
              CustomImage(imageUrl: item.imageUrl),
              const SizedBox(height: 6),
              Text(
                item.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        );
      },
    );
  }
}
