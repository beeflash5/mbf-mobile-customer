import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/component/list/commerce_product.flashsale.list_item.dart';
import 'package:velocity_x/velocity_x.dart';

class FlashSales extends StatefulWidget {
  const FlashSales({super.key, required this.products});
  final List<Product> products;

  @override
  State<FlashSales> createState() => _FlashSalesState();
}

class _FlashSalesState extends State<FlashSales> {
  late PageController _controller;
  int currentPage = 1000; // 🔥 mulai dari tengah biar bisa infinite
  Timer? timer;

  // /// 🔥 DATA
  // final List<Product> products = [
  //   Product(
  //     name: "T-shirt Barong Bali",
  //     price: 100000,
  //     image: "https://via.placeholder.com/150",
  //   ),
  //   Product(
  //     name: "Tas Pria Bali",
  //     price: 150000,
  //     image: "https://via.placeholder.com/150",
  //   ),
  //   Product(
  //     name: "Topi Pantai",
  //     price: 50000,
  //     image: "https://via.placeholder.com/150",
  //   ),
  // ];

  @override
  void initState() {
    super.initState();

    _controller = PageController(
      initialPage: currentPage,
      viewportFraction: 0.5,
    );

    /// 🔥 AUTO SCROLL
    timer = Timer.periodic(const Duration(seconds: 3), (_) {
      currentPage++;

      _controller.animateToPage(
        currentPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        const Text(
          "🔥 Flash Sale",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ).px(16),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 215,
            child: PageView.builder(
              controller: _controller,
              itemBuilder: (context, index) {
                /// 🔥 LOOP TANPA BATAS
                final item = widget.products[index % widget.products.length];

                return CommerceProductListItemFlashSale(item, height: 80).p(10);
              },
            ),
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
  }
}
