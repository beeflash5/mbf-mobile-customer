import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/custom_text_form_field.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/auth.request.dart';
import 'package:fuodz/services/validator.service.dart';
import 'package:fuodz/utils/app_images.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailTEC = TextEditingController();
  bool isBusy = false;

  @override
  void dispose() {
    _emailTEC.dispose();
    super.dispose();
  }

  Future<void> _process() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isBusy = true);
    try {
      final res = await AuthRequest().forgotPassword(_emailTEC.text);
      if (res.allGood) {
        AlertService.dynamic(
          type: AlertType.success,
          title: 'Forgot Password'.tr(),
          text: res.message ?? "Password reset link sent to your email",
          onConfirm: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        );
      } else {
        AlertService.error(
          title: 'Forgot Password'.tr(),
          text: res.message ?? "Failed to send reset link",
        );
      }
    } catch (e) {
      AlertService.error(
        title: 'Forgot Password'.tr(),
        text: e.toString(),
      );
    } finally {
      if (mounted) setState(() => isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showLeadingAction: true,
      showAppBar: true,
      body: SafeArea(
        top: true,
        bottom: false,
        child: VStack([
          Image.asset(AppImages.forgotPasswordImage)
              .hOneForth(context)
              .centered(),
          VStack([
            "Forgot Password".tr().text.xl2.semiBold.make(),
            Form(
              key: _formKey,
              child: VStack([
                CustomTextFormField(
                  labelText: "Email".tr(),
                  hintText: "Enter your email".tr(),
                  keyboardType: TextInputType.emailAddress,
                  textEditingController: _emailTEC,
                  validator: FormValidator.validateEmail,
                ).py12(),
                CustomButton(
                  title: "Send Link".tr(),
                  loading: isBusy,
                  onPressed: _process,
                ).h(Vx.dp48).centered().py12(),
              ], crossAlignment: CrossAxisAlignment.end),
            ).py20(),
          ]).wFull(context).p20(),
        ]).scrollVertical(),
      ),
    );
  }
}
