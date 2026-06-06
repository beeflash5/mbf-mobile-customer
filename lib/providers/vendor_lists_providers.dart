import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/models/banner.dart';
import 'package:fuodz/models/category.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/services/banner.request.dart';
import 'package:fuodz/services/category.request.dart';
import 'package:fuodz/services/geocoder.service.dart';
import 'package:fuodz/services/location.service.dart';
import 'package:fuodz/services/service.request.dart';
import 'package:fuodz/services/vendor.request.dart';
import 'package:fuodz/utils/app_strings.dart';

final _vendorRequestProvider =
    Provider<VendorRequest>((_) => VendorRequest());
final _bannerRequestProvider =
    Provider<BannerRequest>((_) => BannerRequest());
final _categoryRequestProvider =
    Provider<CategoryRequest>((_) => CategoryRequest());
final _serviceRequestProvider =
    Provider<ServiceRequest>((_) => ServiceRequest());

// =====================================================================
// TOP VENDORS — family by (vendorTypeId, selectedType, enableFilter, type)
// `type` is the request-side type filter (e.g. "rated"); empty = none.
// =====================================================================
typedef TopVendorsArgs = ({
  int vendorTypeId,
  int selectedType,
  bool enableFilter,
  String type,
});

class TopVendorsController
    extends FamilyAsyncNotifier<List<Vendor>, TopVendorsArgs> {
  @override
  Future<List<Vendor>> build(TopVendorsArgs arg) async {
    final list = await ref.read(_vendorRequestProvider).topVendorsRequest(
      byLocation: AppStrings.enableFatchByLocation,
      params: {
        if (arg.vendorTypeId != 0) 'vendor_type_id': arg.vendorTypeId,
        if (arg.type.isNotEmpty) 'type': arg.type,
      },
    );
    if (arg.enableFilter) {
      if (arg.selectedType == 2) {
        return list.filter((e) => e.pickup == 1).toList();
      }
      if (arg.selectedType == 1) {
        return list.filter((e) => e.delivery == 1).toList();
      }
    }
    return list;
  }
}

final topVendorsControllerProvider = AsyncNotifierProvider.family<
    TopVendorsController, List<Vendor>, TopVendorsArgs>(
  TopVendorsController.new,
);

// =====================================================================
// NEARBY VENDORS — family by (vendorTypeId, selectedType)
// =====================================================================
typedef NearbyVendorsArgs = ({int vendorTypeId, int selectedType});

class NearbyVendorsController
    extends FamilyAsyncNotifier<List<Vendor>, NearbyVendorsArgs> {
  StreamSubscription<Address>? _sub;

  @override
  Future<List<Vendor>> build(NearbyVendorsArgs arg) async {
    _sub?.cancel();
    if (LocationService.currenctAddress?.coordinates?.latitude == null) {
      _sub = LocationService.currenctAddressSubject.listen((_) {
        _refresh(arg);
      });
      ref.onDispose(() => _sub?.cancel());
      return const [];
    }
    return _fetch(arg);
  }

  Future<List<Vendor>> _fetch(NearbyVendorsArgs arg) async {
    final list = await ref.read(_vendorRequestProvider).nearbyVendorsRequest(
      byLocation: AppStrings.enableFatchByLocation,
      params: {if (arg.vendorTypeId != 0) 'vendor_type_id': arg.vendorTypeId},
    );
    if (arg.selectedType == 2) {
      return list.filter((e) => e.pickup == 1).toList();
    }
    if (arg.selectedType == 1) {
      return list.filter((e) => e.delivery == 1).toList();
    }
    return list;
  }

  Future<void> _refresh(NearbyVendorsArgs arg) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(arg));
  }
}

final nearbyVendorsControllerProvider = AsyncNotifierProvider.family<
    NearbyVendorsController, List<Vendor>, NearbyVendorsArgs>(
  NearbyVendorsController.new,
);

// =====================================================================
// BANNERS — family by (vendorTypeId, featured)
// =====================================================================
typedef BannersArgs = ({int vendorTypeId, bool featured});

class BannersController extends FamilyAsyncNotifier<List<Banner>, BannersArgs> {
  @override
  Future<List<Banner>> build(BannersArgs arg) async {
    return ref.read(_bannerRequestProvider).banners(
      vendorTypeId: arg.vendorTypeId == 0 ? null : arg.vendorTypeId,
      params: {'featured': arg.featured ? '1' : '0'},
    );
  }
}

final bannersControllerProvider = AsyncNotifierProvider.family<
    BannersController, List<Banner>, BannersArgs>(BannersController.new);

// Ads (slot 1 / slot 2) per vendor type.
typedef AdsArgs = ({int vendorTypeId, int slot});

class AdsController extends FamilyAsyncNotifier<List<Banner>, AdsArgs> {
  @override
  Future<List<Banner>> build(AdsArgs arg) async {
    return ref.read(_bannerRequestProvider).ads(
      vendorTypeId: arg.vendorTypeId == 0 ? null : arg.vendorTypeId,
      params: arg.slot == 1 ? {'ads1': 1} : {'ads2': 1},
    );
  }
}

final adsControllerProvider = AsyncNotifierProvider.family<
    AdsController, List<Banner>, AdsArgs>(AdsController.new);

// =====================================================================
// CATEGORIES-SERVICES — categories each pre-filled with their services
// Family arg: (vendorTypeId, maxCategories(0 = unlimited))
// =====================================================================
typedef CategoriesServicesArgs = ({int vendorTypeId, int maxCategories});

class CategoriesServicesController
    extends FamilyAsyncNotifier<List<Category>, CategoriesServicesArgs> {
  @override
  Future<List<Category>> build(CategoriesServicesArgs arg) async {
    var cats = await ref.read(_categoryRequestProvider).categories(
      vendorTypeId: arg.vendorTypeId == 0 ? null : arg.vendorTypeId,
    );
    if (arg.maxCategories > 0 && cats.length > arg.maxCategories) {
      cats = cats.take(arg.maxCategories).toList();
    }
    await Future.wait(
      cats.map((category) async {
        try {
          final List<Service> services =
              await ref.read(_serviceRequestProvider).getServices(
            queryParams: {'category_id': category.id},
          );
          category.services
            ..clear()
            ..addAll(services);
        } catch (_) {/* swallow per-cat */}
      }),
    );
    return cats;
  }
}

final categoriesServicesControllerProvider = AsyncNotifierProvider.family<
    CategoriesServicesController,
    List<Category>,
    CategoriesServicesArgs>(CategoriesServicesController.new);
