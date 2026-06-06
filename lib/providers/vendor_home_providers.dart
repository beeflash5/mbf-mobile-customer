import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/models/product.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/services/product.request.dart';
import 'package:fuodz/services/vendor.request.dart';

final _productRequestProvider =
    Provider<ProductRequest>((_) => ProductRequest());
final _vendorRequestProvider =
    Provider<VendorRequest>((_) => VendorRequest());

/// Today's picks (best products) per vendorType (0 = none).
class TodayPicksController extends FamilyAsyncNotifier<List<Product>, int> {
  @override
  Future<List<Product>> build(int arg) async {
    return ref.read(_productRequestProvider).getProdcuts(
      queryParams: {
        if (arg != 0) 'vendor_type_id': arg,
        'type': 'best',
      },
    );
  }
}

final todayPicksControllerProvider = AsyncNotifierProvider.family<
    TodayPicksController, List<Product>, int>(TodayPicksController.new);

/// Nearby vendors filtered by vendorType (0 = none).
class NearbyVendorsHomeController
    extends FamilyAsyncNotifier<List<Vendor>, int> {
  @override
  Future<List<Vendor>> build(int arg) async {
    return ref.read(_vendorRequestProvider).nearbyVendorsRequest(
      params: {if (arg != 0) 'vendor_type_id': arg},
    );
  }
}

final nearbyVendorsHomeControllerProvider = AsyncNotifierProvider.family<
    NearbyVendorsHomeController, List<Vendor>, int>(
  NearbyVendorsHomeController.new,
);
