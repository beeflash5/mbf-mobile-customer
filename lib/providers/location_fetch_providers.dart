import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_place_picker_mb_v2/google_maps_place_picker.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import 'package:fuodz/models/delivery_address.dart';
import 'package:fuodz/services/delivery_address.helper.dart';
import 'package:fuodz/services/geocoder.service.dart';
import 'package:fuodz/services/location.service.dart';
import 'package:fuodz/services/permission.service.dart';
import 'package:fuodz/services/toast.service.dart';

class LocationFetchState {
  const LocationFetchState({
    this.showManuallySelection = false,
    this.showRequestPermission = false,
    this.isBusy = false,
  });
  final bool showManuallySelection;
  final bool showRequestPermission;
  final bool isBusy;

  LocationFetchState copyWith({
    bool? showManuallySelection,
    bool? showRequestPermission,
    bool? isBusy,
  }) =>
      LocationFetchState(
        showManuallySelection:
            showManuallySelection ?? this.showManuallySelection,
        showRequestPermission:
            showRequestPermission ?? this.showRequestPermission,
        isBusy: isBusy ?? this.isBusy,
      );
}

class LocationFetchController extends Notifier<LocationFetchState> {
  @override
  LocationFetchState build() => const LocationFetchState();

  /// Returns true when an address is available (already saved or just resolved)
  /// — the page should navigate forward.
  Future<bool> initialise() async {
    try {
      LocationService.deliveryaddress =
          await LocationService.getLocallySaveAddress();
    } catch (_) {}
    if (LocationService.deliveryaddress != null) return true;
    return handleFetchCurrentLocation();
  }

  Future<bool> handleFetchCurrentLocation() async {
    final granted = await _locationPermissionGetter();
    state = state.copyWith(
      showManuallySelection: !granted,
      showRequestPermission: granted,
    );
    if (granted) {
      await _fetchCurrentLocation();
      if (LocationService.deliveryaddress != null) return true;
    }
    return false;
  }

  Future<void> _fetchCurrentLocation() async {
    state = state.copyWith(isBusy: true);
    try {
      final pos = await Geolocator.getCurrentPosition();
      final address = await LocationService.addressFromCoordinates(
        lat: pos.latitude,
        lng: pos.longitude,
      );
      LocationService.currenctAddress = address;
      if (address != null) {
        LocationService.currenctAddressSubject.sink.add(address);
      }
      final cur =
          LocationService.deliveryaddress ?? DeliveryAddress();
      cur.address = address?.addressLine;
      cur.latitude = address?.coordinates?.latitude;
      cur.longitude = address?.coordinates?.longitude;
      cur.name = 'Current Location'.tr();
      LocationService.deliveryaddress = cur;
      LocationService.currenctDeliveryAddressSubject.add(cur);
    } catch (_) {}
    state = state.copyWith(isBusy: false);
  }

  Future<bool> _locationPermissionGetter() async {
    bool granted = false;
    try {
      granted = await PermissionService.isLocationGranted();
      if (!granted) {
        final permanentlyDenied =
            await PermissionService.isLocationPermanentlyDenied();
        if (permanentlyDenied && !Platform.isIOS) {
          ToastService.toastError(
            "Permission is denied permanently, please re-enable permission from app info on your device settings. Thank you"
                .tr(),
          );
          granted = await LocationService.showRequestDialog();
          if (granted) granted = await Geolocator.openLocationSettings();
        } else if (permanentlyDenied && Platform.isIOS) {
          ToastService.toastError(
            "Permission is denied permanently. You can skip the use for location and use the app manually. Thank you"
                .tr(),
          );
        } else {
          granted = await LocationService.showRequestDialog();
          if (granted) {
            try {
              granted = await PermissionService.requestPermission();
            } catch (_) {
              granted = false;
            }
          }
        }
      }
    } catch (_) {
      granted = false;
    }
    return granted;
  }

  Future<bool> pickFromMap(BuildContext context) async {
    await _locationPermissionGetter();
    final result = await DeliveryAddressHelper.newPlacePicker(context);
    if (result == null) return false;
    final deliveryAddress = DeliveryAddress();

    if (result is PickResult) {
      deliveryAddress.address = result.formattedAddress;
      deliveryAddress.latitude = result.geometry?.location.lat;
      deliveryAddress.longitude = result.geometry?.location.lng;
      if (result.addressComponents != null &&
          result.addressComponents!.isNotEmpty) {
        for (final c in result.addressComponents!) {
          if (c.types.contains('locality')) deliveryAddress.city = c.longName;
          if (c.types.contains('administrative_area_level_1')) {
            deliveryAddress.state = c.longName;
          }
          if (c.types.contains('country')) deliveryAddress.country = c.longName;
        }
        final address = Address(
          featureName: deliveryAddress.name ?? deliveryAddress.address,
          addressLine: deliveryAddress.address,
          locality: deliveryAddress.city,
          adminArea: deliveryAddress.state,
          countryName: deliveryAddress.country,
          coordinates: Coordinates(
            deliveryAddress.latitude!,
            deliveryAddress.longitude!,
          ),
        );
        LocationService.deliveryaddress = deliveryAddress;
        LocationService.currenctAddressSubject.add(address);
      } else {
        state = state.copyWith(isBusy: true);
        final coords = Coordinates(
          deliveryAddress.latitude!,
          deliveryAddress.longitude!,
        );
        final addresses =
            await GeocoderService().findAddressesFromCoordinates(coords);
        if (addresses.isNotEmpty) {
          deliveryAddress.city = addresses.first.locality;
          LocationService.deliveryaddress = deliveryAddress;
          LocationService.currenctAddressSubject.add(addresses.first);
        }
        state = state.copyWith(isBusy: false);
      }
      await LocationService.saveSelectedAddressLocally(deliveryAddress);
      return true;
    } else if (result is Address) {
      deliveryAddress.address = result.addressLine;
      deliveryAddress.latitude = result.coordinates?.latitude;
      deliveryAddress.longitude = result.coordinates?.longitude;
      deliveryAddress.city = result.locality;
      deliveryAddress.state = result.adminArea;
      deliveryAddress.country = result.countryName;
      LocationService.deliveryaddress = deliveryAddress;
      LocationService.currenctAddressSubject.add(result);
      await LocationService.saveSelectedAddressLocally(deliveryAddress);
      return true;
    }
    return false;
  }
}

final locationFetchControllerProvider =
    NotifierProvider<LocationFetchController, LocationFetchState>(
  LocationFetchController.new,
);
