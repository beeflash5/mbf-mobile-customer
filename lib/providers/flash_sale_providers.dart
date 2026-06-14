import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/models/product.dart';
import 'package:fuodz/models/flash_sale.dart';
import 'package:fuodz/services/flash_sale.request.dart';

/// State paginated untuk produk flash-sale.
class FlashSaleItemsState {
  const FlashSaleItemsState({
    this.items = const [],
    this.page = 1,
    this.isLoadingMore = false,
    this.canLoadMore = true,
  });

  final List<Product> items;
  final int page;
  final bool isLoadingMore;
  final bool canLoadMore;

  FlashSaleItemsState copyWith({
    List<Product>? items,
    int? page,
    bool? isLoadingMore,
    bool? canLoadMore,
  }) {
    return FlashSaleItemsState(
      items: items ?? this.items,
      page: page ?? this.page,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      canLoadMore: canLoadMore ?? this.canLoadMore,
    );
  }
}

final flashSaleRequestProvider = Provider<FlashSaleRequest>(
  (_) => FlashSaleRequest(),
);

/// Controller paginated produk per flash-sale (id), pakai `.family`.
/// Async build = halaman 1.
class FlashSaleItemsController
    extends FamilyAsyncNotifier<FlashSaleItemsState, int> {
  late int _flashSaleId;

  @override
  Future<FlashSaleItemsState> build(int arg) async {
    _flashSaleId = arg;
    final items = await ref
        .read(flashSaleRequestProvider)
        .getProdcuts(queryParams: {'flash_sale_id': arg}, page: 1);
    return FlashSaleItemsState(
      items: items,
      page: 1,
      canLoadMore: items.isNotEmpty,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final items = await ref
          .read(flashSaleRequestProvider)
          .getProdcuts(queryParams: {'flash_sale_id': _flashSaleId}, page: 1);
      return FlashSaleItemsState(
        items: items,
        page: 1,
        canLoadMore: items.isNotEmpty,
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
          .read(flashSaleRequestProvider)
          .getProdcuts(
            queryParams: {'flash_sale_id': _flashSaleId},
            page: nextPage,
          );
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...more],
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

final flashSaleItemsControllerProvider = AsyncNotifierProvider.family<
  FlashSaleItemsController,
  FlashSaleItemsState,
  int
>(FlashSaleItemsController.new);

// =============================================================================
// HOME FLASH SALES (list per vendor-type, each with its items)
// =============================================================================

/// List flash sales untuk home widget, sudah diisi item-nya.
/// Family arg = vendorTypeId (0 = no filter).
final homeFlashSalesProvider = FutureProvider.family<List<FlashSale>, int>((
  ref,
  vendorTypeId,
) async {
  final req = ref.read(flashSaleRequestProvider);
  final sales = await req.getFlashSales(
    queryParams: vendorTypeId == 0 ? null : {'vendor_type_id': vendorTypeId},
  );
  // Fetch items per flash sale in parallel.
  await Future.wait(
    sales.map((fs) async {
      try {
        fs.items = await req.getProdcuts(queryParams: {'flash_sale_id': fs.id});
      } catch (_) {
        fs.items = [];
      }
    }),
  );
  return sales;
});
