import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/models/service.dart';
import 'package:fuodz/services/service.request.dart';

final _serviceRequestProvider = Provider<ServiceRequest>(
  (_) => ServiceRequest(),
);

/// Service list for a vendor. Family arg = vendorId.
class ServiceVendorDetailsController
    extends FamilyAsyncNotifier<List<Service>, int> {
  @override
  Future<List<Service>> build(int arg) async {
    return ref
        .read(_serviceRequestProvider)
        .getServices(queryParams: {'vendor_id': arg}, page: 0);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(_serviceRequestProvider)
          .getServices(queryParams: {'vendor_id': arg}, page: 0),
    );
  }
}

final serviceVendorDetailsControllerProvider = AsyncNotifierProvider.family<
  ServiceVendorDetailsController,
  List<Service>,
  int
>(ServiceVendorDetailsController.new);
