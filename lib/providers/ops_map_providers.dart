import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:fuodz/services/geocoder.service.dart';
import 'package:fuodz/services/toast.service.dart';

class OpsMapState {
  const OpsMapState({
    this.selectedAddress,
    this.googleMapPadding = const EdgeInsets.all(10),
    this.gMarkers = const {},
    this.centerMarker,
    this.isBusy = false,
  });
  final Address? selectedAddress;
  final EdgeInsets googleMapPadding;
  final Map<MarkerId, Marker> gMarkers;
  final Marker? centerMarker;
  final bool isBusy;

  OpsMapState copyWith({
    Address? selectedAddress,
    EdgeInsets? googleMapPadding,
    Map<MarkerId, Marker>? gMarkers,
    Marker? centerMarker,
    bool? isBusy,
    bool clearSelectedAddress = false,
  }) =>
      OpsMapState(
        selectedAddress:
            clearSelectedAddress ? null : (selectedAddress ?? this.selectedAddress),
        googleMapPadding: googleMapPadding ?? this.googleMapPadding,
        gMarkers: gMarkers ?? this.gMarkers,
        centerMarker: centerMarker ?? this.centerMarker,
        isBusy: isBusy ?? this.isBusy,
      );
}

class OpsMapController extends Notifier<OpsMapState> {
  final GeocoderService _geocoderService = GeocoderService();
  final MarkerId _centerMarkerId = const MarkerId('center_loc_marker');
  GoogleMapController? _gMapController;
  Timer? _debounce;

  @override
  OpsMapState build() {
    ref.onDispose(() {
      _debounce?.cancel();
    });
    return const OpsMapState();
  }

  void onMapCreated(GoogleMapController controller) {
    _gMapController = controller;
  }

  Future<List<Address>> fetchPlaces(String keyword) async {
    return _geocoderService.findAddressesFromQuery(keyword);
  }

  Future<Address> fetchPlaceDetails(Address address) async {
    return _geocoderService.fecthPlaceDetails(address);
  }

  Future<void> addressSelected(Address address, {bool moveCamera = true}) async {
    state = state.copyWith(isBusy: true);
    Address selected = address;
    if (address.gMapPlaceId != null) {
      selected = await _geocoderService.fecthPlaceDetails(address);
    }
    if (moveCamera) {
      final lat =
          address.coordinates?.latitude ?? selected.coordinates?.latitude ?? 0.0;
      final lng = address.coordinates?.longitude ??
          selected.coordinates?.longitude ??
          0.0;
      _gMapController?.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(zoom: 16, target: LatLng(lat, lng)),
        ),
      );
    }
    state = state.copyWith(selectedAddress: selected, isBusy: false);
  }

  void updateMapPadding(Size size) {
    state = state.copyWith(
      googleMapPadding: EdgeInsets.only(bottom: size.height + 10),
    );
  }

  void mapCameraMove(CameraPosition position) {
    final marker = state.centerMarker == null
        ? Marker(
            markerId: _centerMarkerId,
            position: position.target,
            draggable: true,
          )
        : state.centerMarker!.copyWith(positionParam: position.target);
    state = state.copyWith(
      centerMarker: marker,
      gMarkers: {...state.gMarkers, _centerMarkerId: marker},
    );

    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () async {
      state = state.copyWith(isBusy: true, clearSelectedAddress: true);
      try {
        final addresses = await _geocoderService.findAddressesFromCoordinates(
          Coordinates(position.target.latitude, position.target.longitude),
        );
        if (addresses.isNotEmpty) {
          final address = addresses.first;
          await addressSelected(address, moveCamera: false);
        } else {
          state = state.copyWith(isBusy: false);
        }
      } catch (e) {
        ToastService.toastError('$e');
        state = state.copyWith(isBusy: false);
      }
    });
  }
}

final opsMapControllerProvider =
    NotifierProvider<OpsMapController, OpsMapState>(OpsMapController.new);
