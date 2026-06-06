import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/services/favourite.request.dart';

final _favouriteRequestProvider =
    Provider<FavouriteRequest>((_) => FavouriteRequest());

/// Toggle favorite produk per id. State = isBusy.
/// Hasil toggle ditandai via boolean (`true` = sekarang favourite).
class FavouriteProductController
    extends FamilyAsyncNotifier<bool, int> {
  @override
  Future<bool> build(int arg) async => false;

  /// Toggle: kalau saat ini bukan favorite, add; sebaliknya remove.
  /// Return state baru `isFavourite` (true/false) atau null kalau gagal.
  Future<bool?> toggle({required int productId, required bool current}) async {
    state = const AsyncLoading();
    try {
      final req = ref.read(_favouriteRequestProvider);
      final res = current
          ? await req.removeFavourite(productId)
          : await req.makeFavourite(productId);
      final newVal = res.allGood ? !current : current;
      state = AsyncData(false);
      return res.allGood ? newVal : null;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}

final favouriteProductControllerProvider = AsyncNotifierProvider.family<
    FavouriteProductController, bool, int>(FavouriteProductController.new);

/// Toggle favorite vendor per id.
class FavouriteVendorController extends FamilyAsyncNotifier<bool, int> {
  @override
  Future<bool> build(int arg) async => false;

  Future<bool?> toggle({required int vendorId, required bool current}) async {
    state = const AsyncLoading();
    try {
      final req = ref.read(_favouriteRequestProvider);
      final res = current
          ? await req.removeFavouriteVendor(vendorId)
          : await req.makeFavouriteVendor(vendorId);
      final newVal = res.allGood ? !current : current;
      state = AsyncData(false);
      return res.allGood ? newVal : null;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}

final favouriteVendorControllerProvider = AsyncNotifierProvider.family<
    FavouriteVendorController, bool, int>(FavouriteVendorController.new);
