import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/custom_text_form_field.dart';
import 'package:fuodz/providers/change_password_providers.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/validator.service.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final result = await ref
        .read(changePasswordControllerProvider.notifier)
        .submit(
          currentPassword: _currentCtrl.text,
          newPassword: _newCtrl.text,
          confirmPassword: _confirmCtrl.text,
        );
    if (!mounted) return;
    switch (result) {
      case ChangePasswordSuccess(:final message):
        await AlertService.success(
          title: 'Change Password'.tr(),
          text: message,
        );
        if (!mounted) return;
        Navigator.of(context).pop(true);
      case ChangePasswordFailure(:final message):
        AlertService.error(title: 'Change Password'.tr(), text: message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = ref.watch(changePasswordControllerProvider).isLoading;

    return BasePage(
      showLeadingAction: true,
      showAppBar: true,
      title: 'Change Password'.tr(),
      body: SafeArea(
        top: true,
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: CustomTextFormField(
                    labelText: 'Current Password'.tr(),
                    obscureText: true,
                    textEditingController: _currentCtrl,
                    validator: FormValidator.validatePassword,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: CustomTextFormField(
                    labelText: 'New Password'.tr(),
                    obscureText: true,
                    textEditingController: _newCtrl,
                    validator: FormValidator.validatePassword,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: CustomTextFormField(
                    labelText: 'Confirm New Password'.tr(),
                    obscureText: true,
                    textEditingController: _confirmCtrl,
                    validator: FormValidator.validatePassword,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: CustomButton(
                    title: 'Update Password'.tr(),
                    loading: isBusy,
                    onPressed: isBusy ? null : _submit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
