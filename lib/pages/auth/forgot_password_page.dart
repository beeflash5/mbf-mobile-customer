import 'package:country_picker/country_picker.dart';
import 'package:flag/flag.dart' as flag;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/component/button/app_button.dart';
import 'package:fuodz/component/input/app_text_field.dart';
import 'package:fuodz/providers/auth_providers.dart';
import 'package:fuodz/utils/alert.service.dart';
import 'package:fuodz/utils/app_images.dart';

/// UI sama seperti legacy forgot_password.page.dart (gambar forgotPassword
/// + phone field dengan country picker + Send OTP), tapi pakai Riverpod.
///
/// NOTE: legacy alur Firebase phone-OTP sebelum reset belum dipindahkan
/// (verifikasi OTP perlu integrasi firebase_auth + halaman OTP entry).
/// Sementara langsung memanggil endpoint reset; sambungkan flow OTP penuh
/// pada iterasi auth lanjutan.
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState
    extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _newPassword = TextEditingController();

  Country _country = Country(
    phoneCode: '62',
    countryCode: 'ID',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'Indonesia',
    example: '',
    displayName: 'Indonesia',
    displayNameNoCountryCode: 'Indonesia',
    e164Key: '',
  );

  @override
  void dispose() {
    _phone.dispose();
    _newPassword.dispose();
    super.dispose();
  }

  void _pickCountry() {
    showCountryPicker(
      context: context,
      onSelect: (c) => setState(() => _country = c),
      showPhoneCode: true,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final fullPhone = '+${_country.phoneCode}${_phone.text.trim()}';
    final result = await ref
        .read(loginControllerProvider.notifier)
        .resetPassword(phone: fullPhone, password: _newPassword.text);
    if (!mounted) return;
    switch (result) {
      case LoginSuccess():
        await AlertService.success(
          title: 'Berhasil',
          text: 'Password berhasil di-reset. Silakan login.',
        );
        if (!mounted) return;
        Navigator.of(context).maybePop();
      case LoginFailure(:final message):
        AlertService.error(title: 'Reset Password Gagal', text: message);
    }
  }

  String? _validateNotEmpty(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null;
  String? _validatePassword(String? v) =>
      (v == null || v.length < 6) ? 'Minimal 6 karakter' : null;

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(loginControllerProvider).isLoading;
    final imgH = MediaQuery.of(context).size.height / 4;
    return Scaffold(
      appBar: AppBar(elevation: 0),
      body: SafeArea(
        top: true,
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Image.asset(
              AppImages.forgotPasswordImage,
              height: imgH,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            const Text(
              'Forgot Password',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppTextField(
                    controller: _phone,
                    label: 'Phone Number',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(' ')),
                    ],
                    validator: _validateNotEmpty,
                    prefixIcon: InkWell(
                      onTap: _pickCountry,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            flag.Flag.fromString(
                              _country.countryCode,
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 5),
                            Text('+${_country.phoneCode}'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _newPassword,
                    label: 'New Password',
                    obscureText: true,
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    label: 'Send OTP',
                    loading: busy,
                    onPressed: busy ? null : _submit,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
