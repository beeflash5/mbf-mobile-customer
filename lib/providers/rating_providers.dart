import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/services/vendor.request.dart';

sealed class RatingResult {
  const RatingResult();
}

class RatingSuccess extends RatingResult {
  const RatingSuccess(this.message);
  final String message;
}

class RatingFailure extends RatingResult {
  const RatingFailure(this.message);
  final String message;
}

final _vendorRequestProvider = Provider<VendorRequest>((_) => VendorRequest());

class DriverRatingController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<RatingResult> submit({
    required int rating,
    required String review,
    required int orderId,
    required int driverId,
  }) async {
    state = const AsyncLoading();
    try {
      final res = await ref
          .read(_vendorRequestProvider)
          .rateDriver(
            rating: rating,
            review: review,
            orderId: orderId,
            driverId: driverId,
          );
      state = const AsyncData(null);
      return res.allGood
          ? RatingSuccess(res.message ?? 'Submitted')
          : RatingFailure(res.message ?? 'Submit gagal');
    } catch (e, st) {
      state = AsyncError(e, st);
      return RatingFailure('$e');
    }
  }
}

final driverRatingControllerProvider =
    AsyncNotifierProvider<DriverRatingController, void>(
      DriverRatingController.new,
    );

class VendorRatingController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<RatingResult> submit({
    required int rating,
    required String review,
    required int orderId,
    required int vendorId,
  }) async {
    state = const AsyncLoading();
    try {
      final res = await ref
          .read(_vendorRequestProvider)
          .rateVendor(
            rating: rating,
            review: review,
            orderId: orderId,
            vendorId: vendorId,
          );
      state = const AsyncData(null);
      return res.allGood
          ? RatingSuccess(res.message ?? 'Submitted')
          : RatingFailure(res.message ?? 'Submit gagal');
    } catch (e, st) {
      state = AsyncError(e, st);
      return RatingFailure('$e');
    }
  }
}

final vendorRatingControllerProvider =
    AsyncNotifierProvider<VendorRatingController, void>(
      VendorRatingController.new,
    );
