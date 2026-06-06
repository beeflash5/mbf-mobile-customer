import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/providers/account_delete_providers.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/utils/utils.dart';

class AccountDeletePage extends ConsumerStatefulWidget {
  const AccountDeletePage({super.key});

  @override
  ConsumerState<AccountDeletePage> createState() => _AccountDeletePageState();
}

class _AccountDeletePageState extends ConsumerState<AccountDeletePage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final result = await ref
        .read(accountDeleteControllerProvider.notifier)
        .delete(password: _passwordCtrl.text);
    if (!mounted) return;
    switch (result) {
      case AccountDeleteSuccess(:final message):
        await AlertService.success(
          title: 'Delete Account'.tr(),
          text: message,
        );
        if (!mounted) return;
        context.goRoute('/splash');
      case AccountDeleteFailure(:final message):
        AlertService.error(title: 'Delete Account'.tr(), text: message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = ref.watch(accountDeleteControllerProvider).isLoading;

    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      elevation: 0,
      title: 'Delete Account'.tr(),
      appBarItemColor: Utils.textColorByTheme(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 5),
              Text(
                'You are about to delete your profile, please select an option below on why you are deleting your profile/account'
                    .tr(),
                style: const TextStyle(fontWeight: FontWeight.w300),
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                'Enter you account password to confirm account deletion'.tr(),
                style: const TextStyle(fontWeight: FontWeight.w300),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password'.tr(),
                  border: const OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Password wajib diisi' : null,
              ),
              const SizedBox(height: 10),
              CustomButton(
                title: 'Submit'.tr(),
                loading: isBusy,
                onPressed: isBusy ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
