import 'package:country_picker/country_picker.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/bottom_sheet/account_verification_entry.dart';
import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/custom_text_form_field.dart';
import 'package:fuodz/component/image.login.dart';
import 'package:fuodz/constants/api.dart';
import 'package:fuodz/providers/register_providers.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/payment.helper.dart';
import 'package:fuodz/services/validator.service.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_routes.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/extensions/context.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key, this.email, this.name, this.phone});

  final String? email;
  final String? name;
  final String? phone;

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameTEC = TextEditingController();
  final _emailTEC = TextEditingController();
  final _phoneTEC = TextEditingController();
  final _passwordTEC = TextEditingController();
  final _referralTEC = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameTEC.text = widget.name ?? '';
    _emailTEC.text = widget.email ?? '';
    _phoneTEC.text = widget.phone ?? '';
  }

  @override
  void dispose() {
    _nameTEC.dispose();
    _emailTEC.dispose();
    _phoneTEC.dispose();
    _passwordTEC.dispose();
    _referralTEC.dispose();
    super.dispose();
  }

  Future<void> _handleResult(RegisterPhase result) async {
    if (!mounted) return;
    switch (result) {
      case RegisterAwaitingOtp():
        await _showVerificationEntry();
        break;
      case RegisterSuccess():
        context.goRoute(AppRoutes.homeRoute);
        break;
      case RegisterFailure(:final message):
        AlertService.error(
          title: 'Registration Failed'.tr(),
          text: message,
        );
        break;
      case RegisterIdle():
        break;
    }
  }

  Future<void> _processRegister() async {
    if (!_formKey.currentState!.validate()) return;
    final state = ref.read(registerControllerProvider);
    if (!state.agreed) return;
    final result = await ref
        .read(registerControllerProvider.notifier)
        .processRegister(
          name: _nameTEC.text,
          email: _emailTEC.text,
          phone: _phoneTEC.text,
          password: _passwordTEC.text,
          referralCode: _referralTEC.text,
          isFirebaseOtp: AppStrings.isFirebaseOtp,
          isCustomOtp: AppStrings.isCustomOtp,
        );
    await _handleResult(result);
  }

  Future<void> _showVerificationEntry() async {
    final phone =
        "+${ref.read(registerControllerProvider).selectedCountry.phoneCode}${_phoneTEC.text}";
    await context.push(
      (context) => AccountVerificationEntry(
        phone: phone,
        email: _emailTEC.text,
        onSubmit: (smsCode) async {
          FocusScope.of(context).unfocus();
          Navigator.of(context).pop();
          RegisterPhase result;
          if (AppStrings.isFirebaseOtp) {
            result = await ref
                .read(registerControllerProvider.notifier)
                .verifyFirebaseOTP(
                  smsCode,
                  name: _nameTEC.text,
                  email: _emailTEC.text,
                  password: _passwordTEC.text,
                  referralCode: _referralTEC.text,
                );
          } else {
            result = await ref
                .read(registerControllerProvider.notifier)
                .verifyCustomOTP(
                  smsCode,
                  name: _nameTEC.text,
                  email: _emailTEC.text,
                  password: _passwordTEC.text,
                  referralCode: _referralTEC.text,
                );
          }
          await _handleResult(result);
        },
        onResendCode: AppStrings.isCustomOtp
            ? () => ref
                .read(registerControllerProvider.notifier)
                .resendCustomOTP(_emailTEC.text)
            : () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerControllerProvider);
    final notifier = ref.read(registerControllerProvider.notifier);
    return BasePage(
      body: Padding(
        padding: EdgeInsets.only(bottom: context.mq.viewInsets.bottom),
        child: VStack([
          ImageLogin(),
          VStack([
            "Register Now!".tr().text.lg.semiBold.make().centered(),
            "Register now to start your journey!".tr().text.make().centered(),
            Form(
              key: _formKey,
              child: VStack([
                CustomTextFormField(
                  labelText: "Name".tr(),
                  textEditingController: _nameTEC,
                  validator: FormValidator.validateName,
                ).py12(),
                CustomTextFormField(
                  labelText: "Email".tr(),
                  keyboardType: TextInputType.emailAddress,
                  textEditingController: _emailTEC,
                  validator: FormValidator.validateEmail,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(' ')),
                  ],
                ).py12(),
                HStack([
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
                    labelText: "Phone".tr(),
                    hintText: "",
                    keyboardType: TextInputType.phone,
                    textEditingController: _phoneTEC,
                    validator: FormValidator.validatePhone,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(' ')),
                    ],
                  ).expand(),
                ]).py12(),
                CustomTextFormField(
                  labelText: "Password".tr(),
                  obscureText: true,
                  textEditingController: _passwordTEC,
                  validator: FormValidator.validatePassword,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(' ')),
                  ],
                ).py12(),
                AppStrings.enableReferSystem
                    ? CustomTextFormField(
                        labelText: "Referral Code(optional)".tr(),
                        textEditingController: _referralTEC,
                      ).py12()
                    : UiSpacer.emptySpace(),
                HStack([
                  Checkbox(
                    value: state.agreed,
                    onChanged: (value) => notifier.setAgreed(value ?? false),
                  ),
                  "I agree with".tr().text.make(),
                  UiSpacer.horizontalSpace(space: 2),
                  "Terms & Conditions"
                      .tr()
                      .text
                      .color(AppColor.primaryColor)
                      .bold
                      .underline
                      .make()
                      .onInkTap(() =>
                          PaymentHelper.openWebpageLink(context, Api.terms))
                      .expand(),
                ]),
                CustomButton(
                  title: "Create Account".tr(),
                  loading: state.isBusy,
                  onPressed: _processRegister,
                ).centered().py12(),
                "Already have an account?"
                    .richText
                    .color(const Color(0xff808080))
                    .withTextSpanChildren([
                      " ".textSpan.make(),
                      "Login"
                          .tr()
                          .textSpan
                          .semiBold
                          .color(Colors.black)
                          .underline
                          .make(),
                    ])
                    .makeCentered()
                    .onInkTap(() => Navigator.of(context).pop()),
              ], crossAlignment: CrossAxisAlignment.end),
            ).py20(),
          ]).wFull(context).p20(),
        ]).scrollVertical(),
      ),
    );
  }
}
