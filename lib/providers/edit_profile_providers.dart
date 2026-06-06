import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/models/user.dart';
import 'package:fuodz/services/auth.request.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/phone_util.service.dart';

/// State edit profile (gambar + country selection terpisah dari TEC).
class EditProfileState {
  const EditProfileState({
    this.currentUser,
    this.newPhoto,
    this.selectedCountry,
  });

  final User? currentUser;
  final File? newPhoto;
  final Country? selectedCountry;

  EditProfileState copyWith({
    User? currentUser,
    File? newPhoto,
    bool clearPhoto = false,
    Country? selectedCountry,
  }) {
    return EditProfileState(
      currentUser: currentUser ?? this.currentUser,
      newPhoto: clearPhoto ? null : (newPhoto ?? this.newPhoto),
      selectedCountry: selectedCountry ?? this.selectedCountry,
    );
  }
}

sealed class EditProfileResult {
  const EditProfileResult();
}

class EditProfileSuccess extends EditProfileResult {
  const EditProfileSuccess(this.message);
  final String message;
}

class EditProfileFailure extends EditProfileResult {
  const EditProfileFailure(this.message);
  final String message;
}

final editProfileAuthRequestProvider =
    Provider<AuthRequest>((_) => AuthRequest());

class EditProfileController extends AsyncNotifier<EditProfileState> {
  @override
  Future<EditProfileState> build() async {
    final user = await AuthServices.getCurrentUser();
    final cc = PhoneUtilService.countryCode ?? 'us';
    return EditProfileState(
      currentUser: user,
      selectedCountry: Country.parse(cc),
    );
  }

  void setPhoto(File? photo) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(newPhoto: photo, clearPhoto: photo == null),
    );
  }

  void setCountry(Country country) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(selectedCountry: country));
  }

  Future<EditProfileResult> submit({
    required String name,
    required String email,
    required String phoneLocal,
  }) async {
    final current = state.valueOrNull;
    final country = current?.selectedCountry;
    final fullPhone = '+${country?.phoneCode ?? ''}$phoneLocal';

    state = const AsyncLoading();
    try {
      final res = await ref
          .read(editProfileAuthRequestProvider)
          .updateProfile(
            photo: current?.newPhoto,
            name: name,
            email: email,
            phone: fullPhone,
            countryCode: country?.countryCode,
          );

      if (res.allGood) {
        await AuthServices.saveUser(res.body['user'], reload: false);
        final updated = await AuthServices.getCurrentUser();
        state = AsyncData(EditProfileState(
          currentUser: updated,
          selectedCountry: country,
        ));
        return EditProfileSuccess(res.message ?? 'Profile updated');
      }
      // restore last good state
      if (current != null) state = AsyncData(current);
      return EditProfileFailure(res.message ?? 'Update profile gagal');
    } catch (e, st) {
      state = AsyncError(e, st);
      return EditProfileFailure('$e');
    }
  }
}

final editProfileControllerProvider =
    AsyncNotifierProvider<EditProfileController, EditProfileState>(
  EditProfileController.new,
);
