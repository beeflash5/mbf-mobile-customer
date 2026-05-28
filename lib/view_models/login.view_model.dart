import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fuodz/constants/api.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/extensions/context.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/models/apple_login_data.dart';
import 'package:fuodz/requests/auth.request.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/phone_util.service.dart';
import 'package:fuodz/services/social_media_login.service.dart';
import 'package:fuodz/traits/qrcode_scanner.trait.dart';
import 'package:fuodz/view_models/payment.view_model.dart';
import 'package:fuodz/views/pages/auth/forgot_password.page.dart';
import 'package:fuodz/views/pages/auth/register.page.dart';
import 'package:fuodz/views/pages/home.page.dart';
import 'package:fuodz/views/pages/payment/custom_webview.page.dart';
import 'package:fuodz/widgets/bottomsheets/account_verification_entry.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:velocity_x/velocity_x.dart';

import 'base.view_model.dart';

class LoginViewModel extends MyBaseViewModel with QrcodeScannerTrait {
  //the textediting controllers
  TextEditingController phoneTEC = new TextEditingController();
  TextEditingController emailTEC = new TextEditingController();
  TextEditingController passwordTEC = new TextEditingController();

  //
  AuthRequest authRequest = AuthRequest();
  SocialMediaLoginService socialMediaLoginService = SocialMediaLoginService();
  bool otpLogin = AppStrings.enableOTPLogin;
  Country? selectedCountry;
  String? accountPhoneNumber;
  bool useOtp = false;

  StreamSubscription? iosLogin;

  LoginViewModel(BuildContext context) {
    this.viewContext = context;
  }
  bool isHandlingApple = false;
  void initialise() async {
    //
    emailTEC.text = kReleaseMode ? "" : "client@demo.com";
    passwordTEC.text = kReleaseMode ? "" : "password";

    //phone login
    String countryCode = PhoneUtilService.countryCode ?? "us";
    this.selectedCountry = Country.parse(countryCode);

    iosLogin = AppService().iosLogin.listen((data) async {
      if (data == null) return; // 🔥 skip null

      await handleAppleCallback(data);

      // 🔥 OPTIONAL reset (biar clean)
      AppService().clearAppleStream();

      // 🔥 STOP listener biar gak double
      await iosLogin?.cancel();
      iosLogin = null;
    });
  }

  dispose() {
    super.dispose();
    iosLogin?.cancel();
  }

