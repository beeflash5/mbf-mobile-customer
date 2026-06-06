import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb_v2/google_maps_place_picker.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/models/delivery_address.dart';
import 'package:fuodz/pages/shared/ops_map.page.dart';
import 'package:fuodz/services/geocoder.service.dart';
import 'package:fuodz/services/location.service.dart';
import 'package:fuodz/utils/app_map_settings.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/utils.dart';

/// Replaces `MyBaseViewModel.getLocationCityName` / `newPlacePicker` with
/// static helpers so Riverpod controllers can use them without inheritance.
class LocationPickerHelper {
  /// Fills missing name/city/state/country fields on the given address by
  /// reverse-geocoding from its lat/lng. Mirrors the old VM helper exactly.
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

  /// Opens either the OSM (`OPSMapPage`) or Google place picker depending on
  /// the env config, returning the picked result (`PickResult` or `Address`).
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
    mapRegion ??= AppStrings.countryCode.trim().split(",").firstWhere(
          (e) => !e.toLowerCase().contains("auto"),
          orElse: () => "",
        );

    if (!AppMapSettings.useGoogleOnApp) {
      return await context.pushWidget(OPSMapPage(
            region: mapRegion,
            initialPosition: initialPosition,
            useCurrentLocation: true,
            initialZoom: initialZoom,
          ));
    }
    return await context.pushWidget(Builder(
      builder: (pickerCtx) => PlacePicker(
        apiKey: AppStrings.googleMapApiKey,
        autocompleteLanguage: translator.activeLocale.languageCode,
        region: mapRegion,
        onPlacePicked: (result) => pickerCtx.popRoute(result),
        initialPosition: initialPosition,
      ),
    ));
  }
}
