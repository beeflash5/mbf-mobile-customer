import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:fuodz/models/order.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_images.dart';
import 'package:fuodz/utils/app_strings.dart';

class OrderTrackingState {
  const OrderTrackingState({
    this.mapMarkers = const {},
    this.polylines = const {},
    this.pickupLatLng,
    this.destinationLatLng,
    this.driverLatLng,
  });
  final Set<Marker> mapMarkers;
  final Map<PolylineId, Polyline> polylines;
  final LatLng? pickupLatLng;
  final LatLng? destinationLatLng;
  final LatLng? driverLatLng;

  OrderTrackingState copyWith({
    Set<Marker>? mapMarkers,
    Map<PolylineId, Polyline>? polylines,
    LatLng? pickupLatLng,
    LatLng? destinationLatLng,
    LatLng? driverLatLng,
  }) => OrderTrackingState(
    mapMarkers: mapMarkers ?? this.mapMarkers,
    polylines: polylines ?? this.polylines,
    pickupLatLng: pickupLatLng ?? this.pickupLatLng,
    destinationLatLng: destinationLatLng ?? this.destinationLatLng,
    driverLatLng: driverLatLng ?? this.driverLatLng,
  );
}

class OrderTrackingController
    extends FamilyAsyncNotifier<OrderTrackingState, Order> {
  GoogleMapController? _mapController;
  final PolylinePoints _polylinePoints = PolylinePoints();
  StreamSubscription? _driverLocationSub;

  @override
  Future<OrderTrackingState> build(Order arg) async {
    ref.onDispose(() => _driverLocationSub?.cancel());
    final markers = <Marker>{};
    final pickupIcon = await _markerIcon(
      arg.isPackageDelivery ? AppImages.addressPin : AppImages.vendor,
    );
    final pickupLatLng = LatLng(
      arg.isPackageDelivery
          ? arg.pickupLocation!.latitude!
          : double.parse(arg.vendor!.latitude),
      arg.isPackageDelivery
          ? arg.pickupLocation!.longitude!
          : double.parse(arg.vendor!.longitude),
    );
    markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: pickupLatLng,
        infoWindow: InfoWindow(
          title:
              arg.isPackageDelivery
                  ? arg.pickupLocation?.name
                  : arg.vendor?.name,
        ),
        icon: pickupIcon,
      ),
    );

    final deliveryIcon = await _markerIcon(AppImages.deliveryParcel);
    final destinationLatLng = LatLng(
      arg.isPackageDelivery
          ? arg.dropoffLocation!.latitude!
          : arg.deliveryAddress!.latitude!,
      arg.isPackageDelivery
          ? arg.dropoffLocation!.longitude!
          : arg.deliveryAddress!.longitude!,
    );
    markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: destinationLatLng,
        infoWindow: InfoWindow(
          title:
              arg.isPackageDelivery
                  ? arg.dropoffLocation?.name
                  : arg.deliveryAddress?.name,
        ),
        icon: deliveryIcon,
      ),
    );

    final newState = OrderTrackingState(
      mapMarkers: markers,
      pickupLatLng: pickupLatLng,
      destinationLatLng: destinationLatLng,
    );

    // schedule async work
    Future(() async {
      await _loadPolyline(pickupLatLng, destinationLatLng);
      _listenToDriverLocation(arg);
    });

    return newState;
  }

  Future<void> _loadPolyline(LatLng pickup, LatLng destination) async {
    final result = await _polylinePoints.getRouteBetweenCoordinates(
      AppStrings.googleMapApiKey,
      PointLatLng(pickup.latitude, pickup.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.driving,
    );
    if (result.points.isEmpty) return;
    final coords =
        result.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
    final cur = state.valueOrNull;
    if (cur == null) return;
    const polyId = PolylineId('poly');
    final polyline = Polyline(
      color: AppColor.primaryColor,
      polylineId: polyId,
      points: coords,
      width: 3,
    );
    state = AsyncData(cur.copyWith(polylines: {polyId: polyline}));
  }

  void _listenToDriverLocation(Order order) {
    _driverLocationSub?.cancel();
    _driverLocationSub = FirebaseFirestore.instance
        .collection('drivers')
        .doc('${order.driverId}')
        .snapshots()
        .listen((event) async {
          final cur = state.valueOrNull;
          if (cur == null) return;
          final driverInfo = event.data();
          final driverLatLng = LatLng(
            (driverInfo?['lat'] as num?)?.toDouble() ?? 0.0,
            (driverInfo?['long'] as num?)?.toDouble() ?? 0.0,
          );
          final markers = {...cur.mapMarkers};
          final existing = markers.firstOrNullWhere(
            (m) => m.markerId.value.contains('driverLocation'),
          );
          Marker marker;
          if (existing == null) {
            final icon = await _markerIcon(AppImages.deliveryBoy);
            marker = Marker(
              markerId: const MarkerId('driverLocation'),
              position: driverLatLng,
              infoWindow: InfoWindow.noText,
              icon: icon,
            );
          } else {
            markers.remove(existing);
            marker = existing.copyWith(positionParam: driverLatLng);
          }
          markers.add(marker);
          state = AsyncData(
            cur.copyWith(mapMarkers: markers, driverLatLng: driverLatLng),
          );
          _zoomToBound();
        });
  }

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
    _zoomToBound();
  }

  void _zoomToBound() {
    final cur = state.valueOrNull;
    if (cur == null ||
        cur.driverLatLng == null ||
        cur.destinationLatLng == null) {
      return;
    }
    final bound = _boundsFromLatLngList([
      cur.driverLatLng!,
      cur.destinationLatLng!,
    ]);
    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bound, 80));
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (final latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > (x1 ?? 0.0)) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > (y1 ?? 0.0)) y1 = latLng.longitude;
        if (latLng.longitude < (y0 ?? 0.0)) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
      northeast: LatLng(x1 ?? 0.0, y1 ?? 0.0),
      southwest: LatLng(x0 ?? 0.0, y0 ?? 0.0),
    );
  }

  Future<BitmapDescriptor> _markerIcon(String assetPath) {
    return BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 1.1, size: Size(24, 24)),
      assetPath,
    );
  }

  void callDriver() {
    launchUrlString('tel:${arg.driver?.phone}');
  }
}

final orderTrackingControllerProvider = AsyncNotifierProvider.family<
  OrderTrackingController,
  OrderTrackingState,
  Order
>(OrderTrackingController.new);
