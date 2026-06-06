import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/services/auth.request.dart';

sealed class ChangePasswordResult {
  const ChangePasswordResult();
}

class ChangePasswordSuccess extends ChangePasswordResult {
  const ChangePasswordSuccess(this.message);
  final String message;
}

class ChangePasswordFailure extends ChangePasswordResult {
  const ChangePasswordFailure(this.message);
  final String message;
}

final changePasswordAuthRequestProvider =
    Provider<AuthRequest>((_) => AuthRequest());

class ChangePasswordController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  AuthRequest get _auth => ref.read(changePasswordAuthRequestProvider);

  Future<ChangePasswordResult> submit({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = const AsyncLoading();
    try {
      final res = await _auth.updatePassword(
        password: currentPassword,
        new_password: newPassword,
        new_password_confirmation: confirmPassword,
      );
      state = const AsyncData(null);
      return res.allGood
          ? ChangePasswordSuccess(res.message ?? 'Password updated')
          : ChangePasswordFailure(res.message ?? 'Update password gagal');
    } catch (e, st) {
      state = AsyncError(e, st);
      return ChangePasswordFailure('$e');
    }
  }
}

final changePasswordControllerProvider =
    AsyncNotifierProvider<ChangePasswordController, void>(
  ChangePasswordController.new,
);
