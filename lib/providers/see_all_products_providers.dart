import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/models/product.dart';
import 'package:fuodz/services/product.request.dart';
import 'package:fuodz/utils/product_fetch_data_type.enum.dart';

/// State paginated produk "see all" — di-key oleh kombinasi parameter.
class SeeAllProductsState {
  const SeeAllProductsState({
    this.products = const [],
    this.page = 1,
    this.canLoadMore = true,
    this.isLoadingMore = false,
  });

  final List<Product> products;
  final int page;
  final bool canLoadMore;
  final bool isLoadingMore;

  SeeAllProductsState copyWith({
    List<Product>? products,
    int? page,
    bool? canLoadMore,
    bool? isLoadingMore,
  }) => SeeAllProductsState(
    products: products ?? this.products,
    page: page ?? this.page,
    canLoadMore: canLoadMore ?? this.canLoadMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}

/// Argumen family — record. Pakai 0 sebagai sentinel "no filter".
typedef SeeAllProductsArgs =
    ({ProductFetchDataType type, int categoryId, int vendorTypeId});

final _productRequestProvider = Provider<ProductRequest>(
  (_) => ProductRequest(),
);

class SeeAllProductsController
    extends FamilyAsyncNotifier<SeeAllProductsState, SeeAllProductsArgs> {
  late SeeAllProductsArgs _args;

  Map<String, dynamic> _params(int page) {
    final t = _args.type.name.toLowerCase();
    return {
      'category_id': _args.categoryId == 0 ? null : _args.categoryId,
      'vendor_type_id': _args.vendorTypeId == 0 ? null : _args.vendorTypeId,
      'type': t,
      'filter': t,
      'page': page,
    };
  }

  @override
  Future<SeeAllProductsState> build(SeeAllProductsArgs arg) async {
    _args = arg;
    final products = await ref
        .read(_productRequestProvider)
        .getProdcuts(queryParams: _params(1), page: 1);
    return SeeAllProductsState(
      products: products,
      page: 1,
      canLoadMore: products.isNotEmpty,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final products = await ref
          .read(_productRequestProvider)
          .getProdcuts(queryParams: _params(1), page: 1);
      return SeeAllProductsState(
        products: products,
        page: 1,
        canLoadMore: products.isNotEmpty,
      );
    });
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore || !current.canLoadMore) {
      return;
    }
    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final nextPage = current.page + 1;
      final more = await ref
          .read(_productRequestProvider)
          .getProdcuts(queryParams: _params(nextPage), page: nextPage);
      state = AsyncData(
        current.copyWith(
          products: [...current.products, ...more],
          page: nextPage,
          isLoadingMore: false,
          canLoadMore: more.isNotEmpty,
        ),
      );
    } catch (_) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
      rethrow;
    }
  }
}

final seeAllProductsControllerProvider = AsyncNotifierProvider.family<
  SeeAllProductsController,
  SeeAllProductsState,
  SeeAllProductsArgs
>(SeeAllProductsController.new);
