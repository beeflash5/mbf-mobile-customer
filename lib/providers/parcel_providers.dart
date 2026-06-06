import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/models/order.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/services/order.request.dart';

final _orderRequestProvider =
    Provider<OrderRequest>((_) => OrderRequest());

sealed class TrackOrderResult {
  const TrackOrderResult();
}

class TrackOrderSuccess extends TrackOrderResult {
  const TrackOrderSuccess(this.order);
  final Order order;
}

class TrackOrderFailure extends TrackOrderResult {
  const TrackOrderFailure(this.message);
  final String message;
}

/// Track an order by code. Family arg = vendorTypeId (0 = none).
class ParcelTrackingController extends FamilyAsyncNotifier<Order?, int> {
  @override
  Future<Order?> build(int arg) async => null;

  Future<TrackOrderResult> trackOrder(String code) async {
    state = const AsyncLoading();
    try {
      final order = await ref.read(_orderRequestProvider).trackOrder(
        code,
        vendorTypeId: arg == 0 ? null : arg,
      );
      state = AsyncData(order);
      return TrackOrderSuccess(order);
    } catch (e, st) {
      state = AsyncError(e, st);
      return TrackOrderFailure('$e');
    }
  }
}

final parcelTrackingControllerProvider = AsyncNotifierProvider.family<
    ParcelTrackingController, Order?, int>(ParcelTrackingController.new);

class ParcelHomeController extends Notifier<VendorType?> {
  @override
  VendorType? build() => null;

  void setVendorType(VendorType vendorType) {
    state = vendorType;
  }
}

final parcelHomeControllerProvider =
    NotifierProvider<ParcelHomeController, VendorType?>(
  ParcelHomeController.new,
);
