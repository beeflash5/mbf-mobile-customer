import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/models/coupon.dart';
import 'package:fuodz/services/coupon.request.dart';

final couponRequestProvider = Provider<CouponRequest>((_) => CouponRequest());

/// List coupons. Family arg = vendorTypeId (0 = no filter).
final couponsByVendorTypeProvider = FutureProvider.family<List<Coupon>, int>((
  ref,
  vendorTypeId,
) async {
  return ref
      .read(couponRequestProvider)
      .fetchCoupons(
        params: vendorTypeId == 0 ? null : {'vendor_type_id': vendorTypeId},
      );
});

/// Detail coupon dengan kemampuan refresh. Family arg = couponId.
class CouponDetailsController extends FamilyAsyncNotifier<Coupon, int> {
  late int _id;

  @override
  Future<Coupon> build(int arg) async {
    _id = arg;
    return ref.read(couponRequestProvider).fetchCoupon(arg);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(couponRequestProvider).fetchCoupon(_id),
    );
  }
}

final couponDetailsControllerProvider =
    AsyncNotifierProvider.family<CouponDetailsController, Coupon, int>(
      CouponDetailsController.new,
    );
