import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/models/wallet.dart';
import 'package:fuodz/models/wallet_transaction.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/services/wallet.request.dart';

final _walletRequestProvider =
    Provider<WalletRequest>((_) => WalletRequest());

class WalletState {
  const WalletState({
    this.wallet,
    this.transactions = const [],
    this.page = 1,
    this.isLoadingMore = false,
  });
  final Wallet? wallet;
  final List<WalletTransaction> transactions;
  final int page;
  final bool isLoadingMore;

  WalletState copyWith({
    Wallet? wallet,
    List<WalletTransaction>? transactions,
    int? page,
    bool? isLoadingMore,
  }) =>
      WalletState(
        wallet: wallet ?? this.wallet,
        transactions: transactions ?? this.transactions,
        page: page ?? this.page,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );
}

sealed class WalletTopupResult {
  const WalletTopupResult();
}

class WalletTopupSuccess extends WalletTopupResult {
  const WalletTopupSuccess(this.link);
  final String link;
}

class WalletTopupFailure extends WalletTopupResult {
  const WalletTopupFailure(this.message);
  final String message;
}

class WalletController extends AsyncNotifier<WalletState> {
  StreamSubscription<bool>? _sub;

  @override
  Future<WalletState> build() async {
    _sub?.cancel();
    _sub = AppService().refreshWalletBalance.listen((_) => refresh());
    ref.onDispose(() => _sub?.cancel());
    return _fetch();
  }

  Future<WalletState> _fetch() async {
    final req = ref.read(_walletRequestProvider);
    final wallet = await req.walletBalance();
    final transactions = await req.walletTransactions(page: 1);
    return WalletState(wallet: wallet, transactions: transactions, page: 1);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> loadMore() async {
    final cur = state.valueOrNull;
    if (cur == null || cur.isLoadingMore) return;
    state = AsyncData(cur.copyWith(isLoadingMore: true));
    try {
      final next = cur.page + 1;
      final more =
          await ref.read(_walletRequestProvider).walletTransactions(page: next);
      state = AsyncData(cur.copyWith(
        transactions: [...cur.transactions, ...more],
        page: next,
        isLoadingMore: false,
      ));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<WalletTopupResult> initiateTopUp(String amount) async {
    try {
      final link = await ref.read(_walletRequestProvider).walletTopup(amount);
      return WalletTopupSuccess(link);
    } catch (e) {
      return WalletTopupFailure('$e');
    }
  }

  /// Returns the `ApiResponse` for the address screen. Page handles the modal.
  Future<dynamic> fetchMyWalletAddress() {
    return ref.read(_walletRequestProvider).myWalletAddress();
  }
}

final walletControllerProvider =
    AsyncNotifierProvider<WalletController, WalletState>(
  WalletController.new,
);
