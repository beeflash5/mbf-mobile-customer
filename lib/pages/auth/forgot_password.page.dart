import 'package:country_picker/country_picker.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/bottom_sheet/account_verification_entry.dart';
import 'package:fuodz/component/bottom_sheet/new_password_entry.dart';
import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/custom_text_form_field.dart';
import 'package:fuodz/providers/forgot_password_providers.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/validator.service.dart';
import 'package:fuodz/utils/app_images.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/extensions/context.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneTEC = TextEditingController();

  @override
  void dispose() {
    _phoneTEC.dispose();
    super.dispose();
  }

  Future<void> _handle(ForgotPasswordPhase result) async {
    if (!mounted) return;
    switch (result) {
      case ForgotAwaitingOtp(:final phone, :final email):
        await _showVerificationEntry(phone: phone ?? '', email: email);
        break;
      case ForgotAwaitingPassword():
        await _showNewPasswordEntry();
        break;
      case ForgotSuccess(:final message):
        AlertService.dynamic(
          type: AlertType.success,
          title: 'Forgot Password'.tr(),
          text: message,
          onConfirm: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        );
        break;
      case ForgotFailure(:final message):
        AlertService.error(
          title: 'Forgot Password'.tr(),
          text: message,
        );
        break;
      case ForgotIdle():
        break;
    }
  }

  Future<void> _process() async {
    if (!_formKey.currentState!.validate()) return;
    final result = await ref
        .read(forgotPasswordControllerProvider.notifier)
        .processForgotPassword(
          phone: _phoneTEC.text,
          isCustomOtp: AppStrings.isCustomOtp,
        );
    await _handle(result);
  }

  Future<void> _showVerificationEntry({
    required String phone,
    String? email,
  }) async {
    await context.push(
      (context) => AccountVerificationEntry(
        phone: phone,
        email: email,
        onSubmit: (smsCode) async {
          Navigator.of(context).pop();
          ForgotPasswordPhase result;
          if (AppStrings.isCustomOtp) {
            result = await ref
                .read(forgotPasswordControllerProvider.notifier)
                .verifyCustomOTP(smsCode);
          } else {
            result = await ref
                .read(forgotPasswordControllerProvider.notifier)
                .verifyFirebaseOTP(smsCode);
          }
          await _handle(result);
        },
        onResendCode: AppStrings.isCustomOtp
            ? () => ref
                .read(forgotPasswordControllerProvider.notifier)
                .resendCustomOTP()
            : () {},
      ),
    );
  }

  Future<void> _showNewPasswordEntry() async {
    context.pushWidget(NewPasswordEntry(
          onSubmit: (password) async {
            Navigator.of(context).pop();
            final result = await ref
                .read(forgotPasswordControllerProvider.notifier)
                .finishChangeAccountPassword(
                  password: password,
                  isCustomOtp: AppStrings.isCustomOtp,
                );
            await _handle(result);
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordControllerProvider);
    final notifier = ref.read(forgotPasswordControllerProvider.notifier);
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
                  prefixIcon: HStack([
                    Flag.fromString(
                      state.selectedCountry.countryCode,
                      width: 20,
                      height: 20,
                    ),
                    UiSpacer.horizontalSpace(space: 5),
                    ("+" + state.selectedCountry.phoneCode).text.make(),
                  ]).px8().onInkTap(() => showCountryPicker(
                        context: context,
                        showPhoneCode: true,
                        onSelect: notifier.setCountry,
                      )),
                  labelText: "Phone Number".tr(),
                  hintText: "",
                  keyboardType: TextInputType.phone,
                  textEditingController: _phoneTEC,
                  validator: FormValidator.validatePhone,
                ).py12(),
                CustomButton(
                  title: "Send OTP".tr(),
                  loading: state.isBusy,
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
