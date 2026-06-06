import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/models/product.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/services/favourite.request.dart';

final favouritesRequestProvider =
    Provider<FavouriteRequest>((_) => FavouriteRequest());

/// Controller list produk favorit.
class FavouriteProductsController
    extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    return ref.read(favouritesRequestProvider).favourites();
  }

  FavouriteRequest get _req => ref.read(favouritesRequestProvider);

  /// Refresh dari server.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _req.favourites());
  }

  /// Hapus produk dari favorit + sync state.
  /// Returns message hasil (success/error) untuk dialog di UI.
  Future<({bool ok, String message})> remove(Product product) async {
    final res = await _req.removeFavourite(product.id);
    if (res.allGood) {
      final current = state.valueOrNull ?? [];
      state = AsyncData(current.where((p) => p.id != product.id).toList());
    }
    return (ok: res.allGood, message: res.message ?? '');
  }
}

final favouriteProductsControllerProvider =
    AsyncNotifierProvider<FavouriteProductsController, List<Product>>(
  FavouriteProductsController.new,
);

/// Controller list vendor favorit.
class FavouriteVendorsController extends AsyncNotifier<List<Vendor>> {
  @override
  Future<List<Vendor>> build() async {
    return ref.read(favouritesRequestProvider).favouriteVendors();
  }

  FavouriteRequest get _req => ref.read(favouritesRequestProvider);

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _req.favouriteVendors());
  }

  Future<({bool ok, String message})> remove(Vendor vendor) async {
    final res = await _req.removeFavouriteVendor(vendor.id);
    if (res.allGood) {
      final current = state.valueOrNull ?? [];
      state = AsyncData(current.where((v) => v.id != vendor.id).toList());
    }
    return (ok: res.allGood, message: res.message ?? '');
  }
}

final favouriteVendorsControllerProvider =
    AsyncNotifierProvider<FavouriteVendorsController, List<Vendor>>(
  FavouriteVendorsController.new,
);
