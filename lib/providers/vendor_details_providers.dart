import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/services/vendor.request.dart';

final _vendorRequestProvider = Provider<VendorRequest>((_) => VendorRequest());

/// Vendor details fetched by id. Family arg = vendorId.
class VendorDetailsController extends FamilyAsyncNotifier<Vendor, int> {
  @override
  Future<Vendor> build(int arg) async {
    return ref
        .read(_vendorRequestProvider)
        .vendorDetails(arg, params: {'type': 'small'});
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(_vendorRequestProvider)
          .vendorDetails(arg, params: {'type': 'small'}),
    );
  }
}

final vendorDetailsControllerProvider =
    AsyncNotifierProvider.family<VendorDetailsController, Vendor, int>(
      VendorDetailsController.new,
    );
