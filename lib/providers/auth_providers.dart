import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/services/auth.request.dart';
import 'package:fuodz/services/auth_services.dart';

// =============================================================================
// LoginResult sealed class — outcome dari login flow.
// =============================================================================
sealed class LoginResult {
  const LoginResult();
}

class LoginSuccess extends LoginResult {
  const LoginSuccess();
}

class LoginFailure extends LoginResult {
  const LoginFailure(this.message);
  final String message;
}

// =============================================================================
// PROVIDERS
// =============================================================================
final authRequestProvider = Provider<AuthRequest>((_) => AuthRequest());

/// Login controller. UI `ref.watch` ke isLoading, call `login()`/`qrLogin()`
/// dan terima `LoginResult` untuk drive navigation/alert.
class LoginController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  AuthRequest get _auth => ref.read(authRequestProvider);

  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final res = await _auth.loginRequest(email: email, password: password);
      final result = await _handle(res);
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return LoginFailure('$e');
    }
  }

  Future<LoginResult> loginWithPhone({
    required String phone,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final res = await _auth.loginHpRequest(phone: phone, password: password);
      final result = await _handle(res);
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return LoginFailure('$e');
    }
  }

  Future<LoginResult> qrLogin(String code) async {
    state = const AsyncLoading();
    try {
      final res = await _auth.qrLoginRequest(code: code);
      final result = await _handle(res);
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return LoginFailure('$e');
    }
  }

  // ===========================================================================
  // REGISTER
  // ===========================================================================
  Future<LoginResult> register({
    required String name,
    required String email,
    required String phone,
    required String countryCode,
    required String password,
    String code = '',
  }) async {
    state = const AsyncLoading();
    try {
      final res = await _auth.registerRequest(
        name: name,
        email: email,
        phone: phone,
        countryCode: countryCode,
        password: password,
        code: code,
      );
      final result = await _handle(res);
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return LoginFailure('$e');
    }
  }

  // ===========================================================================
  // RESET PASSWORD
  // ===========================================================================
  Future<LoginResult> resetPassword({
    required String phone,
    required String password,
    String? firebaseToken,
    String? customToken,
  }) async {
    state = const AsyncLoading();
    try {
      final res = await _auth.resetPasswordRequest(
        phone: phone,
        password: password,
        firebaseToken: firebaseToken,
        customToken: customToken,
      );
      state = const AsyncData(null);
      if (res.hasError()) {
        return LoginFailure(res.message ?? 'Reset password gagal');
      }
      return const LoginSuccess();
    } catch (e, st) {
      state = AsyncError(e, st);
      return LoginFailure('$e');
    }
  }

  Future<LoginResult> _handle(ApiResponse res) async {
    if (res.hasError()) return LoginFailure(res.message ?? 'Login gagal');
    final body = res.body;
    if (body is! Map) return const LoginFailure('Response tidak valid');
    final token = body['token']?.toString() ?? '';
    if (token.isEmpty) return const LoginFailure('Token kosong');
    await AuthServices.setAuthBearerToken(token);
    await AuthServices.saveUser(body['user']);
    await AuthServices.isAuthenticated();
    return const LoginSuccess();
  }
}

final loginControllerProvider =
    AsyncNotifierProvider<LoginController, void>(LoginController.new);
