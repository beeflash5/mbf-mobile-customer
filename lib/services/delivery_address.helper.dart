import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb_v2/google_maps_place_picker.dart';
import 'package:localize_and_translate/localize_and_translate.dart' show translator;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:what3words/what3words.dart' hide Coordinates;

import 'package:fuodz/models/delivery_address.dart';
import 'package:fuodz/pages/shared/ops_map.page.dart';
import 'package:fuodz/services/geocoder.service.dart';
import 'package:fuodz/services/location.service.dart';
import 'package:fuodz/utils/app_map_settings.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/extensions/context.dart';
import 'package:fuodz/utils/utils.dart';

/// Static helpers extracted from `BaseDeliveryAddressesViewModel` so the
/// delivery-address pages can use them without inheriting from MyBaseViewModel.
class DeliveryAddressHelper {
  static final What3WordsV3 what3WordsV3Api =
      What3WordsV3(AppStrings.what3wordsApiKey);

  /// Reverse geocode lat/lng to fill in name / address / city / state / country
  /// where missing.
  static Future<DeliveryAddress> getLocationCityName(
    DeliveryAddress deliveryAddress,
  ) async {
    final coordinates = Coordinates(
      deliveryAddress.latitude ?? 0.00,
      deliveryAddress.longitude ?? 0.00,
    );
    final addresses =
        await GeocoderService().findAddressesFromCoordinates(coordinates);
    for (final address in addresses) {
      deliveryAddress.address ??= address.addressLine;
      if (deliveryAddress.name.isEmptyOrNull) {
        deliveryAddress.name = address.featureName;
      }
      if (deliveryAddress.name.isEmptyOrNull) {
        deliveryAddress.name = address.addressLine;
      }
      if (deliveryAddress.city.isEmptyOrNull) {
        deliveryAddress.city = address.subLocality;
      }
      if (deliveryAddress.state.isEmptyOrNull) {
        deliveryAddress.state = address.subAdminArea;
      }
      if (deliveryAddress.country.isEmptyOrNull) {
        deliveryAddress.country = address.countryName;
      }
      if (deliveryAddress.address != null &&
          deliveryAddress.city != null &&
          deliveryAddress.state != null &&
          deliveryAddress.country != null) {
        break;
      }
    }
    return deliveryAddress;
  }

  /// Opens the Google Place Picker (or the OPS map page) and returns the
  /// chosen `PickResult` or `Address`.
  static Future<dynamic> newPlacePicker(BuildContext context) async {
    LatLng initialPosition = const LatLng(0.00, 0.00);
    double initialZoom = 0;
    if (LocationService.currenctAddress != null) {
      initialPosition = LatLng(
        LocationService.currenctAddress?.coordinates?.latitude ?? 0.00,
        LocationService.currenctAddress?.coordinates?.longitude ?? 0.00,
      );
      initialZoom = 15;
    }
    String? mapRegion;
    try {
      mapRegion = await Utils.getCurrentCountryCode();
    } catch (_) {}
    mapRegion ??= AppStrings.countryCode.trim().split(',').firstWhere(
          (e) => !e.toLowerCase().contains('auto'),
          orElse: () => '',
        );

    if (!AppMapSettings.useGoogleOnApp) {
      return context.push(
        (context) => OPSMapPage(
          region: mapRegion,
          initialPosition: initialPosition,
          useCurrentLocation: true,
          initialZoom: initialZoom,
        ),
      );
    }
    return context.pushWidget(PlacePicker(
          apiKey: AppStrings.googleMapApiKey,
          autocompleteLanguage: translator.activeLocale.languageCode,
          region: mapRegion,
          onPlacePicked: (result) => Navigator.of(context).pop(result),
          initialPosition: initialPosition,
        ));
  }

  /// Resolve a 3-word address into coordinates and set them on the
  /// [deliveryAddress]. Returns true on success.
  static Future<bool> validateWhat3words(
    BuildContext context,
    String value,
    DeliveryAddress deliveryAddress, {
    required TextEditingController addressTEC,
  }) async {
    final coordinates =
        await what3WordsV3Api.convertToCoordinates(value).execute();
    if (coordinates.isSuccessful()) {
      addressTEC.text = coordinates.data()?.toJson()['nearestPlace'];
      deliveryAddress.address =
          coordinates.data()?.toJson()['nearestPlace'];
      deliveryAddress.latitude =
          coordinates.data()?.toJson()['coordinates']['lat'];
      deliveryAddress.longitude =
          coordinates.data()?.toJson()['coordinates']['lng'];
      final c =
          Coordinates(deliveryAddress.latitude!, deliveryAddress.longitude!);
      final addresses =
          await GeocoderService().findAddressesFromCoordinates(c);
      if (addresses.isNotEmpty) {
        deliveryAddress.city = addresses.first.locality;
      }
      return true;
    }
    final error = coordinates.error();
    if (error != null) {
      context.showToast(msg: error.message ?? '', bgColor: Colors.red);
    }
    return false;
  }

  static void shareWhat3words() {
    launchUrlString('https://what3words.com/');
  }

  /// Apply google PlacePicker `PickResult` (or fall back to plain `Address`)
  /// to the [deliveryAddress] + [addressTEC].
  static Future<DeliveryAddress> applyPickerResult(
    dynamic result,
    DeliveryAddress deliveryAddress,
    TextEditingController addressTEC,
  ) async {
    if (result is PickResult) {
      addressTEC.text = result.formattedAddress ?? '';
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
      } else {
        await getLocationCityName(deliveryAddress);
      }
    } else if (result is Address) {
      addressTEC.text = result.addressLine ?? '';
      deliveryAddress.address = result.addressLine;
      deliveryAddress.latitude = result.coordinates?.latitude;
      deliveryAddress.longitude = result.coordinates?.longitude;
      deliveryAddress.city = result.locality;
      deliveryAddress.state = result.adminArea;
      deliveryAddress.country = result.countryName;
    }
    return deliveryAddress;
  }
}
