import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/models/apple_login_data.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/services/auth.request.dart';
import 'package:fuodz/services/auth.service.dart';

final _authRequestProvider = Provider<AuthRequest>((_) => AuthRequest());

sealed class LoginPhase {
  const LoginPhase();
}

class LoginIdle extends LoginPhase {
  const LoginIdle();
}

class LoginAwaitingOtp extends LoginPhase {
  const LoginAwaitingOtp({this.verificationId, required this.phone});
  final String? verificationId;
  final String phone;
}

class LoginSuccess extends LoginPhase {
  const LoginSuccess();
}

class LoginNeedsRegister extends LoginPhase {
  const LoginNeedsRegister({this.email, this.name, this.phone});
  final String? email;
  final String? name;
  final String? phone;
}

class LoginFailure extends LoginPhase {
  const LoginFailure(this.message);
  final String message;
}

class LoginState {
  const LoginState({
    this.isBusy = false,
    this.phase = const LoginIdle(),
  });
  final bool isBusy;
  final LoginPhase phase;

  LoginState copyWith({bool? isBusy, LoginPhase? phase}) =>
      LoginState(
        isBusy: isBusy ?? this.isBusy,
        phase: phase ?? this.phase,
      );
}

class LoginController extends Notifier<LoginState> {
  StreamSubscription? _iosLoginSub;
  String? _accountPhoneNumber;
  String? _firebaseVerificationId;

  AuthRequest get authRequest => ref.read(_authRequestProvider);

  @override
  LoginState build() {
    ref.onDispose(() => _iosLoginSub?.cancel());
    return const LoginState();
  }

  /// Listen for iOS Apple login callback.
  void listenAppleCallback(Future<void> Function(AppleLoginData) onCallback) {
    _iosLoginSub?.cancel();
    _iosLoginSub = AppService().iosLogin.listen((data) async {
      if (data == null) return;
      await onCallback(data);
      AppService().clearAppleStream();
      await _iosLoginSub?.cancel();
      _iosLoginSub = null;
    });
  }

  Map<String, dynamic>? parseJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = _decodeBase64(parts[1]);
      final map = json.decode(payload);
      return map is Map<String, dynamic> ? map : null;
    } catch (_) {
      return null;
    }
  }

  String _decodeBase64(String str) {
    var output = str.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Invalid base64');
    }
    return utf8.decode(base64.decode(output));
  }

  Future<LoginPhase> processEmailLogin({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isBusy: true);
    final response = await authRequest.loginRequest(
      email: email,
      password: password,
    );
    return _handleDeviceLogin(response);
  }

  Future<LoginPhase> processOTPLogin(String phone, {
    required String countryPhoneCode,
    required bool isFirebaseOtp,
  }) async {
    _accountPhoneNumber = "+$countryPhoneCode$phone";
    state = state.copyWith(isBusy: true);
    final res = await authRequest.verifyPhoneAccount(_accountPhoneNumber!);
    if (!res.allGood) {
      final result = LoginFailure(res.message ?? 'Failed');
      state = state.copyWith(isBusy: false, phase: result);
      return result;
    }
    if (isFirebaseOtp) {
      return _processFirebaseOTPVerification();
    }
    return _processCustomOTPVerification();
  }

  Future<LoginPhase> _processFirebaseOTPVerification() async {
    state = state.copyWith(isBusy: true);
    final completer = Completer<LoginPhase>();
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _accountPhoneNumber,
      verificationCompleted: (credential) {},
      verificationFailed: (e) {
        if (!completer.isCompleted) {
          completer.complete(LoginFailure(e.message ?? 'Failed'));
        }
      },
      codeSent: (verificationId, _) {
        _firebaseVerificationId = verificationId;
        if (!completer.isCompleted) {
          completer.complete(LoginAwaitingOtp(
            verificationId: verificationId,
            phone: _accountPhoneNumber!,
          ));
        }
      },
      codeAutoRetrievalTimeout: (_) {},
    );
    final result = await completer.future;
    state = state.copyWith(isBusy: false, phase: result);
    return result;
  }

  Future<LoginPhase> _processCustomOTPVerification() async {
    try {
      await authRequest.sendOTP(_accountPhoneNumber!, null);
      final result = LoginAwaitingOtp(phone: _accountPhoneNumber!);
      state = state.copyWith(isBusy: false, phase: result);
      return result;
    } catch (e) {
      final result = LoginFailure('$e');
      state = state.copyWith(isBusy: false, phase: result);
      return result;
    }
  }

  Future<LoginPhase> verifyFirebaseOTP(String smsCode) async {
    state = state.copyWith(isBusy: true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _firebaseVerificationId!,
        smsCode: smsCode,
      );
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseToken = await userCredential.user!.getIdToken();
      final response = await authRequest.verifyFirebaseToken(
        _accountPhoneNumber!,
        firebaseToken!,
      );
      return _handleDeviceLogin(response);
    } catch (e) {
      final result = LoginFailure('$e');
      state = state.copyWith(isBusy: false, phase: result);
      return result;
    }
  }

  Future<LoginPhase> verifyCustomOTP(String smsCode) async {
    state = state.copyWith(isBusy: true);
    try {
      final response = await authRequest.verifyOTP(
        _accountPhoneNumber!,
        smsCode,
        isLogin: true,
      );
      return _handleDeviceLogin(response);
    } catch (e) {
      final result = LoginFailure('$e');
      state = state.copyWith(isBusy: false, phase: result);
      return result;
    }
  }

  Future<LoginPhase> resendCustomOTP() async {
    try {
      final response = await authRequest.sendOTP(_accountPhoneNumber!, null);
      return LoginAwaitingOtp(
        phone: _accountPhoneNumber!,
        verificationId: response.message,
      );
    } catch (e) {
      return LoginFailure('$e');
    }
  }

  Future<LoginPhase> processQrLogin(String loginCode) async {
    state = state.copyWith(isBusy: true);
    try {
      final response = await authRequest.qrLoginRequest(code: loginCode);
      return _handleDeviceLogin(response);
    } catch (e) {
      final result = LoginFailure('$e');
      state = state.copyWith(isBusy: false, phase: result);
      return result;
    }
  }

  Future<LoginPhase> handleDeviceLogin(ApiResponse response) =>
      _handleDeviceLogin(response);

  Future<LoginPhase> _handleDeviceLogin(ApiResponse response) async {
    try {
      if (response.hasError()) {
        final result = LoginFailure(response.message ?? 'Login failed');
        state = state.copyWith(isBusy: false, phase: result);
        return result;
      }
      final fbToken = response.body['fb_token'];
      if (fbToken != null && fbToken.toString().isNotEmpty) {
        await FirebaseAuth.instance.signInWithCustomToken(fbToken);
      }
      await AuthServices.saveUser(response.body['user']);
      await AuthServices.setAuthBearerToken(response.body['token']);
      await AuthServices.isAuthenticated();
      const result = LoginSuccess();
      state = state.copyWith(isBusy: false, phase: result);
      return result;
    } catch (e) {
      final result = LoginFailure('$e');
      state = state.copyWith(isBusy: false, phase: result);
      return result;
    }
  }

  void setBusy(bool value) {
    state = state.copyWith(isBusy: value);
  }
}

final loginControllerProvider =
    NotifierProvider<LoginController, LoginState>(LoginController.new);
