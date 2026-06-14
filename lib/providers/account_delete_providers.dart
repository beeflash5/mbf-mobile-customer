import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/services/auth.request.dart';
import 'package:fuodz/services/auth.service.dart';

/// Hasil aksi delete account.
sealed class AccountDeleteResult {
  const AccountDeleteResult();
}

class AccountDeleteSuccess extends AccountDeleteResult {
  const AccountDeleteSuccess(this.message);
  final String message;
}

class AccountDeleteFailure extends AccountDeleteResult {
  const AccountDeleteFailure(this.message);
  final String message;
}

final accountDeleteAuthRequestProvider = Provider<AuthRequest>(
  (_) => AuthRequest(),
);

/// Controller delete-account. Page memanggil `delete(password)`,
/// menangkap [AccountDeleteResult] untuk navigasi/alert.
class AccountDeleteController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  AuthRequest get _auth => ref.read(accountDeleteAuthRequestProvider);

  Future<AccountDeleteResult> delete({required String password}) async {
    state = const AsyncLoading();
    try {
      final res = await _auth.deleteProfile(password: password);
      state = const AsyncData(null);
      if (res.allGood) {
        await AuthServices.logout();
        return AccountDeleteSuccess(res.message ?? 'Account deleted');
      }
      return AccountDeleteFailure(res.message ?? 'Delete account gagal');
    } catch (e, st) {
      state = AsyncError(e, st);
      return AccountDeleteFailure('$e');
    }
  }
}

final accountDeleteControllerProvider =
    AsyncNotifierProvider<AccountDeleteController, void>(
      AccountDeleteController.new,
    );
