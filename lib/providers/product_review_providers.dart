import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/models/product.dart';
import 'package:fuodz/models/product_review.dart';
import 'package:fuodz/models/product_review_stat.dart';
import 'package:fuodz/services/product.request.dart';

final _productRequestProvider =
    Provider<ProductRequest>((_) => ProductRequest());

sealed class ProductReviewSubmissionResult {
  const ProductReviewSubmissionResult();
}

class ProductReviewSubmissionSuccess extends ProductReviewSubmissionResult {
  const ProductReviewSubmissionSuccess();
}

class ProductReviewSubmissionFailure extends ProductReviewSubmissionResult {
  const ProductReviewSubmissionFailure(this.message);
  final String message;
}

class ProductReviewState {
  const ProductReviewState({
    this.reviews = const [],
    this.stats = const [],
    this.page = 1,
    this.loadingMore = false,
  });
  final List<ProductReview> reviews;
  final List<ProductReviewStat> stats;
  final int page;
  final bool loadingMore;

  ProductReviewState copyWith({
    List<ProductReview>? reviews,
    List<ProductReviewStat>? stats,
    int? page,
    bool? loadingMore,
  }) =>
      ProductReviewState(
        reviews: reviews ?? this.reviews,
        stats: stats ?? this.stats,
        page: page ?? this.page,
        loadingMore: loadingMore ?? this.loadingMore,
      );
}

typedef ProductReviewArgs = ({Product product, bool summary});

class ProductReviewController
    extends FamilyAsyncNotifier<ProductReviewState, ProductReviewArgs> {
  late ProductReviewArgs _args;

  @override
  Future<ProductReviewState> build(ProductReviewArgs arg) async {
    _args = arg;
    final stats = await _fetchSummary(arg);
    if (arg.summary) return ProductReviewState(stats: stats.stats, reviews: stats.reviews);
    final reviews = await _fetchReviews(arg.product.id, 1);
    return ProductReviewState(
      reviews: reviews,
      stats: stats.stats,
      page: 1,
    );
  }

  Future<({List<ProductReviewStat> stats, List<ProductReview> reviews})>
      _fetchSummary(ProductReviewArgs arg) async {
    final res = await ref.read(_productRequestProvider).productReviewSummary(
      queryParams: {'id': arg.product.id},
    );
    final body = res.body as Map;
    final reviews = (body['latest_reviews'] as List)
        .map((e) => ProductReview.fromJson(e))
        .toList();
    final stats = (body['rating_summary'] as List)
        .map((e) => ProductReviewStat.fromJson(e))
        .toList();
    return (stats: stats, reviews: reviews);
  }

  Future<List<ProductReview>> _fetchReviews(int productId, int page) async {
    return ref.read(_productRequestProvider).productReviews(
      page: page,
      queryParams: {'product_id': productId},
    );
  }

  Future<void> loadMore() async {
    final cur = state.valueOrNull;
    if (cur == null || cur.loadingMore) return;
    state = AsyncData(cur.copyWith(loadingMore: true));
    final next = cur.page + 1;
    try {
      final more = await _fetchReviews(_args.product.id, next);
      state = AsyncData(cur.copyWith(
        reviews: [...cur.reviews, ...more],
        page: more.isEmpty ? cur.page : next,
        loadingMore: false,
      ));
    } catch (_) {
      state = AsyncData(cur.copyWith(loadingMore: false));
    }
  }

  Future<ProductReviewSubmissionResult> submitReview({
    required double rating,
    required String review,
    int? orderId,
  }) async {
    try {
      final res = await ref.read(_productRequestProvider).submitReview(
        params: {
          'product_id': _args.product.id,
          'order_id': orderId,
          'rating': rating,
          'review': review,
        },
      );
      if (res.allGood) return const ProductReviewSubmissionSuccess();
      return ProductReviewSubmissionFailure(res.message ?? '');
    } catch (e) {
      return ProductReviewSubmissionFailure('$e');
    }
  }
}

final productReviewControllerProvider = AsyncNotifierProvider.family<
    ProductReviewController, ProductReviewState, ProductReviewArgs>(
  ProductReviewController.new,
);
