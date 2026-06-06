import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/models/user.dart';
import 'package:fuodz/services/wallet.request.dart';

sealed class WalletTransferResult {
  const WalletTransferResult();
}

class WalletTransferSuccess extends WalletTransferResult {
  const WalletTransferSuccess(this.message);
  final String message;
}

class WalletTransferFailure extends WalletTransferResult {
  const WalletTransferFailure(this.message);
  final String message;
}

final _walletRequestProvider =
    Provider<WalletRequest>((_) => WalletRequest());

/// State controller wallet transfer: selectedUser + busy.
class WalletTransferController extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async => null;

  void selectUser(User user) => state = AsyncData(user);

  Future<List<User>> searchUsers(String keyword) async {
    if (keyword.isEmpty) return [];
    final res =
        await ref.read(_walletRequestProvider).getWalletAddress(keyword);
    if (!res.allGood) return [];
    return (res.body['users'] as List)
        .map((e) => User.fromJson(e))
        .toList();
  }

  Future<WalletTransferResult> submit({
    required String amount,
    required String password,
  }) async {
    final user = state.valueOrNull;
    if (user == null) {
      return const WalletTransferFailure('Please select recipient');
    }
    state = const AsyncLoading();
    try {
      final res = await ref.read(_walletRequestProvider).transferWallet(
            amount,
            user.walletAddress,
            password,
          );
      state = AsyncData(user);
      return res.allGood
          ? WalletTransferSuccess(res.message ?? 'Operation successful')
          : WalletTransferFailure(res.message ?? 'Operation failed');
    } catch (e, st) {
      state = AsyncError(e, st);
      return WalletTransferFailure('$e');
    }
  }
}

final walletTransferControllerProvider =
    AsyncNotifierProvider<WalletTransferController, User?>(
  WalletTransferController.new,
);
