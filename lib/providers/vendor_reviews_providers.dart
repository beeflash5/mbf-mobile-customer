import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/models/review.dart';
import 'package:fuodz/services/vendor.request.dart';

class VendorReviewsState {
  const VendorReviewsState({
    this.reviews = const [],
    this.page = 1,
    this.canLoadMore = true,
    this.isLoadingMore = false,
  });

  final List<Review> reviews;
  final int page;
  final bool canLoadMore;
  final bool isLoadingMore;

  VendorReviewsState copyWith({
    List<Review>? reviews,
    int? page,
    bool? canLoadMore,
    bool? isLoadingMore,
  }) =>
      VendorReviewsState(
        reviews: reviews ?? this.reviews,
        page: page ?? this.page,
        canLoadMore: canLoadMore ?? this.canLoadMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );
}

final _vendorRequestProvider =
    Provider<VendorRequest>((_) => VendorRequest());

/// Paginated reviews per vendor (family by vendorId).
class VendorReviewsController
    extends FamilyAsyncNotifier<VendorReviewsState, int> {
  late int _vendorId;

  @override
  Future<VendorReviewsState> build(int arg) async {
    _vendorId = arg;
    final reviews = await ref
        .read(_vendorRequestProvider)
        .getReviews(page: 1, vendorId: arg);
    return VendorReviewsState(
      reviews: reviews,
      page: 1,
      canLoadMore: reviews.isNotEmpty,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final reviews = await ref
          .read(_vendorRequestProvider)
          .getReviews(page: 1, vendorId: _vendorId);
      return VendorReviewsState(
        reviews: reviews,
        page: 1,
        canLoadMore: reviews.isNotEmpty,
      );
    });
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore || !current.canLoadMore) {
      return;
    }
    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final nextPage = current.page + 1;
      final more = await ref
          .read(_vendorRequestProvider)
          .getReviews(page: nextPage, vendorId: _vendorId);
      state = AsyncData(current.copyWith(
        reviews: [...current.reviews, ...more],
        page: nextPage,
        isLoadingMore: false,
        canLoadMore: more.isNotEmpty,
      ));
    } catch (_) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
      rethrow;
    }
  }
}

final vendorReviewsControllerProvider = AsyncNotifierProvider.family<
    VendorReviewsController, VendorReviewsState, int>(
  VendorReviewsController.new,
);