  Map<String, dynamic>? parseJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('invalid token');
      }

      final payload = _decodeBase64(parts[1]);
      final payloadMap = json.decode(payload);

      if (payloadMap is! Map<String, dynamic>) {
        throw Exception('invalid payload');
      }

      return payloadMap;
    } catch (e) {
      print("parseJwt error: $e");
      return null;
    }
  }

  String _decodeBase64(String str) {
    // 🔥 FIX base64url → base64
    String output = str.replaceAll('-', '+').replaceAll('_', '/');

    // 🔥 padding
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

  Future<void> handleAppleCallback(AppleLoginData data) async {
     setBusy(true);
    bool isLoadingShown = false;

    try {
      // 🔥 biar UI gak hitam pas balik dari Chrome
      await Future.delayed(const Duration(milliseconds: 300));

      // AlertService.showLoading();
      isLoadingShown = true;

      final idToken = data.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw Exception("ID TOKEN NULL");
      }

      final payload = parseJwt(idToken);
      final email = payload?['email'];

      print("apple android --> email: $email");

      final apiResponse = await authRequest.loginAppleAndroid(
        email ?? "",
        idToken,
        "apple",
      );

      // 🔥 kalau user close tab / cancel
      if (apiResponse == null) {
        print("apple android --> USER CANCEL");
        return;
      }

      // 🔥 delay biar navigator aman
      await Future.delayed(const Duration(milliseconds: 200));

      if (apiResponse.hasError()) {
        AlertService.error(title: "Login Failed", text: apiResponse.message);
        return;
      }

      await handleDeviceLogin(apiResponse);
    } catch (e) {
      final msg = e.toString();

      print("apple android --> ERROR: $msg");

      // 🔥 HANDLE USER CANCEL BIAR GA ERROR
      if (msg.contains("canceled") || msg.contains("closed the Custom Tab")) {
        print("apple android --> USER CANCEL DETECTED");
        return;
      }

      toastError(msg);
    } finally {
      // 🔥 INI PENTING: jangan pop kalau gak ada dialog
      if (isLoadingShown) {
        await Future.delayed(const Duration(milliseconds: 150));

        if (Navigator.canPop(viewContext)) {
          Navigator.pop(viewContext);
        }
      }
    }
  }

  setUseOtp(bool use) {
    useOtp = use;
    print("masuk");
    notifyListeners();
  }

  toggleLoginType() {
    otpLogin = !otpLogin;
    notifyListeners();
  }

  showCountryDialPicker() {
    showCountryPicker(
      context: viewContext,
      showPhoneCode: true,
      onSelect: countryCodeSelected,
    );
  }

  countryCodeSelected(Country country) {
    selectedCountry = country;
    notifyListeners();
  }

  void processHpLogin() async {
    // accountPhoneNumber = "+${selectedCountry?.phoneCode}${phoneTEC.text}";
    // Validate returns true if the form is valid, otherwise false.
    if (formKey.currentState!.validate()) {
      //

      setBusy(true);

      final apiResponse = await authRequest.loginRequest(
        email: emailTEC.text,
        password: passwordTEC.text,
      );
      // final apiResponse = await authRequest.loginHpRequest(
      //   phone: accountPhoneNumber!,
      //   password: passwordTEC.text,
      // );
      setBusy(false);

      //
      await handleDeviceLogin(apiResponse);
    }
  }

  void processOTPLogin() async {
    //
    accountPhoneNumber = "+${selectedCountry?.phoneCode}${phoneTEC.text}";
    // Validate returns true if the form is valid, otherwise false.
    if (formKey.currentState!.validate()) {
      //

      setBusyForObject(otpLogin, true);
      //phone number verification
      final apiResponse = await authRequest.verifyPhoneAccount(
        accountPhoneNumber!,
      );

      if (!apiResponse.allGood) {
        AlertService.error(title: "Login".tr(), text: apiResponse.message);
        setBusyForObject(otpLogin, false);
        return;
      }

      setBusyForObject(otpLogin, false);
      //
      if (AppStrings.isFirebaseOtp) {
        processFirebaseOTPVerification();
      } else {
        processCustomOTPVerification();
      }
    }
  }

  //PROCESSING VERIFICATION
  processFirebaseOTPVerification() async {
    setBusyForObject(otpLogin, true);
    //firebase authentication
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: accountPhoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {
        // firebaseVerificationId = credential.verificationId;
        // verifyFirebaseOTP(credential.smsCode);
        print("verificationCompleted ==>  Yes");
        // finishOTPLogin(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        // log("Error message ==> ${e.message}");
        if (e.code == 'invalid-phone-number') {
          viewContext.showToast(
            msg: "Invalid Phone Number".tr(),
            bgColor: Colors.red,
          );
        } else {
          viewContext.showToast(
            msg: e.message ?? "Failed".tr(),
            bgColor: Colors.red,
          );
        }
        //
        setBusyForObject(otpLogin, false);
      },
      codeSent: (String verificationId, int? resendToken) async {
        firebaseVerificationId = verificationId;
        print("codeSent ==>  $firebaseVerificationId");
        showVerificationEntry();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print("codeAutoRetrievalTimeout called");
      },
    );
    setBusyForObject(otpLogin, false);
  }

  processCustomOTPVerification() async {
    setBusyForObject(otpLogin, true);
    try {
      await authRequest.sendOTP(accountPhoneNumber!, null);
      setBusyForObject(otpLogin, false);
      showVerificationEntry();
    } catch (error) {
      setBusyForObject(otpLogin, false);
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
  }

  //
  void showVerificationEntry() async {
    //
    setBusy(false);
    //
    await viewContext.push(
      (context) => AccountVerificationEntry(
        vm: this,
        phone: accountPhoneNumber!,
        onSubmit: (smsCode) {
          //
          if (AppStrings.isFirebaseOtp) {
            verifyFirebaseOTP(smsCode);
          } else {
            verifyCustomOTP(smsCode);
          }

          viewContext.pop();
        },
        onResendCode: () async {
          if (!AppStrings.isCustomOtp) {
            return;
          }
          try {
            final response = await authRequest.sendOTP(
              accountPhoneNumber!,
              null,
            );
            toastSuccessful(response.message ?? "Code sent successfully".tr());
          } catch (error) {
            viewContext.showToast(msg: "$error", bgColor: Colors.red);
          }
        },
      ),
    );
  }

  //
  void verifyFirebaseOTP(String smsCode) async {
    //
    setBusyForObject(otpLogin, true);

    // Sign the user in (or link) with the credential
    try {
      // Create a PhoneAuthCredential with the code
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: firebaseVerificationId!,
        smsCode: smsCode,
      );

      //
      await finishOTPLogin(phoneAuthCredential);
    } catch (error) {
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
    //
    setBusyForObject(otpLogin, false);
  }

  void verifyCustomOTP(String smsCode) async {
    //
    setBusy(true);
    // Sign the user in (or link) with the credential
    try {
      final apiResponse = await authRequest.verifyOTP(
        accountPhoneNumber!,
        smsCode,
        isLogin: true,
      );

      //
      setBusy(false);
      await handleDeviceLogin(apiResponse);
    } catch (error) {
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
    setBusy(false);
    //
  }

  //Login to with firebase token
  finishOTPLogin(AuthCredential authCredential) async {
    //
    setBusyForObject(otpLogin, true);
    // Sign the user in (or link) with the credential
    try {
      //
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        authCredential,
      );
      //
      String? firebaseToken = await userCredential.user!.getIdToken();
      final apiResponse = await authRequest.verifyFirebaseToken(
        accountPhoneNumber!,
        firebaseToken!,
      );
      //
      setBusyForObject(otpLogin, false);
      await handleDeviceLogin(apiResponse);
    } catch (error) {
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
    //
    setBusyForObject(otpLogin, false);
  }

  //REGULAR LOGIN
  void processLogin() async {
    // Validate returns true if the form is valid, otherwise false.
    if (formKey.currentState!.validate()) {
      //

      setBusy(true);

      final apiResponse = await authRequest.loginRequest(
        email: emailTEC.text,
        password: passwordTEC.text,
      );
      setBusy(false);

      //
      await handleDeviceLogin(apiResponse);
    }
  }

  //QRCode login
  void initateQrcodeLogin() async {
    //
    final loginCode = await openScanner(viewContext);
    if (loginCode == null) {
      toastError("Operation failed/cancelled".tr());
    } else {
      setBusy(true);

      try {
        final apiResponse = await authRequest.qrLoginRequest(code: loginCode);
        //
        setBusy(false);
        await handleDeviceLogin(apiResponse);
      } catch (error) {
        print("QR Code login error ==> $error");
      }
      setBusy(false);
    }
  }

  ///
  ///
  ///
  handleDeviceLogin(ApiResponse apiResponse) async {
    try {
      if (apiResponse.hasError()) {
        //there was an error
        AlertService.error(
          title: "Server Login Failed".tr(),
          text: apiResponse.message,
        );
      } else {
        //everything works well
        //firebase auth
        setBusy(true);
        final fbToken = apiResponse.body["fb_token"];
        await FirebaseAuth.instance.signInWithCustomToken(fbToken);
        await AuthServices.saveUser(apiResponse.body["user"]);
        await AuthServices.setAuthBearerToken(apiResponse.body["token"]);
        await AuthServices.isAuthenticated();
        setBusy(false);
        //go to home
        // Navigator.of(viewContext).pushNamedAndRemoveUntil(
        //   AppRoutes.homeRoute,
        //   (_) => false,
        // );
        viewContext.nextAndRemoveUntilPage(HomePage());
      }
    } on FirebaseAuthException catch (error) {
      AlertService.error(
        title: ("FirebaseAuthException " + "Login Failed".tr()),
        text: "${error.message}",
      );
    } catch (error) {
      AlertService.error(title: "Login Failed".tr(), text: "${error}");
    }
  }

  ///

  void openRegister({String? email, String? name, String? phone}) async {
    Navigator.of(viewContext).push(
      MaterialPageRoute(
        builder:
            (context) => RegisterPage(email: email, name: name, phone: phone),
      ),
    );
  }

  void openForgotPassword() {
    Navigator.of(
      viewContext,
    ).push(MaterialPageRoute(builder: (context) => ForgotPasswordPage()));
  }

  openPrivacyPolicy() async {
    final url = Api.privacyPolicy;
    openWebpageLink(url);
  }

  openTerms() {
    final url = Api.terms;
    openWebpageLink(url);
  }

  Future<dynamic> openWebpageLink(
    String url, {
    bool external = false,
    bool embeded = false,
  }) async {
    //
    if (embeded) {
      return openEmbededWebpageLink(url);
    }
    //
    if (!embeded && (Platform.isIOS || external)) {
      await launchUrlString(url, webViewConfiguration: WebViewConfiguration());
      return;
    }
    final result = await viewContext.push(
      (context) => CustomWebviewPage(selectedUrl: url),
    );

    return result;
  }

  openEmbededWebpageLink(String url) async {
    //
    try {
      ChromeSafariBrowser browser = new MyChromeSafariBrowser();
      await browser.open(
        url: WebUri.uri(Uri.parse(url)),
        settings: ChromeSafariBrowserSettings(
          enableUrlBarHiding: false,
          barCollapsingEnabled: true,
          shareState: CustomTabsShareState.SHARE_STATE_OFF,
        ),
      );
    } catch (error) {
      await launchUrlString(url);
    }
    //
  }
}
