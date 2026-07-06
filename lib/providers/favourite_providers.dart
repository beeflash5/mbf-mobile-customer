import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/services/favourite.request.dart';

final _favouriteRequestProvider = Provider<FavouriteRequest>(
  (_) => FavouriteRequest(),
);

// ── Global ID Cache ───────────────────────────────────────────────────────────
// Source of truth for all three entity types.
// Fetched once on boot; updated optimistically on every toggle.

class FavouriteIdsNotifier
    extends StateNotifier<AsyncValue<Map<String, List<int>>>> {
  final Ref ref;
  FavouriteIdsNotifier(this.ref) : super(const AsyncLoading()) {
    fetchIds();
  }

  Future<void> fetchIds() async {
    try {
      final req = ref.read(_favouriteRequestProvider);
      final ids = await req.getFavouriteIds();
      state = AsyncData(ids);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  void toggleProduct(int id, bool isFav) => _toggle('product_ids', id, isFav);
  void toggleService(int id, bool isFav) => _toggle('service_ids', id, isFav);
  void toggleVendor(int id, bool isFav) => _toggle('vendor_ids', id, isFav);

  bool isProductFav(int id) =>
      state.valueOrNull?['product_ids']?.contains(id) ?? false;
  bool isServiceFav(int id) =>
      state.valueOrNull?['service_ids']?.contains(id) ?? false;
  bool isVendorFav(int id) =>
      state.valueOrNull?['vendor_ids']?.contains(id) ?? false;

  void _toggle(String key, int id, bool isFav) {
    if (state is AsyncData) {
      final data = Map<String, List<int>>.from(
        state.value!.map((k, v) => MapEntry(k, List<int>.from(v))),
      );
      final list = data[key] ?? [];
      if (isFav && !list.contains(id)) {
        list.add(id);
      } else if (!isFav) {
        list.remove(id);
      }
      data[key] = list;
      state = AsyncData(data);
    }
  }
}

final favouriteIdsProvider = StateNotifierProvider<FavouriteIdsNotifier,
    AsyncValue<Map<String, List<int>>>>((ref) {
  return FavouriteIdsNotifier(ref);
});

// ── Product ───────────────────────────────────────────────────────────────────

class FavouriteProductController extends FamilyAsyncNotifier<bool, int> {
  @override
  Future<bool> build(int arg) async => false;

  Future<bool?> toggle({required int productId, required bool current}) async {
    state = const AsyncLoading();
    try {
      final req = ref.read(_favouriteRequestProvider);
      final res = current
          ? await req.removeFavourite(productId)
          : await req.makeFavourite(productId);
      final newVal = res.allGood ? !current : current;
      if (res.allGood) {
        ref.read(favouriteIdsProvider.notifier).toggleProduct(productId, newVal);
      }
      state = AsyncData(false);
      return res.allGood ? newVal : null;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}

final favouriteProductControllerProvider =
    AsyncNotifierProvider.family<FavouriteProductController, bool, int>(
      FavouriteProductController.new,
    );

// ── Service ───────────────────────────────────────────────────────────────────

class FavouriteServiceController extends FamilyAsyncNotifier<bool, int> {
  @override
  Future<bool> build(int arg) async => false;

  Future<bool?> toggle({required int serviceId, required bool current}) async {
    state = const AsyncLoading();
    try {
      final req = ref.read(_favouriteRequestProvider);
      final res = current
          ? await req.removeFavourite(serviceId)
          : await req.makeFavouriteService(serviceId);
      final newVal = res.allGood ? !current : current;
      if (res.allGood) {
        ref.read(favouriteIdsProvider.notifier).toggleService(serviceId, newVal);
      }
      state = AsyncData(false);
      return res.allGood ? newVal : null;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}

final favouriteServiceControllerProvider =
    AsyncNotifierProvider.family<FavouriteServiceController, bool, int>(
      FavouriteServiceController.new,
    );

// ── Vendor ────────────────────────────────────────────────────────────────────

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
      if (res.allGood) {
        ref.read(favouriteIdsProvider.notifier).toggleVendor(vendorId, newVal);
      }
      state = AsyncData(false);
      return res.allGood ? newVal : null;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}

final favouriteVendorControllerProvider =
    AsyncNotifierProvider.family<FavouriteVendorController, bool, int>(
      FavouriteVendorController.new,
    );
