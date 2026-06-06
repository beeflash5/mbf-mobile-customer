import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import 'package:fuodz/models/menu.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/services/product.request.dart';
import 'package:fuodz/services/vendor.request.dart';

final _vendorRequestProvider =
    Provider<VendorRequest>((_) => VendorRequest());
final _productRequestProvider =
    Provider<ProductRequest>((_) => ProductRequest());

class VendorMenuDetailsState {
  const VendorMenuDetailsState({
    required this.vendor,
    this.menuProducts = const {},
    this.menuPages = const {},
    this.loadingMore = const {},
  });
  final Vendor vendor;
  final Map<int, List<Product>> menuProducts;
  final Map<int, int> menuPages;
  final Map<int, bool> loadingMore;

  VendorMenuDetailsState copyWith({
    Vendor? vendor,
    Map<int, List<Product>>? menuProducts,
    Map<int, int>? menuPages,
    Map<int, bool>? loadingMore,
  }) =>
      VendorMenuDetailsState(
        vendor: vendor ?? this.vendor,
        menuProducts: menuProducts ?? this.menuProducts,
        menuPages: menuPages ?? this.menuPages,
        loadingMore: loadingMore ?? this.loadingMore,
      );
}

/// Family arg = vendorId.
class VendorMenuDetailsController
    extends FamilyAsyncNotifier<VendorMenuDetailsState, int> {
  @override
  Future<VendorMenuDetailsState> build(int arg) async {
    final vendor = await ref.read(_vendorRequestProvider).vendorDetails(
      arg,
      params: {'type': 'small'},
    );
    vendor.menus.insert(0, Menu.fromJson({'id': 0, 'name': 'All'.tr()}));
    final products = <int, List<Product>>{};
    final pages = <int, int>{};
    await Future.wait(vendor.menus.map((menu) async {
      try {
        products[menu.id] = await ref
            .read(_productRequestProvider)
            .getProdcuts(
              page: 1,
              queryParams: {'menu_id': menu.id, 'vendor_id': vendor.id},
            );
        pages[menu.id] = 1;
      } catch (_) {
        products[menu.id] = const [];
        pages[menu.id] = 1;
      }
    }));
    return VendorMenuDetailsState(
      vendor: vendor,
      menuProducts: products,
      menuPages: pages,
    );
  }

  Future<void> loadMore(int menuId) async {
    final cur = state.valueOrNull;
    if (cur == null) return;
    if (cur.loadingMore[menuId] ?? false) return;
    state = AsyncData(cur.copyWith(
      loadingMore: {...cur.loadingMore, menuId: true},
    ));
    final nextPage = (cur.menuPages[menuId] ?? 1) + 1;
    try {
      final list = await ref.read(_productRequestProvider).getProdcuts(
        page: nextPage,
        queryParams: {'menu_id': menuId, 'vendor_id': cur.vendor.id},
      );
      state = AsyncData(state.value!.copyWith(
        menuProducts: {
          ...state.value!.menuProducts,
          menuId: [...?state.value!.menuProducts[menuId], ...list],
        },
        menuPages: {...state.value!.menuPages, menuId: nextPage},
        loadingMore: {...state.value!.loadingMore, menuId: false},
      ));
    } catch (_) {
      state = AsyncData(state.value!.copyWith(
        loadingMore: {...state.value!.loadingMore, menuId: false},
      ));
    }
  }

  Future<void> refreshMenu(int menuId) async {
    final cur = state.valueOrNull;
    if (cur == null) return;
    try {
      final list = await ref.read(_productRequestProvider).getProdcuts(
        page: 1,
        queryParams: {'menu_id': menuId, 'vendor_id': cur.vendor.id},
      );
      state = AsyncData(cur.copyWith(
        menuProducts: {...cur.menuProducts, menuId: list},
        menuPages: {...cur.menuPages, menuId: 1},
      ));
    } catch (_) {}
  }
}

final vendorMenuDetailsControllerProvider = AsyncNotifierProvider.family<
    VendorMenuDetailsController, VendorMenuDetailsState, int>(
  VendorMenuDetailsController.new,
);
