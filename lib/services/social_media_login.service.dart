import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/auth.request.dart';

/// Callback API for social media login flows. Replaces the old
/// LoginViewModel-coupled interface so any Riverpod page can drive these.
typedef SocialLoginRegister = void Function({String? email, String? name});
typedef SocialLoginToast = void Function(String message);

class SocialMediaLoginService {
  final AuthRequest _authRequest = AuthRequest();

  Future<void> googleLogin({
    required Future<void> Function(ApiResponse) onApiResponse,
    required SocialLoginRegister onNeedsRegister,
    required SocialLoginToast onError,
    required void Function(bool) onBusy,
  }) async {
    onBusy(true);
    try {
      // serverClientId = Web Client ID (type:3) dari google-services.json
      // WAJIB agar idToken tidak null di Android
      final googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId:
            '1033816567831-l1c235q24i561jg1mdj57tb6entv66jr.apps.googleusercontent.com',
      );
      try {
        // Selalu disconnect dulu agar account picker selalu muncul
        if (await googleSignIn.isSignedIn()) {
          await googleSignIn.disconnect();
        }
        final googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          // User membatalkan login — jangan tampilkan error
          onBusy(false);
          return;
        }
        final googleAuth = await googleUser.authentication;
        final idToken = googleAuth.idToken;
        final accessToken = googleAuth.accessToken;

        if (idToken == null) {
          onError(
            'Google login gagal: idToken null. Pastikan SHA-1 sudah didaftarkan di Firebase Console.',
          );
          onBusy(false);
          return;
        }

        // Sign in ke Firebase dengan credential Google
        final credential = GoogleAuthProvider.credential(
          accessToken: accessToken,
          idToken: idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);

        // Kirim ke backend MBF
        try {
          final apiResponse = await _authRequest.socialLogin(
            googleUser.email,
            idToken,
            'google',
          );
          if (apiResponse != null) await onApiResponse(apiResponse);
        } catch (error) {
          final errStr = '$error';
          if (errStr.toLowerCase().contains('not found') ||
              errStr.toLowerCase().contains('register') ||
              errStr.toLowerCase().contains('404')) {
            onNeedsRegister(
              email: googleUser.email,
              name: googleUser.displayName,
            );
          } else {
            onError(errStr);
          }
        }
      } on FirebaseAuthException catch (error) {
        onError('Firebase: ${error.message ?? error.code}');
      } catch (error) {
        onError('Google: $error');
      }
    } catch (error) {
      onError('$error');
    }
    onBusy(false);
  }

  Future<void> facebookLogin({
    required Future<void> Function(ApiResponse) onApiResponse,
    required SocialLoginRegister onNeedsRegister,
    required SocialLoginToast onError,
  }) async {
    AlertService.showLoading();
    try {
      final result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );
      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken;
        if (accessToken == null) {
          throw "Facebook login failed".tr();
        }
        try {
          final credential = FacebookAuthProvider.credential(
            accessToken.tokenString,
          );
          final userAccount = await FirebaseAuth.instance.signInWithCredential(
            credential,
          );
          final apiResponse = await _authRequest.socialLogin(
            userAccount.user!.email!,
            accessToken.tokenString,
            'facebook',
          );
          AlertService.stopLoading();
          if (apiResponse != null) await onApiResponse(apiResponse);
        } on FirebaseAuthException catch (error) {
          AlertService.stopLoading();
          onError(error.message ?? '');
        } catch (error) {
          AlertService.stopLoading();
          onError('$error');
          if (error.toString().toLowerCase().contains('register')) {
            onNeedsRegister();
          }
        }
      } else {
        AlertService.stopLoading();
        onError(result.message ?? '');
      }
    } catch (error) {
      AlertService.stopLoading();
      onError('$error');
    }
  }

  Future<void> appleLoginAndroid({
    required Future<void> Function(ApiResponse) onApiResponse,
    required SocialLoginRegister onNeedsRegister,
    required SocialLoginToast onError,
  }) async {
    AlertService.showLoading();
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'com.aplikasii.mybalifriendz.service',
          redirectUri: Uri.parse(
            'https://mybalifriendz.co/auth/apple/callback',
          ),
        ),
      );
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );
      final userAccount = await FirebaseAuth.instance.signInWithCredential(
        oauthCredential,
      );
      try {
        final apiResponse = await _authRequest.socialLogin(
          userAccount.user!.email ?? '',
          credential.identityToken,
          'apple',
          uid: userAccount.user?.uid,
        );
        AlertService.stopLoading();
        if (apiResponse != null) await onApiResponse(apiResponse);
      } catch (error) {
        AlertService.stopLoading();
        onError('$error');
        if (error.toString().toLowerCase().contains('register')) {
          onNeedsRegister(
            email: userAccount.user?.email,
            name: userAccount.user?.displayName,
          );
        }
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      AlertService.stopLoading();
      if (e.code == AuthorizationErrorCode.canceled) return;
      onError(e.message);
    } catch (error) {
      AlertService.stopLoading();
      onError('$error');
    }
  }

  Future<void> appleLogin({
    required Future<void> Function(ApiResponse) onApiResponse,
    required SocialLoginRegister onNeedsRegister,
    required SocialLoginToast onError,
  }) async {
    AlertService.showLoading();
    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: credential.identityToken,
        rawNonce: rawNonce,
        accessToken: credential.authorizationCode,
      );
      final userAccount = await FirebaseAuth.instance.signInWithCredential(
        oauthCredential,
      );
      try {
        final apiResponse = await _authRequest.socialLogin(
          userAccount.user!.email ?? '',
          credential.identityToken,
          'apple',
          nonce: rawNonce,
          uid: userAccount.user?.uid,
        );
        AlertService.stopLoading();
        if (apiResponse != null) await onApiResponse(apiResponse);
      } catch (error) {
        AlertService.stopLoading();
        onError('$error');
        if (error.toString().toLowerCase().contains('register')) {
          onNeedsRegister(
            email: userAccount.user?.email,
            name: userAccount.user?.displayName,
          );
        }
      }
    } on FirebaseAuthException catch (error) {
      AlertService.stopLoading();
      onError(error.message ?? '');
    } catch (error) {
      AlertService.stopLoading();
      onError('$error');
    }
  }

  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
