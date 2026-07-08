import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/models/coupon.dart';
import 'package:fuodz/services/cart.request.dart';

/// State pencarian/penerapan coupon.
class ApplyDiscountState {
  const ApplyDiscountState({this.coupon, this.isBusy = false, this.error});

  final Coupon? coupon;
  final bool isBusy;
  final String? error;

  ApplyDiscountState copyWith({
    Coupon? coupon,
    bool clearCoupon = false,
    bool? isBusy,
    String? error,
    bool clearError = false,
  }) {
    return ApplyDiscountState(
      coupon: clearCoupon ? null : (coupon ?? this.coupon),
      isBusy: isBusy ?? this.isBusy,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final applyDiscountCartRequestProvider = Provider<CartRequest>(
  (_) => CartRequest(),
);

class ApplyDiscountController extends Notifier<ApplyDiscountState> {
  @override
  ApplyDiscountState build() => const ApplyDiscountState();

  CartRequest get _cart => ref.read(applyDiscountCartRequestProvider);

  void setInitialCoupon(Coupon? coupon) {
    state = state.copyWith(coupon: coupon);
  }

  /// `vendorTypeId` boleh null bila non-vendor-type context.
  Future<Coupon?> apply({required String code, int? vendorTypeId}) async {
    state = state.copyWith(isBusy: true, clearError: true);
    try {
      final fetched = await _cart.fetchCoupon(code);
      if (vendorTypeId != null &&
          fetched.vendorTypeId != null &&
          fetched.vendorTypeId != vendorTypeId) {
        state = state.copyWith(
          isBusy: false,
          error: "Coupon can't be used for this vendor type.",
          clearCoupon: true,
        );
        return null;
      }
      if (fetched.useLeft <= 0) {
        state = state.copyWith(
          isBusy: false,
          error: 'Coupon use limit exceeded',
          clearCoupon: true,
        );
        return null;
      }
      if (fetched.expired) {
        state = state.copyWith(
          isBusy: false,
          error: 'Coupon has expired',
          clearCoupon: true,
        );
        return null;
      }
      state = state.copyWith(coupon: fetched, isBusy: false, clearError: true);
      return fetched;
    } catch (e) {
      state = state.copyWith(isBusy: false, error: '$e', clearCoupon: true);
      return null;
    }
  }
}

final applyDiscountControllerProvider =
    NotifierProvider<ApplyDiscountController, ApplyDiscountState>(
      ApplyDiscountController.new,
    );
