import 'dart:async';

import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/services/auth.request.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/phone_util.service.dart';

final _authRequestProvider = Provider<AuthRequest>((_) => AuthRequest());

sealed class RegisterPhase {
  const RegisterPhase();
}

class RegisterIdle extends RegisterPhase {
  const RegisterIdle();
}

class RegisterAwaitingOtp extends RegisterPhase {
  const RegisterAwaitingOtp({this.firebaseVerificationId});
  final String? firebaseVerificationId;
}

class RegisterSuccess extends RegisterPhase {
  const RegisterSuccess();
}

class RegisterFailure extends RegisterPhase {
  const RegisterFailure(this.message);
  final String message;
}

class RegisterState {
  RegisterState({
    Country? selectedCountry,
    this.agreed = false,
    this.phase = const RegisterIdle(),
    this.isBusy = false,
  }) : selectedCountry =
           selectedCountry ??
           Country.parse(PhoneUtilService.countryCode ?? 'us');

  final Country selectedCountry;
  final bool agreed;
  final RegisterPhase phase;
  final bool isBusy;

  RegisterState copyWith({
    Country? selectedCountry,
    bool? agreed,
    RegisterPhase? phase,
    bool? isBusy,
  }) => RegisterState(
    selectedCountry: selectedCountry ?? this.selectedCountry,
    agreed: agreed ?? this.agreed,
    phase: phase ?? this.phase,
    isBusy: isBusy ?? this.isBusy,
  );
}

class RegisterController extends Notifier<RegisterState> {
  String? _accountPhoneNumber;
  String? _firebaseVerificationId;

  @override
  RegisterState build() => RegisterState();

  void setCountry(Country country) {
    state = state.copyWith(selectedCountry: country);
  }

  void setAgreed(bool value) {
    state = state.copyWith(agreed: value);
  }

  /// Returns:
  /// - `RegisterSuccess` when registration completes
  /// - `RegisterAwaitingOtp` when SMS-based verification is pending
  /// - `RegisterFailure` on error
  Future<RegisterPhase> processRegister({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String referralCode,
    required bool isFirebaseOtp,
    required bool isCustomOtp,
  }) async {
    _accountPhoneNumber = "+${state.selectedCountry.phoneCode}$phone";
    if (isFirebaseOtp) {
      return _processFirebaseOTPVerification();
    }
    if (isCustomOtp) {
      return _processCustomOTPVerification(email);
    }
    return _finishAccountRegistration(
      name: name,
      email: email,
      password: password,
      referralCode: referralCode,
    );
  }

  Future<RegisterPhase> _processFirebaseOTPVerification() async {
    state = state.copyWith(isBusy: true);
    final completer = Completer<RegisterPhase>();
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _accountPhoneNumber,
      verificationCompleted: (credential) {
        if (!completer.isCompleted) {
          completer.complete(const RegisterAwaitingOtp());
        }
      },
      verificationFailed: (e) {
        final msg =
            (e.code == 'invalid-phone-number')
                ? 'Invalid Phone Number'
                : (e.message ?? 'Failed');
        if (!completer.isCompleted) completer.complete(RegisterFailure(msg));
      },
      codeSent: (verificationId, _) {
        _firebaseVerificationId = verificationId;
        if (!completer.isCompleted) {
          completer.complete(
            RegisterAwaitingOtp(firebaseVerificationId: verificationId),
          );
        }
      },
      codeAutoRetrievalTimeout: (_) {},
    );
    final result = await completer.future;
    state = state.copyWith(isBusy: false, phase: result);
    return result;
  }

  Future<RegisterPhase> _processCustomOTPVerification(String email) async {
    state = state.copyWith(isBusy: true);
    try {
      await ref.read(_authRequestProvider).sendOTP(_accountPhoneNumber!, email);
      final result = const RegisterAwaitingOtp();
      state = state.copyWith(isBusy: false, phase: result);
      return result;
    } catch (e) {
      final result = RegisterFailure('$e');
      state = state.copyWith(isBusy: false, phase: result);
      return result;
    }
  }

  Future<RegisterPhase> verifyFirebaseOTP(
    String smsCode, {
    required String name,
    required String email,
    required String password,
    required String referralCode,
  }) async {
    state = state.copyWith(isBusy: true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _firebaseVerificationId!,
        smsCode: smsCode,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      return _finishAccountRegistration(
        name: name,
        email: email,
        password: password,
        referralCode: referralCode,
      );
    } catch (e) {
      final result = RegisterFailure('$e');
      state = state.copyWith(isBusy: false, phase: result);
      return result;
    }
  }

  Future<RegisterPhase> verifyCustomOTP(
    String smsCode, {
    required String name,
    required String email,
    required String password,
    required String referralCode,
  }) async {
    state = state.copyWith(isBusy: true);
    try {
      await ref
          .read(_authRequestProvider)
          .verifyOTP(_accountPhoneNumber!, smsCode);
      return _finishAccountRegistration(
        name: name,
        email: email,
        password: password,
        referralCode: referralCode,
      );
    } catch (e) {
      final result = RegisterFailure('$e');
      state = state.copyWith(isBusy: false, phase: result);
      return result;
    }
  }

  Future<RegisterPhase> resendCustomOTP(String email) async {
    try {
      final response = await ref
          .read(_authRequestProvider)
          .sendOTP(_accountPhoneNumber!, email);
      return RegisterAwaitingOtp(firebaseVerificationId: response.message);
    } catch (e) {
      return RegisterFailure('$e');
    }
  }

  Future<RegisterPhase> _finishAccountRegistration({
    required String name,
    required String email,
    required String password,
    required String referralCode,
  }) async {
    state = state.copyWith(isBusy: true);
    try {
      final response = await ref
          .read(_authRequestProvider)
          .registerRequest(
            name: name,
            email: email,
            phone: _accountPhoneNumber!,
            countryCode: state.selectedCountry.countryCode,
            password: password,
            code: referralCode,
          );
      if (response.hasError()) {
        final result = RegisterFailure(
          response.message ?? 'Registration Failed',
        );
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
      const result = RegisterSuccess();
      state = state.copyWith(isBusy: false, phase: result);
      return result;
    } catch (e) {
      final result = RegisterFailure('$e');
      state = state.copyWith(isBusy: false, phase: result);
      return result;
    }
  }
}

final registerControllerProvider =
    NotifierProvider<RegisterController, RegisterState>(RegisterController.new);
