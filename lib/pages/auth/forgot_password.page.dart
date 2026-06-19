import 'package:country_picker/country_picker.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuodz/services/app_colors.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/custom_text_form_field.dart';
import 'package:fuodz/providers/forgot_password_providers.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/utils/app_images.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  // Using custom OTP via WhatsApp instead of Firebase as standard
  final bool _isCustomOtp = true;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final state = ref.read(forgotPasswordControllerProvider);
    String localNumber = _phoneCtrl.text.trim();
    localNumber = localNumber.replaceAll(RegExp(r'^0+'), '');
    localNumber = localNumber.replaceAll(RegExp(r'[\s\-]'), '');

    final phase = await ref
        .read(forgotPasswordControllerProvider.notifier)
        .processForgotPassword(phone: localNumber, isCustomOtp: _isCustomOtp);

    if (!mounted) return;

    switch (phase) {
      case ForgotAwaitingOtp():
        _openOtpEntry();
      case ForgotAwaitingPassword():
        _openNewPasswordEntry();
      case ForgotFailure(:final message):
        AlertService.error(title: 'Forgot Password'.tr(), text: message);
      case ForgotIdle():
      case ForgotSuccess():
        break;
    }
  }

  void _showCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect:
          (c) =>
              ref.read(forgotPasswordControllerProvider.notifier).setCountry(c),
    );
  }

  Future<void> _openOtpEntry() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _OtpEntryPage(isCustomOtp: _isCustomOtp),
      ),
    );
  }

  Future<void> _openNewPasswordEntry() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _NewPasswordPage(isCustomOtp: _isCustomOtp),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordControllerProvider);
    final country = state.selectedCountry;

    return BasePage(
      showLeadingAction: true,
      showAppBar: true,
      isLoading: state.isBusy,
      body: SafeArea(
        top: true,
        bottom: false,
        child:
            VStack([
              Image.asset(
                AppImages.forgotPasswordImage,
              ).hOneForth(context).centered(),
              VStack([
                "Forgot Password".tr().text.xl2.semiBold.make(),
                "Enter your phone number to receive a verification code via WhatsApp"
                    .tr()
                    .text
                    .sm
                    .gray500
                    .make()
                    .py4(),

                Form(
                  key: _formKey,
                  child: VStack([
                    CustomTextFormField(
                      labelText: "Phone Number".tr(),
                      hintText: "Enter your phone number".tr(),
                      keyboardType: TextInputType.phone,
                      textEditingController: _phoneCtrl,
                      prefixIcon: GestureDetector(
                        onTap: state.isBusy ? null : _showCountryPicker,
                        child: HStack([
                          Flag.fromString(
                            country.countryCode,
                            height: 20,
                            width: 28,
                            fit: BoxFit.cover,
                          ),
                          4.widthBox,
                          "+${country.phoneCode}".text.sm.semiBold.make(),
                          const Icon(
                            Icons.arrow_drop_down,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ]).pSymmetric(h: 10, v: 4),
                      ),
                      validator:
                          (v) =>
                              (v == null || v.trim().length < 5)
                                  ? 'Required'.tr()
                                  : null,
                    ).py12(),
                    CustomButton(
                      title: "Send OTP".tr(),
                      loading: state.isBusy,
                      onPressed: state.isBusy ? null : _submit,
                    ).h(Vx.dp48).centered().py12(),
                  ], crossAlignment: CrossAxisAlignment.end),
                ).py20(),
              ]).wFull(context).p20(),
            ]).scrollVertical(),
      ),
    );
  }
}

class _OtpEntryPage extends ConsumerStatefulWidget {
  const _OtpEntryPage({required this.isCustomOtp});
  final bool isCustomOtp;

  @override
  ConsumerState<_OtpEntryPage> createState() => _OtpEntryPageState();
}

class _OtpEntryPageState extends ConsumerState<_OtpEntryPage> {
  String _code = '';

  Future<void> _verify() async {
    if (_code.length < 4) return;

    final notifier = ref.read(forgotPasswordControllerProvider.notifier);
    final phase =
        widget.isCustomOtp
            ? await notifier.verifyCustomOTP(_code)
            : await notifier.verifyFirebaseOTP(_code);

    if (!mounted) return;
    switch (phase) {
      case ForgotAwaitingPassword():
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => _NewPasswordPage(isCustomOtp: widget.isCustomOtp),
          ),
        );
      case ForgotFailure(:final message):
        AlertService.error(title: 'Verification'.tr(), text: message);
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordControllerProvider);
    final pinWidth = context.screenWidth * 0.7;

    return BasePage(
      showLeadingAction: true,
      showAppBar: true,
      title: "Verification Code".tr(),
      isLoading: state.isBusy,
      body:
          VStack([
            "Verify your phone number".tr().text.xl2.bold.center.makeCentered(),
            "Enter otp sent to your provided phone number"
                .tr()
                .text
                .center
                .makeCentered()
                .py8(),

            PinCodeTextField(
              appContext: context,
              length: 6,
              obscureText: false,
              keyboardType: TextInputType.number,
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.underline,
                fieldHeight: 50,
                fieldWidth: pinWidth / 7,
                activeFillColor: AppColor.primaryColor,
                selectedColor: AppColor.primaryColor,
                inactiveColor: AppColor.accentColor,
              ),
              animationDuration: const Duration(milliseconds: 300),
              backgroundColor: Colors.transparent,
              enableActiveFill: false,
              onChanged: (v) => _code = v,
              onCompleted: (v) => _code = v,
            ).w(pinWidth).centered().py16(),

            CustomButton(
              title: "Verify".tr(),
              loading: state.isBusy,
              onPressed: state.isBusy ? null : _verify,
            ).h(Vx.dp48).centered(),
          ]).p20(),
    );
  }
}

class _NewPasswordPage extends ConsumerStatefulWidget {
  const _NewPasswordPage({required this.isCustomOtp});
  final bool isCustomOtp;

  @override
  ConsumerState<_NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends ConsumerState<_NewPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final phase = await ref
        .read(forgotPasswordControllerProvider.notifier)
        .finishChangeAccountPassword(
          password: _passwordCtrl.text,
          isCustomOtp: widget.isCustomOtp,
        );

    if (!mounted) return;
    switch (phase) {
      case ForgotSuccess(:final message):
        await AlertService.success(
          title: 'Forgot Password'.tr(),
          text: message,
        );
        if (!mounted) return;
        Navigator.of(context).popUntil((route) => route.isFirst);
      case ForgotFailure(:final message):
        AlertService.error(title: 'Forgot Password'.tr(), text: message);
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordControllerProvider);

    return BasePage(
      showLeadingAction: true,
      showAppBar: true,
      title: "New Password".tr(),
      isLoading: state.isBusy,
      body: Form(
        key: _formKey,
        child:
            VStack([
              "Please enter account new password"
                  .tr()
                  .text
                  .center
                  .makeCentered()
                  .py8(),

              CustomTextFormField(
                textEditingController: _passwordCtrl,
                labelText: "New Password".tr(),
                hintText: "Enter your new password",
                obscureText: true,
                validator:
                    (v) =>
                        (v == null || v.length < 6)
                            ? 'Password minimal 6 karakter'.tr()
                            : null,
              ).py16(),

              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _passwordCtrl,
                builder: (context, value, child) {
                  final isValid = value.text.length >= 6;
                  return CustomButton(
                    title: "Reset Password".tr(),
                    loading: state.isBusy,
                    onPressed: state.isBusy || !isValid ? null : _submit,
                  ).h(Vx.dp48).centered();
                },
              ),
            ]).p20(),
      ),
    );
  }
}
