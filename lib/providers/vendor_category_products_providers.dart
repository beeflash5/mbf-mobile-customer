import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/models/category.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/services/product.request.dart';

final _productRequestProvider =
    Provider<ProductRequest>((_) => ProductRequest());

class VendorCategoryProductsState {
  const VendorCategoryProductsState({
    this.productsBySubcategory = const {},
    this.pagesBySubcategory = const {},
    this.loadingMore = const {},
  });
  final Map<int, List<Product>> productsBySubcategory;
  final Map<int, int> pagesBySubcategory;
  final Map<int, bool> loadingMore;

  VendorCategoryProductsState copyWith({
    Map<int, List<Product>>? productsBySubcategory,
    Map<int, int>? pagesBySubcategory,
    Map<int, bool>? loadingMore,
  }) =>
      VendorCategoryProductsState(
        productsBySubcategory:
            productsBySubcategory ?? this.productsBySubcategory,
        pagesBySubcategory: pagesBySubcategory ?? this.pagesBySubcategory,
        loadingMore: loadingMore ?? this.loadingMore,
      );
}

typedef VendorCategoryProductsArgs = ({Category category, Vendor? vendor});

class VendorCategoryProductsController extends FamilyAsyncNotifier<
    VendorCategoryProductsState, VendorCategoryProductsArgs> {
  late VendorCategoryProductsArgs _args;

  @override
  Future<VendorCategoryProductsState> build(
    VendorCategoryProductsArgs arg,
  ) async {
    _args = arg;
    final products = <int, List<Product>>{};
    final pages = <int, int>{};
    await Future.wait(arg.category.subcategories.map((sub) async {
      try {
        final list = await ref.read(_productRequestProvider).getProdcuts(
          page: 1,
          queryParams: {
            'sub_category_id': sub.id,
            if (arg.vendor != null) 'vendor_id': arg.vendor!.id,
          },
        );
        products[sub.id] = list;
        pages[sub.id] = 1;
      } catch (_) {
        products[sub.id] = const [];
        pages[sub.id] = 1;
      }
    }));
    return VendorCategoryProductsState(
      productsBySubcategory: products,
      pagesBySubcategory: pages,
    );
  }

  Future<void> refreshSubcategory(int subcategoryId) async {
    final cur = state.valueOrNull;
    if (cur == null) return;
    final list = await ref.read(_productRequestProvider).getProdcuts(
      page: 1,
      queryParams: {
        'sub_category_id': subcategoryId,
        if (_args.vendor != null) 'vendor_id': _args.vendor!.id,
      },
    );
    state = AsyncData(cur.copyWith(
      productsBySubcategory: {
        ...cur.productsBySubcategory,
        subcategoryId: list,
      },
      pagesBySubcategory: {
        ...cur.pagesBySubcategory,
        subcategoryId: 1,
      },
    ));
  }

  Future<void> loadMore(int subcategoryId) async {
    final cur = state.valueOrNull;
    if (cur == null) return;
    if (cur.loadingMore[subcategoryId] ?? false) return;
    state = AsyncData(cur.copyWith(loadingMore: {
      ...cur.loadingMore,
      subcategoryId: true,
    }));
    final nextPage = (cur.pagesBySubcategory[subcategoryId] ?? 1) + 1;
    try {
      final list = await ref.read(_productRequestProvider).getProdcuts(
        page: nextPage,
        queryParams: {
          'sub_category_id': subcategoryId,
          if (_args.vendor != null) 'vendor_id': _args.vendor!.id,
        },
      );
      state = AsyncData(state.value!.copyWith(
        productsBySubcategory: {
          ...state.value!.productsBySubcategory,
          subcategoryId: [
            ...?state.value!.productsBySubcategory[subcategoryId],
            ...list,
          ],
        },
        pagesBySubcategory: {
          ...state.value!.pagesBySubcategory,
          subcategoryId: nextPage,
        },
        loadingMore: {...state.value!.loadingMore, subcategoryId: false},
      ));
    } catch (_) {
      state = AsyncData(state.value!.copyWith(
        loadingMore: {...state.value!.loadingMore, subcategoryId: false},
      ));
    }
  }
}

final vendorCategoryProductsControllerProvider = AsyncNotifierProvider.family<
    VendorCategoryProductsController,
    VendorCategoryProductsState,
    VendorCategoryProductsArgs>(VendorCategoryProductsController.new);
