import 'package:dartx/dartx.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/models/cart.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/services/cart.service.dart';
import 'package:fuodz/services/product.request.dart';

class ProductBoughtTogetherState {
  const ProductBoughtTogetherState({
    this.products = const [],
    this.selectedIds = const {},
    this.expanded = false,
    this.isAddingToCart = false,
  });

  final List<Product> products;
  final Set<int> selectedIds;
  final bool expanded;
  final bool isAddingToCart;

  double get totalSellPrice => products
      .where((p) => selectedIds.contains(p.id))
      .sumBy((p) => p.sellPrice);

  List<Product> get selectedProducts =>
      products.where((p) => selectedIds.contains(p.id)).toList();

  ProductBoughtTogetherState copyWith({
    List<Product>? products,
    Set<int>? selectedIds,
    bool? expanded,
    bool? isAddingToCart,
  }) => ProductBoughtTogetherState(
    products: products ?? this.products,
    selectedIds: selectedIds ?? this.selectedIds,
    expanded: expanded ?? this.expanded,
    isAddingToCart: isAddingToCart ?? this.isAddingToCart,
  );
}

final _productRequestProvider = Provider<ProductRequest>(
  (_) => ProductRequest(),
);

/// Family by product id (produk yang sedang dilihat).
class ProductBoughtTogetherController
    extends FamilyAsyncNotifier<ProductBoughtTogetherState, int> {
  @override
  Future<ProductBoughtTogetherState> build(int arg) async {
    final products = await ref
        .read(_productRequestProvider)
        .productsBoughtTogether(queryParams: {'id': arg});
    return ProductBoughtTogetherState(
      products: products,
      selectedIds: products.map((p) => p.id).toSet(),
    );
  }

  void toggleExpanded() {
    final s = state.valueOrNull;
    if (s == null) return;
    state = AsyncData(s.copyWith(expanded: !s.expanded));
  }

  void toggleProduct(int productId, bool selected) {
    final s = state.valueOrNull;
    if (s == null) return;
    final ids = {...s.selectedIds};
    if (selected) {
      ids.add(productId);
    } else {
      ids.remove(productId);
    }
    state = AsyncData(s.copyWith(selectedIds: ids));
  }

  Future<bool> addSelectedToCart() async {
    final s = state.valueOrNull;
    if (s == null) return false;
    state = AsyncData(s.copyWith(isAddingToCart: true));
    try {
      for (final product in s.selectedProducts) {
        product.selectedQty = 1;
        await CartServices.addToCart(
          Cart(product: product, selectedQty: 1, price: product.sellPrice),
        );
      }
      state = AsyncData(s.copyWith(isAddingToCart: false));
      return true;
    } catch (_) {
      state = AsyncData(s.copyWith(isAddingToCart: false));
      return false;
    }
  }
}

final productBoughtTogetherControllerProvider = AsyncNotifierProvider.family<
  ProductBoughtTogetherController,
  ProductBoughtTogetherState,
  int
>(ProductBoughtTogetherController.new);
