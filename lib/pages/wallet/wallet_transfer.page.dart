import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/custom_text_form_field.dart';
import 'package:fuodz/models/user.dart';
import 'package:fuodz/models/wallet.dart';
import 'package:fuodz/providers/wallet_transfer_providers.dart';
import 'package:fuodz/services/toast.service.dart';
import 'package:fuodz/services/validator.service.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/extensions/string.dart';
import 'package:fuodz/utils/qrcode_scanner.trait.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';

import 'widgets/selected_wallet_user.dart';

class WalletTransferPage extends ConsumerStatefulWidget {
  const WalletTransferPage(this.wallet, {super.key});

  final Wallet wallet;

  @override
  ConsumerState<WalletTransferPage> createState() => _WalletTransferPageState();
}

class _WalletTransferPageState extends ConsumerState<WalletTransferPage>
    with QrcodeScannerTrait {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _amountCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _scanWalletAddress() async {
    final code = await openScanner(context);
    if (code == null) {
      ToastService.toastError('Operation failed/cancelled'.tr());
      return;
    }
    try {
      final user = User.fromJson(jsonDecode(code));
      ref.read(walletTransferControllerProvider.notifier).selectUser(user);
    } catch (_) {
      ToastService.toastError('Invalid QR'.tr());
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final result = await ref
        .read(walletTransferControllerProvider.notifier)
        .submit(amount: _amountCtrl.text, password: _passwordCtrl.text);
    if (!mounted) return;
    switch (result) {
      case WalletTransferSuccess(:final message):
        ToastService.toastSuccessful(message);
        Navigator.of(context).pop(true);
      case WalletTransferFailure(:final message):
        ToastService.toastError(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedUserAsync = ref.watch(walletTransferControllerProvider);
    final selectedUser = selectedUserAsync.valueOrNull;
    final isBusy = selectedUserAsync.isLoading;
    final notifier = ref.read(walletTransferControllerProvider.notifier);

    return BasePage(
      title: 'Wallet Transfer'.tr(),
      showLeadingAction: true,
      showAppBar: true,
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child:
            VStack([
              CustomTextFormField(
                labelText: 'Amount'.tr(),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textEditingController: _amountCtrl,
                validator:
                    (value) => FormValidator.validateCustom(
                      value,
                      name: 'Amount'.tr(),
                      rules: 'required|lt:${widget.wallet.balance}',
                    ),
              ),
              UiSpacer.formVerticalSpace(),
              'Receiver'.tr().text.lg.semiBold.make(),
              UiSpacer.verticalSpace(space: 6),
              Row(
                children: [
                  TypeAheadField(
                    hideOnLoading: true,
                    hideWithKeyboard: false,
                    debounceDuration: const Duration(seconds: 1),
                    builder: (context, controller, focusNode) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        autofocus: false,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColor.primaryColor,
                            ),
                          ),
                          hintText: 'Email/Phone'.tr(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColor.primaryColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColor.primaryColor,
                            ),
                          ),
                        ),
                      );
                    },
                    suggestionsCallback: notifier.searchUsers,
                    itemBuilder: (context, User? suggestion) {
                      if (suggestion == null) return const Divider();
                      return VStack([
                        VStack([
                          '${suggestion.name}'.text.semiBold.lg.make(),
                          UiSpacer.vSpace(5),
                          "${suggestion.code ?? ''} - ${suggestion.phone.isNotBlank ? suggestion.phone.maskString(start: 3, end: 8) : ''}"
                              .text
                              .sm
                              .make(),
                        ]).px12().py(3),
                        const Divider(),
                      ]);
                    },
                    onSelected: notifier.selectUser,
                  ).expand(),
                  UiSpacer.horizontalSpace(),
                  Icon(Icons.qr_code, size: 32, color: Utils.textColorByTheme())
                      .p12()
                      .box
                      .roundedSM
                      .outerShadowSm
                      .color(AppColor.primaryColor)
                      .make()
                      .onInkTap(_scanWalletAddress),
                ],
              ),
              if (selectedUser != null) SelectedWalletUser(selectedUser),
              UiSpacer.formVerticalSpace(),
              CustomTextFormField(
                labelText: 'Password'.tr(),
                textEditingController: _passwordCtrl,
                obscureText: true,
                validator: FormValidator.validatePassword,
              ),
              UiSpacer.formVerticalSpace(),
              CustomButton(
                loading: isBusy,
                title: 'Transfer'.tr(),
                onPressed: isBusy ? null : _submit,
              ).wFull(context),
              UiSpacer.formVerticalSpace(),
            ]).p20().scrollVertical(),
      ),
    );
  }
}
