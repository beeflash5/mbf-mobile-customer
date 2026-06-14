import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/custom_text_form_field.dart';
import 'package:fuodz/pages/auth/forgot_password.page.dart';
import 'package:fuodz/providers/login_providers.dart';
import 'package:fuodz/services/validator.service.dart';

class OTPLoginView extends ConsumerStatefulWidget {
  const OTPLoginView({super.key, required this.onLoggedIn});

  final Future<void> Function(LoginPhase) onLoggedIn;

  @override
  ConsumerState<OTPLoginView> createState() => _OTPLoginViewState();
}

class _OTPLoginViewState extends ConsumerState<OTPLoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailTEC = TextEditingController();
  final _passwordTEC = TextEditingController();

  @override
  void dispose() {
    _emailTEC.dispose();
    _passwordTEC.dispose();
    super.dispose();
  }

  Future<void> _process() async {
    if (!_formKey.currentState!.validate()) return;
    final result = await ref
        .read(loginControllerProvider.notifier)
        .processEmailLogin(email: _emailTEC.text, password: _passwordTEC.text);
    await widget.onLoggedIn(result);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);
    return Form(
      key: _formKey,
      child: VStack([
        CustomTextFormField(
          labelText: "Email / Phone".tr(),
          keyboardType: TextInputType.emailAddress,
          textEditingController: _emailTEC,
          validator: FormValidator.validateEmpty,
        ).py12(),
        CustomTextFormField(
          labelText: "Password".tr(),
          obscureText: true,
          textEditingController: _passwordTEC,
          validator: FormValidator.validatePassword,
        ).py12(),
        const SizedBox(height: 10),
        "Forgot Password ?".tr().text.underline.make().onInkTap(() {
          context.pushWidget(const ForgotPasswordPage());
        }),
        const SizedBox(height: 10),
        CustomButton(
          title: "Login".tr(),
          loading: state.isBusy,
          onPressed: _process,
        ).centered().py12(),
      ], crossAlignment: CrossAxisAlignment.end),
    ).py20();
  }
}
