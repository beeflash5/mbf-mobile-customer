import 'dart:async';

import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/services/auth.request.dart';
import 'package:fuodz/services/phone_util.service.dart';

final _authRequestProvider = Provider<AuthRequest>((_) => AuthRequest());

sealed class ForgotPasswordPhase {
  const ForgotPasswordPhase();
}

class ForgotIdle extends ForgotPasswordPhase {
  const ForgotIdle();
}

class ForgotAwaitingOtp extends ForgotPasswordPhase {
  const ForgotAwaitingOtp({this.phone, this.email});
  final String? phone;
  final String? email;
}

class ForgotAwaitingPassword extends ForgotPasswordPhase {
  const ForgotAwaitingPassword();
}

class ForgotSuccess extends ForgotPasswordPhase {
  const ForgotSuccess(this.message);
  final String message;
}

class ForgotFailure extends ForgotPasswordPhase {
  const ForgotFailure(this.message);
  final String message;
}

class ForgotPasswordState {
  ForgotPasswordState({
    Country? selectedCountry,
    this.phase = const ForgotIdle(),
    this.isBusy = false,
  }) : selectedCountry =
           selectedCountry ??
           Country.parse(PhoneUtilService.countryCode ?? 'us');

  final Country selectedCountry;
  final ForgotPasswordPhase phase;
  final bool isBusy;

  ForgotPasswordState copyWith({
    Country? selectedCountry,
    ForgotPasswordPhase? phase,
    bool? isBusy,
  }) => ForgotPasswordState(
    selectedCountry: selectedCountry ?? this.selectedCountry,
    phase: phase ?? this.phase,
    isBusy: isBusy ?? this.isBusy,
  );
}

class ForgotPasswordController extends Notifier<ForgotPasswordState> {
  String? _accountPhoneNumber;
  String? _accountEmail;
  String? _firebaseVerificationId;
  String? _firebaseToken;

  @override
  ForgotPasswordState build() => ForgotPasswordState();

  void setCountry(Country country) {
    state = state.copyWith(selectedCountry: country);
  }

  /// Returns the phase after attempting to look up the phone account.
  Future<ForgotPasswordPhase> processForgotPassword({
    required String phone,
    required bool isCustomOtp,
  }) async {
    _accountPhoneNumber = "+${state.selectedCountry.phoneCode}$phone";
    state = state.copyWith(isBusy: true);
    final res = await ref
        .read(_authRequestProvider)
        .verifyPhoneAccount(_accountPhoneNumber!);
    if (!res.allGood) {
      final result = ForgotFailure(res.message ?? 'Failed');
      state = state.copyWith(isBusy: false, phase: result);
      return result;
    }
    _accountPhoneNumber = res.body['phone'];
    _accountEmail = res.body['email'];
    state = state.copyWith(isBusy: false);
    if (isCustomOtp) {
      return _processCustomForgotPassword();
    }
    return _processFirebaseForgotPassword();
  }

  Future<ForgotPasswordPhase> _processFirebaseForgotPassword() async {
    state = state.copyWith(isBusy: true);
    final completer = Completer<ForgotPasswordPhase>();
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _accountPhoneNumber,
      verificationCompleted: (credential) async {
        try {
          final userCredential = await FirebaseAuth.instance
              .signInWithCredential(credential);
          _firebaseToken = await userCredential.user?.getIdToken();
          _firebaseVerificationId = credential.verificationId;
          if (!completer.isCompleted) {
            completer.complete(const ForgotAwaitingPassword());
          }
        } catch (e) {
          if (!completer.isCompleted) completer.complete(ForgotFailure('$e'));
        }
      },
      verificationFailed: (e) {
        final msg =
            (e.code == 'invalid-phone-number')
                ? 'Invalid Phone Number'
                : (e.message ?? 'Error');
        if (!completer.isCompleted) completer.complete(ForgotFailure(msg));
      },
      codeSent: (verificationId, _) {
        _firebaseVerificationId = verificationId;
        if (!completer.isCompleted) {
          completer.complete(
            ForgotAwaitingOtp(phone: _accountPhoneNumber, email: _accountEmail),
          );
        }
      },
      codeAutoRetrievalTimeout: (_) {},
    );
    final result = await completer.future;
    state = state.copyWith(isBusy: false, phase: result);
    return result;
  }

  Future<ForgotPasswordPhase> _processCustomForgotPassword() async {
    state = state.copyWith(isBusy: true);
    try {
      await ref.read(_authRequestProvider).sendOTP(_accountPhoneNumber!, null);
      final result = ForgotAwaitingOtp(
        phone: _accountPhoneNumber,
        email: _accountEmail,
      );
      state = state.copyWith(isBusy: false, phase: result);
      return result;
    } catch (e) {
      final result = ForgotFailure('$e');
      state = state.copyWith(isBusy: false, phase: result);
      return result;
    }
  }

  Future<ForgotPasswordPhase> verifyFirebaseOTP(String smsCode) async {
    state = state.copyWith(isBusy: true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _firebaseVerificationId!,
        smsCode: smsCode,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      _firebaseToken = await userCredential.user?.getIdToken();
      const result = ForgotAwaitingPassword();
      state = state.copyWith(isBusy: false, phase: result);
      return result;
    } catch (e) {
      final result = ForgotFailure('$e');
      state = state.copyWith(isBusy: false, phase: result);
      return result;
    }
  }

  Future<ForgotPasswordPhase> verifyCustomOTP(String smsCode) async {
    state = state.copyWith(isBusy: true);
    try {
      final response = await ref
          .read(_authRequestProvider)
          .verifyOTP(_accountPhoneNumber!, smsCode);
      _firebaseToken = response.body['token'];
      const result = ForgotAwaitingPassword();
      state = state.copyWith(isBusy: false, phase: result);
      return result;
    } catch (e) {
      final result = ForgotFailure('$e');
      state = state.copyWith(isBusy: false, phase: result);
      return result;
    }
  }

  Future<ForgotPasswordPhase> finishChangeAccountPassword({
    required String password,
    required bool isCustomOtp,
  }) async {
    state = state.copyWith(isBusy: true);
    final response = await ref
        .read(_authRequestProvider)
        .resetPasswordRequest(
          phone: _accountPhoneNumber!,
          password: password,
          firebaseToken: isCustomOtp ? null : _firebaseToken,
          customToken: isCustomOtp ? _firebaseToken : null,
        );
    final result =
        response.allGood
            ? ForgotSuccess(response.message ?? '')
            : ForgotFailure(response.message ?? 'Failed');
    state = state.copyWith(isBusy: false, phase: result);
    return result;
  }

  Future<String?> resendCustomOTP() async {
    try {
      final response = await ref
          .read(_authRequestProvider)
          .sendOTP(_accountPhoneNumber!, null);
      return response.message;
    } catch (_) {
      return null;
    }
  }
}

final forgotPasswordControllerProvider =
    NotifierProvider<ForgotPasswordController, ForgotPasswordState>(
      ForgotPasswordController.new,
    );
