import 'dart:io';
import 'package:fuodz/utils/extensions/router.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/dynamic_status_bar.dart';
import 'package:fuodz/component/image.login.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/pages/auth/login/otp_login.view.dart';
import 'package:fuodz/pages/auth/register.page.dart';
import 'package:fuodz/providers/login_providers.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/social_media_login.service.dart';
import 'package:fuodz/services/toast.service.dart';
import 'package:fuodz/utils/app_images.dart';
import 'package:fuodz/utils/app_routes.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, this.required = false});

  final bool required;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final SocialMediaLoginService _socialMediaLoginService =
      SocialMediaLoginService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(loginControllerProvider.notifier).listenAppleCallback(
        (data) async {
          final notifier = ref.read(loginControllerProvider.notifier);
          final idToken = data.idToken;
          if (idToken == null || idToken.isEmpty) return;
          final payload = notifier.parseJwt(idToken);
          final email = payload?['email'];
          final apiResponse = await notifier.authRequest.loginAppleAndroid(
            email ?? '',
            idToken,
            'apple',
          );
          if (apiResponse == null) return;
          if (apiResponse.hasError()) {
            AlertService.error(
              title: 'Login Failed',
              text: apiResponse.message,
            );
            return;
          }
          await _handleLoginResult(
            await notifier.handleDeviceLogin(apiResponse),
          );
        },
      );
    });
  }

  Future<void> _handleLoginResult(LoginPhase phase) async {
    if (!mounted) return;
    switch (phase) {
      case LoginSuccess():
        context.goRoute(AppRoutes.homeRoute);
        break;
      case LoginFailure(:final message):
        AlertService.error(
          title: 'Login Failed'.tr(),
          text: message,
        );
        break;
      case LoginNeedsRegister(:final email, :final name, :final phone):
        context.pushWidget(RegisterPage(email: email, name: name, phone: phone));
        break;
      case LoginAwaitingOtp():
      case LoginIdle():
        break;
    }
  }

  void _openRegister() {
    context.pushWidget(const RegisterPage());
  }

  Future<void> _onSocialApiResponse(ApiResponse response) async {
    final phase = await ref
        .read(loginControllerProvider.notifier)
        .handleDeviceLogin(response);
    await _handleLoginResult(phase);
  }

  @override
  Widget build(BuildContext context) {
    return DynamicStatusBar(
      baseColor: Colors.white,
      child: PopScope(
        canPop: !widget.required,
        onPopInvoked: (didPop) async {
          if (!didPop && widget.required) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "You are required to login/register to continue process"
                      .tr(),
                ),
              ),
            );
          }
        },
        child: BasePage(
          body: Padding(
            padding: EdgeInsets.only(bottom: context.mq.viewInsets.bottom),
            child: VStack([
              ImageLogin(),
              VStack([
                "Login Now!".tr().text.lg.semiBold.make().centered(),
                "Welcome back. Please enter your details."
                    .tr()
                    .text
                    .make()
                    .centered(),
                OTPLoginView(onLoggedIn: _handleLoginResult),
              ]).wFull(context).px20().pOnly(top: Vx.dp20),
              "Don’t have an account?"
                  .richText
                  .color(const Color(0xff808080))
                  .withTextSpanChildren([
                    " ".textSpan.make(),
                    "Sign Up"
                        .tr()
                        .textSpan
                        .semiBold
                        .color(Colors.black)
                        .underline
                        .make(),
                  ])
                  .makeCentered()
                  .onInkTap(_openRegister),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xff808080)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(AppImages.google2, width: 24, height: 24),
                        const SizedBox(width: 10),
                        "Google".text.make(),
                      ],
                    ),
                  ).onInkTap(() => _socialMediaLoginService.googleLogin(
                        onApiResponse: _onSocialApiResponse,
                        onNeedsRegister: ({email, name}) =>
                            context.pushWidget(RegisterPage(email: email, name: name)),
                        onError: ToastService.toastError,
                        onBusy: ref
                            .read(loginControllerProvider.notifier)
                            .setBusy,
                      )).expand(),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xff808080)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(AppImages.apple2, width: 24, height: 24),
                        const SizedBox(width: 10),
                        "Apple".text.make(),
                      ],
                    ),
                  ).onInkTap(() {
                    if (Platform.isAndroid) {
                      _socialMediaLoginService.appleLoginAndroid(
                        onError: ToastService.toastError,
                      );
                    } else {
                      _socialMediaLoginService.appleLogin(
                        onApiResponse: _onSocialApiResponse,
                        onNeedsRegister: ({email, name}) =>
                            context.pushWidget(RegisterPage(email: email, name: name)),
                        onError: ToastService.toastError,
                      );
                    }
                  }).expand(),
                ],
              ).px20(),
              const SizedBox(height: 30),
            ]).scrollVertical(),
          ),
        ),
      ),
    );
  }
}
