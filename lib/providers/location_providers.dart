import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import 'package:fuodz/models/delivery_address.dart';
import 'package:fuodz/services/location.service.dart';

/// App-wide current delivery address (set via picker or device geolocation).
/// Listens to LocationService.currenctDeliveryAddressSubject so any update
/// from other modules (cart, checkout, address picker) flows through here.
class CurrentDeliveryAddressController extends AsyncNotifier<DeliveryAddress?> {
  @override
  Future<DeliveryAddress?> build() async {
    final sub = LocationService.currenctDeliveryAddressSubject.listen((addr) {
      state = AsyncData(addr);
    });
    ref.onDispose(sub.cancel);
    DeliveryAddress? cur = LocationService.deliveryaddress;
    cur ??= await LocationService.getLocallySaveAddress();
    return cur;
  }

  Future<void> useUserLocation() async {
    await LocationService.geocodeCurrentLocation();
  }

  /// Equivalent of MyBaseViewModel.fetchCurrentLocation.
  Future<void> fetchCurrentLocation() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final pos = await Geolocator.getCurrentPosition();
      final address = await LocationService.addressFromCoordinates(
        lat: pos.latitude,
        lng: pos.longitude,
      );
      LocationService.currenctAddress = address;
      if (address != null) {
        LocationService.currenctAddressSubject.sink.add(address);
      }
      final cur = state.valueOrNull ?? DeliveryAddress();
      cur.address = address?.addressLine;
      cur.latitude = address?.coordinates?.latitude;
      cur.longitude = address?.coordinates?.longitude;
      cur.name = 'Current Location'.tr();
      LocationService.deliveryaddress = cur;
      LocationService.currenctDeliveryAddressSubject.add(cur);
      return cur;
    });
  }

  void setAddress(DeliveryAddress addr) {
    LocationService.deliveryaddress = addr;
    LocationService.currenctDeliveryAddressSubject.add(addr);
    state = AsyncData(addr);
  }
}

final currentDeliveryAddressControllerProvider =
    AsyncNotifierProvider<CurrentDeliveryAddressController, DeliveryAddress?>(
      CurrentDeliveryAddressController.new,
    );
