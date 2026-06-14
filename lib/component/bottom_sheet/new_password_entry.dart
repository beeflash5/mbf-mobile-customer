import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/button/custom_leading.dart';
import 'package:fuodz/component/custom_text_form_field.dart';
import 'package:fuodz/services/validator.service.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/extensions/context.dart';

class NewPasswordEntry extends StatefulWidget {
  const NewPasswordEntry({super.key, required this.onSubmit});

  final Function(String) onSubmit;

  @override
  State<NewPasswordEntry> createState() => _NewPasswordEntryState();
}

class _NewPasswordEntryState extends State<NewPasswordEntry> {
  final _resetFormKey = GlobalKey<FormState>();
  final _passwordTEC = TextEditingController();

  @override
  void dispose() {
    _passwordTEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      appBarColor: AppColor.primaryColor,
      title: "New Password".tr(),
      elevation: 0,
      leading: CustomLeading().onInkTap(() => context.pop()),
      body: Form(
        key: _resetFormKey,
        child:
            VStack([
              "Please enter account new password".tr().text.makeCentered(),
              CustomTextFormField(
                labelText: "New Password".tr(),
                textEditingController: _passwordTEC,
                validator: FormValidator.validatePassword,
                obscureText: true,
              ).py12(),
              CustomButton(
                title: "Reset Password".tr(),
                onPressed: () {
                  if (_resetFormKey.currentState!.validate()) {
                    widget.onSubmit(_passwordTEC.text);
                  }
                },
              ).h(Vx.dp48),
            ]).p20(),
      ),
    );
  }
}
