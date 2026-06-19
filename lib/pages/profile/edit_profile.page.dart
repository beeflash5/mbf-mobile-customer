import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/busy_indicator.dart';
import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/custom_text_form_field.dart';
import 'package:fuodz/providers/edit_profile_providers.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/validator.service.dart';
import 'package:fuodz/utils/app_images.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _picker = ImagePicker();
  bool _prefilled = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _prefillIfNeeded(EditProfileState? s) {
    if (_prefilled || s?.currentUser == null) return;
    final u = s!.currentUser!;
    _nameCtrl.text = u.name;
    _emailCtrl.text = u.email;
    String raw = (u.rawPhone ?? u.phone).replaceAll(RegExp(r'[^0-9]'), '');
    final phoneCode = s.selectedCountry?.phoneCode ?? '';
    if (phoneCode.isNotEmpty && raw.startsWith(phoneCode)) {
      raw = raw.substring(phoneCode.length);
    }
    _phoneCtrl.text = raw;
    _prefilled = true;
  }

  Future<void> _pickPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    ref
        .read(editProfileControllerProvider.notifier)
        .setPhoto(picked != null ? File(picked.path) : null);
  }

  void _pickCountry() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect:
          (c) => ref.read(editProfileControllerProvider.notifier).setCountry(c),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final result = await ref
        .read(editProfileControllerProvider.notifier)
        .submit(
          name: _nameCtrl.text,
          email: _emailCtrl.text,
          phoneLocal: _phoneCtrl.text,
        );
    if (!mounted) return;
    switch (result) {
      case EditProfileSuccess(:final message):
        await AlertService.success(title: 'Profile Update'.tr(), text: message);
        if (!mounted) return;
        Navigator.of(context).pop(true);
      case EditProfileFailure(:final message):
        AlertService.error(title: 'Profile Update'.tr(), text: message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(editProfileControllerProvider);
    final state = asyncState.valueOrNull;
    _prefillIfNeeded(state);
    final isBusy = asyncState.isLoading;
    final user = state?.currentUser;
    final newPhoto = state?.newPhoto;
    final country = state?.selectedCountry;

    return BasePage(
      showLeadingAction: true,
      showAppBar: true,
      title: 'Edit Profile'.tr(),
      body: SafeArea(
        top: true,
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Stack(
                children: [
                  if (user == null)
                    BusyIndicator()
                  else
                    (newPhoto == null
                            ? CachedNetworkImage(
                              imageUrl: user.photo,
                              progressIndicatorBuilder:
                                  (context, url, progress) => BusyIndicator(),
                              errorWidget:
                                  (context, _, __) =>
                                      Image.asset(AppImages.user),
                              fit: BoxFit.cover,
                            )
                            : Image.file(newPhoto, fit: BoxFit.cover))
                        .wh(Vx.dp64 * 1.3, Vx.dp64 * 1.3)
                        .box
                        .rounded
                        .clip(Clip.antiAlias)
                        .make(),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: const Icon(Icons.camera_alt, size: 16)
                        .p8()
                        .box
                        .color(Theme.of(context).colorScheme.surface)
                        .roundedFull
                        .shadow
                        .make()
                        .onInkTap(_pickPhoto),
                  ),
                ],
              ).box.makeCentered(),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: CustomTextFormField(
                        labelText: 'Name'.tr(),
                        textEditingController: _nameCtrl,
                        validator: FormValidator.validateName,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: CustomTextFormField(
                        labelText: 'Email'.tr(),
                        keyboardType: TextInputType.emailAddress,
                        textEditingController: _emailCtrl,
                        validator: FormValidator.validateEmail,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: CustomTextFormField(
                        prefixIcon: HStack([
                          Flag.fromString(
                            country?.countryCode ?? 'us',
                            width: 20,
                            height: 20,
                          ),
                          UiSpacer.horizontalSpace(space: 5),
                          ('+${country?.phoneCode ?? '1'}').text.make(),
                        ]).px8().onInkTap(_pickCountry),
                        labelText: 'Phone',
                        keyboardType: TextInputType.phone,
                        textEditingController: _phoneCtrl,
                        validator: FormValidator.validatePhone,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child:
                          CustomButton(
                            title: 'Update Profile'.tr(),
                            loading: isBusy,
                            onPressed: isBusy ? null : _submit,
                          ).centered(),
                    ),
                  ],
                ),
              ).py20(),
            ],
          ),
        ),
      ),
    );
  }
}
