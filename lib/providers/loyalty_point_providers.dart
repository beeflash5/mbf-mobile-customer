import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/models/loyalty_point.dart';
import 'package:fuodz/models/loyalty_point_report.dart';
import 'package:fuodz/services/loyalty_point.request.dart';
import 'package:fuodz/utils/app_finance_settings.dart';

final _loyaltyPointRequestProvider =
    Provider<LoyaltyPointRequest>((_) => LoyaltyPointRequest());

sealed class WithdrawResult {
  const WithdrawResult();
}

class WithdrawSuccess extends WithdrawResult {
  const WithdrawSuccess(this.message);
  final String message;
}

class WithdrawFailure extends WithdrawResult {
  const WithdrawFailure(this.message);
  final String message;
}

class LoyaltyPointState {
  const LoyaltyPointState({
    this.loyaltyPoint,
    this.estimatedAmount = 0,
    this.reports = const [],
    this.page = 1,
  });
  final LoyaltyPoint? loyaltyPoint;
  final double estimatedAmount;
  final List<LoyaltyPointReport> reports;
  final int page;

  LoyaltyPointState copyWith({
    LoyaltyPoint? loyaltyPoint,
    double? estimatedAmount,
    List<LoyaltyPointReport>? reports,
    int? page,
  }) =>
      LoyaltyPointState(
        loyaltyPoint: loyaltyPoint ?? this.loyaltyPoint,
        estimatedAmount: estimatedAmount ?? this.estimatedAmount,
        reports: reports ?? this.reports,
        page: page ?? this.page,
      );
}

class LoyaltyPointController extends AsyncNotifier<LoyaltyPointState> {
  @override
  Future<LoyaltyPointState> build() async => _load();

  Future<LoyaltyPointState> _load() async {
    final point =
        await ref.read(_loyaltyPointRequestProvider).getLoyaltyPoint();
    final estimated =
        point.points * double.parse(AppFinanceSettings.loyaltyPointsToAmount);
    final reports =
        await ref.read(_loyaltyPointRequestProvider).loyaltyPointReports(page: 1);
    return LoyaltyPointState(
      loyaltyPoint: point,
      estimatedAmount: estimated.toDouble(),
      reports: reports,
      page: 1,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> loadMore() async {
    final cur = state.valueOrNull;
    if (cur == null) return;
    final nextPage = cur.page + 1;
    try {
      final more = await ref
          .read(_loyaltyPointRequestProvider)
          .loyaltyPointReports(page: nextPage);
      state = AsyncData(cur.copyWith(
        reports: [...cur.reports, ...more],
        page: more.isEmpty ? cur.page : nextPage,
      ));
    } catch (_) {}
  }

  Future<WithdrawResult> withdrawPoints(String points) async {
    try {
      final res = await ref
          .read(_loyaltyPointRequestProvider)
          .withdrawPoints(points);
      if (res.allGood) {
        await refresh();
        return WithdrawSuccess(res.message ?? '');
      }
      return WithdrawFailure(res.message ?? '');
    } catch (e) {
      return WithdrawFailure('$e');
    }
  }
}

final loyaltyPointControllerProvider =
    AsyncNotifierProvider<LoyaltyPointController, LoyaltyPointState>(
  LoyaltyPointController.new,
);
