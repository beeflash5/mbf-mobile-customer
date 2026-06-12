import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:dartx/dartx.dart' hide IterableFirstOrNull, StringIsNotBlankExtension;
import 'package:firestore_chat/firestore_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb_v2/google_maps_place_picker.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import 'package:fuodz/models/checkout.dart';
import 'package:fuodz/models/coupon.dart';
import 'package:fuodz/models/delivery_address.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/models/payment_method.dart';
import 'package:fuodz/models/vehicle_type.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/pages/delivery_address/widgets/address_search.view.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/cart.request.dart';
import 'package:fuodz/services/chat.service.dart';
import 'package:fuodz/services/checkout_shared.helper.dart';
import 'package:fuodz/services/geocoder.service.dart';
import 'package:fuodz/services/location.service.dart';
import 'package:fuodz/services/location_picker.helper.dart';
import 'package:fuodz/services/order.request.dart';
import 'package:fuodz/services/order_details_websocket.service.dart';
import 'package:fuodz/services/order_driver_location_websocket.service.dart';
import 'package:fuodz/services/payment.helper.dart';
import 'package:fuodz/services/taxi.request.dart';
import 'package:fuodz/services/toast.service.dart';
import 'package:fuodz/services/trip.service.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_images.dart';
import 'package:fuodz/utils/app_routes.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/app_ui_settings.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/utils/map.utils.dart';

class TaxiState {
  const TaxiState({
    this.checkout,
    this.currentOrderStep = 1,
    this.currentAddressSelectionStep = 1,
    this.onTrip = false,
    this.ignoreMapInteraction = false,
    this.mapStyle,
    this.googleMapPadding = const EdgeInsets.all(10),
    this.gMapPolylines = const {},
    this.gMapMarkers = const {},
    this.pickupLocation,
    this.dropoffLocation,
    this.deliveryAddress,
    this.driverPosition,
    this.driverPositionRotation = 0,
    this.paymentMethods = const [],
    this.selectedPaymentMethod,
    this.vehicleTypes = const [],
    this.selectedVehicleType,
    this.possibleDriverETA,
    this.onGoingOrderTrip,
    this.newTripRating = 3.0,
    this.canApplyCoupon = false,
    this.canScheduleTaxiOrder = false,
    this.coupon,
    this.subTotal = 0.0,
    this.total = 0.0,
    this.tip = 0.0,
    this.isBusy = false,
    this.couponBusy = false,
    this.couponError,
    this.vehicleTypesBusy = false,
    this.tripBusy = false,
  });

  final CheckOut? checkout;
  final int currentOrderStep;
  final int currentAddressSelectionStep;
  final bool onTrip;
  final bool ignoreMapInteraction;
  final String? mapStyle;
  final EdgeInsets googleMapPadding;
  final Set<Polyline> gMapPolylines;
  final Set<Marker> gMapMarkers;
  final DeliveryAddress? pickupLocation;
  final DeliveryAddress? dropoffLocation;
  final DeliveryAddress? deliveryAddress;
  final LatLng? driverPosition;
  final double driverPositionRotation;
  final List<PaymentMethod> paymentMethods;
  final PaymentMethod? selectedPaymentMethod;
  final List<VehicleType> vehicleTypes;
  final VehicleType? selectedVehicleType;
  final int? possibleDriverETA;
  final Order? onGoingOrderTrip;
  final double newTripRating;
  final bool canApplyCoupon;
  final bool canScheduleTaxiOrder;
  final Coupon? coupon;
  final double subTotal;
  final double total;
  final double tip;
  final bool isBusy;
  final bool couponBusy;
  final Object? couponError;
  final bool vehicleTypesBusy;
  final bool tripBusy;

  bool currentStep(int step) => step == currentOrderStep;

  TaxiState copyWith({
    Object? checkout = _sentinel,
    int? currentOrderStep,
    int? currentAddressSelectionStep,
    bool? onTrip,
    bool? ignoreMapInteraction,
    Object? mapStyle = _sentinel,
    EdgeInsets? googleMapPadding,
    Set<Polyline>? gMapPolylines,
    Set<Marker>? gMapMarkers,
    Object? pickupLocation = _sentinel,
    Object? dropoffLocation = _sentinel,
    Object? deliveryAddress = _sentinel,
    Object? driverPosition = _sentinel,
    double? driverPositionRotation,
    List<PaymentMethod>? paymentMethods,
    Object? selectedPaymentMethod = _sentinel,
    List<VehicleType>? vehicleTypes,
    Object? selectedVehicleType = _sentinel,
    Object? possibleDriverETA = _sentinel,
    Object? onGoingOrderTrip = _sentinel,
    double? newTripRating,
    bool? canApplyCoupon,
    bool? canScheduleTaxiOrder,
    Object? coupon = _sentinel,
    double? subTotal,
    double? total,
    double? tip,
    bool? isBusy,
    bool? couponBusy,
    Object? couponError = _sentinel,
    bool? vehicleTypesBusy,
    bool? tripBusy,
  }) {
    return TaxiState(
      checkout: identical(checkout, _sentinel)
          ? this.checkout
          : checkout as CheckOut?,
      currentOrderStep: currentOrderStep ?? this.currentOrderStep,
      currentAddressSelectionStep:
          currentAddressSelectionStep ?? this.currentAddressSelectionStep,
      onTrip: onTrip ?? this.onTrip,
      ignoreMapInteraction:
          ignoreMapInteraction ?? this.ignoreMapInteraction,
      mapStyle:
          identical(mapStyle, _sentinel) ? this.mapStyle : mapStyle as String?,
      googleMapPadding: googleMapPadding ?? this.googleMapPadding,
      gMapPolylines: gMapPolylines ?? this.gMapPolylines,
      gMapMarkers: gMapMarkers ?? this.gMapMarkers,
      pickupLocation: identical(pickupLocation, _sentinel)
          ? this.pickupLocation
          : pickupLocation as DeliveryAddress?,
      dropoffLocation: identical(dropoffLocation, _sentinel)
          ? this.dropoffLocation
          : dropoffLocation as DeliveryAddress?,
      deliveryAddress: identical(deliveryAddress, _sentinel)
          ? this.deliveryAddress
          : deliveryAddress as DeliveryAddress?,
      driverPosition: identical(driverPosition, _sentinel)
          ? this.driverPosition
          : driverPosition as LatLng?,
      driverPositionRotation:
          driverPositionRotation ?? this.driverPositionRotation,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      selectedPaymentMethod: identical(selectedPaymentMethod, _sentinel)
          ? this.selectedPaymentMethod
          : selectedPaymentMethod as PaymentMethod?,
      vehicleTypes: vehicleTypes ?? this.vehicleTypes,
      selectedVehicleType: identical(selectedVehicleType, _sentinel)
          ? this.selectedVehicleType
          : selectedVehicleType as VehicleType?,
      possibleDriverETA: identical(possibleDriverETA, _sentinel)
          ? this.possibleDriverETA
          : possibleDriverETA as int?,
      onGoingOrderTrip: identical(onGoingOrderTrip, _sentinel)
          ? this.onGoingOrderTrip
          : onGoingOrderTrip as Order?,
      newTripRating: newTripRating ?? this.newTripRating,
      canApplyCoupon: canApplyCoupon ?? this.canApplyCoupon,
      canScheduleTaxiOrder:
          canScheduleTaxiOrder ?? this.canScheduleTaxiOrder,
      coupon: identical(coupon, _sentinel) ? this.coupon : coupon as Coupon?,
      subTotal: subTotal ?? this.subTotal,
      total: total ?? this.total,
      tip: tip ?? this.tip,
      isBusy: isBusy ?? this.isBusy,
      couponBusy: couponBusy ?? this.couponBusy,
      couponError: identical(couponError, _sentinel)
          ? this.couponError
          : couponError,
      vehicleTypesBusy: vehicleTypesBusy ?? this.vehicleTypesBusy,
      tripBusy: tripBusy ?? this.tripBusy,
    );
  }

  static const _sentinel = Object();
}

class TaxiController
    extends AutoDisposeFamilyNotifier<TaxiState, VendorType> {
  final TaxiRequest _taxiRequest = TaxiRequest();
  final CartRequest _cartRequest = CartRequest();

  GoogleMapController? googleMapController;
  CameraPosition mapCameraPosition =
      const CameraPosition(target: LatLng(0.00, 0.00));
  BitmapDescriptor? sourceIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? driverIcon;

  final TextEditingController placeSearchTEC = TextEditingController();
  final TextEditingController pickupLocationTEC = TextEditingController();
  final TextEditingController dropoffLocationTEC = TextEditingController();
  final TextEditingController couponTEC = TextEditingController();
  final TextEditingController tripReviewTEC = TextEditingController();
  final FocusNode pickupLocationFocusNode = FocusNode();
  final FocusNode dropoffLocationFocusNode = FocusNode();

  StreamSubscription? _currentLocationListener;
  StreamSubscription? _driverLocationStream;
  StreamSubscription? _tripUpdateStream;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final PolylinePoints _polylinePoints = PolylinePoints();
  final List<LatLng> _polylineCoordinates = [];

  @override
  TaxiState build(VendorType arg) {
    ref.onDispose(() {
      _currentLocationListener?.cancel();
      _driverLocationStream?.cancel();
      _tripUpdateStream?.cancel();
      OrderDetailsWebsocketService().disconnect();
      OrderDriverLocationWebsocketService().disconnect();
      pickupLocationFocusNode.dispose();
      dropoffLocationFocusNode.dispose();
      placeSearchTEC.dispose();
      pickupLocationTEC.dispose();
      dropoffLocationTEC.dispose();
      couponTEC.dispose();
      tripReviewTEC.dispose();
    });
    return TaxiState(checkout: CheckOut());
  }

  Future<void> initialise() async {
    await fetchTaxiPaymentOptions();
    await getOnGoingTrip();
    await setupCurrentLocationAsPickuplocation();
  }

  // ===== MAP =====
  void setCurrentStep(int step) {
    state = state.copyWith(currentOrderStep: step, onTrip: false);
  }

  void updateGoogleMapPadding({required double height}) {
    state = state.copyWith(
      googleMapPadding: EdgeInsets.only(bottom: height - 20),
    );
  }

  Future<void> onMapCreated(GoogleMapController controller, BuildContext context) async {
    googleMapController = controller;
    await setGoogleMapStyle(context);
    await startUserLocationListener();
    await setSourceAndDestinationIcons();
  }

  Future<void> setGoogleMapStyle(BuildContext context) async {
    final s = await DefaultAssetBundle.of(context)
        .loadString('assets/json/google_map_style.json');
    state = state.copyWith(mapStyle: s);
  }

  Future<void> setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2.5),
      AppImages.pickupLocation,
    );
    destinationIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2.5),
      AppImages.dropoffLocation,
    );
    driverIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2.5),
      AppImages.driverCar,
    );
  }

  Future<void> updateDriverIconDynamically(VehicleType vehicleType) async {
    Uint8List? iconByteData = await MapUtils.imageToUint8List(
      base64String: vehicleType.iconBase64,
      url: vehicleType.icon,
    );
    if (iconByteData != null) {
      driverIcon = await BitmapDescriptor.fromBytes(iconByteData);
    }
  }

  Future<void> startUserLocationListener() async {
    await LocationService.prepareLocationListener();
    _currentLocationListener =
        LocationService.currenctAddressSubject.listen((currentAddress) {
      if (!state.onTrip) {
        zoomToLocation(
          LatLng(
            currentAddress.coordinates?.latitude ?? 0.00,
            currentAddress.coordinates?.longitude ?? 0.00,
          ),
        );
      }
    });
  }

  void zoomToLocation(LatLng target, {double zoom = 16}) {
    googleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: zoom),
      ),
    );
  }

  // ===== ADDRESS PICKING =====
  Future<void> openLocationSelector(
    BuildContext context,
    int step, {
    bool showpicker = true,
  }) async {
    if (showpicker) {
      await openLocationPicker(context);
    }
    final co = state.checkout;
    if (state.currentAddressSelectionStep == 1) {
      pickupLocationTEC.text = co?.deliveryAddress?.address ?? "";
      state = state.copyWith(pickupLocation: co?.deliveryAddress);
    } else {
      dropoffLocationTEC.text = co?.deliveryAddress?.address ?? "";
      state = state.copyWith(dropoffLocation: co?.deliveryAddress);
    }
  }

  Future<void> openLocationPicker(BuildContext context) async {
    final co = state.checkout;
    co?.deliveryAddress = null;
    state = state.copyWith(checkout: co, deliveryAddress: DeliveryAddress());
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (sheetCtx) {
        return AddressSearchView(
          placeSearchTEC: placeSearchTEC,
          addressSelected: (dynamic prediction) async {
            final co = state.checkout;
            var addr = state.deliveryAddress ?? DeliveryAddress();
            if (prediction is Prediction) {
              addr.address = prediction.description;
              addr.latitude = prediction.lat?.toDoubleOrNull();
              addr.longitude = prediction.lng?.toDoubleOrNull();
              co?.deliveryAddress = addr;
              state = state.copyWith(
                deliveryAddress: addr,
                checkout: co,
                isBusy: true,
              );
              addr = await LocationPickerHelper.getLocationCityName(addr);
              state = state.copyWith(deliveryAddress: addr, isBusy: false);
            } else if (prediction is Address) {
              addr.address = prediction.addressLine;
              addr.latitude = prediction.coordinates?.latitude;
              addr.longitude = prediction.coordinates?.longitude;
              addr.city = prediction.locality;
              addr.state = prediction.adminArea;
              addr.country = prediction.countryName;
              co?.deliveryAddress = addr;
              state = state.copyWith(deliveryAddress: addr, checkout: co);
            }
          },
          selectOnMap: () => showDeliveryAddressPicker(context),
        );
      },
    );
  }

  Future<DeliveryAddress> showDeliveryAddressPicker(
    BuildContext context,
  ) async {
    final result = await LocationPickerHelper.newPlacePicker(context);
    var addr = DeliveryAddress();
    if (result is PickResult) {
      addr.address = result.formattedAddress;
      addr.latitude = result.geometry?.location.lat;
      addr.longitude = result.geometry?.location.lng;
      final co = state.checkout;
      co?.deliveryAddress = addr;
      if (result.addressComponents != null &&
          result.addressComponents!.isNotEmpty) {
        for (final ac in result.addressComponents!) {
          if (ac.types.contains("locality")) addr.city = ac.longName;
          if (ac.types.contains("administrative_area_level_1")) {
            addr.state = ac.longName;
          }
          if (ac.types.contains("country")) addr.country = ac.longName;
        }
      } else {
        state = state.copyWith(isBusy: true);
        addr = await LocationPickerHelper.getLocationCityName(addr);
        state = state.copyWith(isBusy: false);
      }
      state = state.copyWith(deliveryAddress: addr, checkout: co);
      await openLocationSelector(
        context,
        state.currentAddressSelectionStep,
        showpicker: false,
      );
    } else if (result is Address) {
      addr.address = result.addressLine;
      addr.latitude = result.coordinates?.latitude;
      addr.longitude = result.coordinates?.longitude;
      addr.city = result.locality;
      addr.state = result.adminArea;
      addr.country = result.countryName;
      final co = state.checkout;
      co?.deliveryAddress = addr;
      state = state.copyWith(deliveryAddress: addr, checkout: co);
      await openLocationSelector(
        context,
        state.currentAddressSelectionStep,
        showpicker: false,
      );
    }
    return state.deliveryAddress ?? DeliveryAddress();
  }

  Future<void> setupCurrentLocationAsPickuplocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      final addresses = await GeocoderService().findAddressesFromCoordinates(
        Coordinates(pos.latitude, pos.longitude),
      );
      if (addresses.isNotEmpty) {
        final pickup = DeliveryAddress(
          name: addresses.first.featureName,
          address: addresses.first.addressLine,
          latitude: pos.latitude,
          longitude: pos.longitude,
        );
        pickupLocationTEC.text = pickup.address ?? "";
        state = state.copyWith(pickupLocation: pickup);
      }
    } catch (_) {}
  }

  void setCurrentAddressSelectionStep(int step) {
    state = state.copyWith(currentAddressSelectionStep: step);
  }

  void setDeliveryAddress(DeliveryAddress? addr) {
    state = state.copyWith(deliveryAddress: addr);
  }

  void setPickupLocation(DeliveryAddress? addr) {
    state = state.copyWith(pickupLocation: addr);
  }

  void setDropoffLocation(DeliveryAddress? addr) {
    state = state.copyWith(dropoffLocation: addr);
  }

  // ===== POLYLINES =====
  Future<void> drawTripPolyLines() async {
    final pickup = state.pickupLocation;
    final dropoff = state.dropoffLocation;
    if (pickup == null || dropoff == null) return;
    if (pickup.latitude == null || pickup.longitude == null) return;
    if (dropoff.latitude == null || dropoff.longitude == null) return;

    final markers = <Marker>{};
    markers.add(Marker(
      markerId: const MarkerId('sourcePin'),
      position: LatLng(pickup.latitude!, pickup.longitude!),
      icon: sourceIcon ?? BitmapDescriptor.defaultMarker,
      anchor: const Offset(0.5, 0.5),
    ));
    markers.add(Marker(
      markerId: const MarkerId('destPin'),
      position: LatLng(dropoff.latitude!, dropoff.longitude!),
      icon: destinationIcon ?? BitmapDescriptor.defaultMarker,
      anchor: const Offset(0.5, 0.5),
    ));

    final result = await _polylinePoints.getRouteBetweenCoordinates(
      AppStrings.googleMapApiKey,
      PointLatLng(pickup.latitude!, pickup.longitude!),
      PointLatLng(dropoff.latitude!, dropoff.longitude!),
    );
    _polylineCoordinates.clear();
    for (final p in result.points) {
      _polylineCoordinates.add(LatLng(p.latitude, p.longitude));
    }
    final polyline = Polyline(
      polylineId: const PolylineId("poly"),
      color: AppColor.primaryColor,
      points: _polylineCoordinates,
      width: 3,
    );
    state = state.copyWith(
      gMapMarkers: markers,
      gMapPolylines: {polyline},
    );

    await updateCameraLocation(
      LatLng(pickup.latitude!, pickup.longitude!),
      LatLng(dropoff.latitude!, dropoff.longitude!),
      googleMapController,
    );
  }

  Future<void> updateCameraLocation(
    LatLng source,
    LatLng destination,
    GoogleMapController? mapController,
  ) async {
    if (mapController == null) return;
    LatLngBounds bounds;
    if (source.latitude > destination.latitude &&
        source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: destination, northeast: source);
    } else if (source.longitude > destination.longitude) {
      bounds = LatLngBounds(
        southwest: LatLng(source.latitude, destination.longitude),
        northeast: LatLng(destination.latitude, source.longitude),
      );
    } else if (source.latitude > destination.latitude) {
      bounds = LatLngBounds(
        southwest: LatLng(destination.latitude, source.longitude),
        northeast: LatLng(source.latitude, destination.longitude),
      );
    } else {
      bounds = LatLngBounds(southwest: source, northeast: destination);
    }
    final cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 70);
    await _checkCameraLocation(cameraUpdate, mapController);
  }

  Future<void> _checkCameraLocation(
    CameraUpdate cameraUpdate,
    GoogleMapController mapController,
  ) async {
    mapController.animateCamera(cameraUpdate);
    final l1 = await mapController.getVisibleRegion();
    if (l1.southwest.latitude == -90) {
      return _checkCameraLocation(cameraUpdate, mapController);
    }
  }

  Future<void> zoomToCurrentLocation() async {
    var pos = await Geolocator.getLastKnownPosition();
    pos ??= await Geolocator.getCurrentPosition();
    zoomToLocation(LatLng(pos.latitude, pos.longitude));
  }

  void clearMapData() {
    _polylineCoordinates.clear();
    pickupLocationTEC.clear();
    dropoffLocationTEC.clear();
    state = state.copyWith(
      gMapMarkers: {},
      gMapPolylines: {},
    );
    _driverLocationStream?.cancel();
    setupCurrentLocationAsPickuplocation();
  }

  // ===== TRIP / WEBSOCKET =====
  Future<void> getOnGoingTrip() async {
    state = state.copyWith(tripBusy: true);
    try {
      final t = await _taxiRequest.getOnGoingTrip();
      state = state.copyWith(onGoingOrderTrip: t);
      loadTripUIByOrderStatus(initial: true);
    } catch (e) {
      // ignore: avoid_print
      print("Taxi getOnGoingTrip error: $e");
    }
    state = state.copyWith(tripBusy: false);
  }

  Future<void> cancelTrip() async {
    state = state.copyWith(tripBusy: true);
    try {
      final apiResponse = await _taxiRequest.cancelTrip(
        state.onGoingOrderTrip!.id,
      );
      if (apiResponse.allGood) {
        ToastService.toastSuccessful(
          apiResponse.message ?? "Trip cancelled successfully".tr(),
        );
        setCurrentStep(1);
        clearMapData();
      } else {
        ToastService.toastError(
          apiResponse.message ?? "Failed to cancel trip".tr(),
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print("Taxi cancelTrip error: $e");
    }
    state = state.copyWith(tripBusy: false);
  }

  void loadTripUIByOrderStatus({bool initial = false}) {
    final trip = state.onGoingOrderTrip;
    if (initial) {
      state = state.copyWith(
        pickupLocation: DeliveryAddress(
          latitude: trip?.taxiOrder?.pickupLatitude.toDoubleOrNull(),
          longitude: trip?.taxiOrder?.pickupLongitude.toDoubleOrNull(),
          address: trip?.taxiOrder?.pickupAddress,
        ),
        dropoffLocation: DeliveryAddress(
          latitude: trip?.taxiOrder?.dropoffLatitude.toDoubleOrNull(),
          longitude: trip?.taxiOrder?.dropoffLongitude.toDoubleOrNull(),
          address: trip?.taxiOrder?.dropoffAddress,
        ),
      );
      drawTripPolyLines();
      startHandlingOnGoingTrip();
    } else if (trip != null) {
      switch (trip.status) {
        case "pending":
          setCurrentStep(3);
          break;
        case "preparing":
        case "ready":
        case "enroute":
          setCurrentStep(4);
          startZoomFocusDriver();
          break;
        case "delivered":
          setCurrentStep(1);
          clearMapData();
          zoomToLocation(LatLng(
            trip.taxiOrder?.dropoffLatitude.toDoubleOrNull() ?? 0.0,
            trip.taxiOrder?.dropoffLongitude.toDoubleOrNull() ?? 0.0,
          ));
          stopAllListeners();
          setCurrentStep(6);
          break;
        case "failed":
        case "cancelled":
          setCurrentStep(1);
          clearMapData();
          stopAllListeners();
          closeOrderSummary();
          break;
      }
    }
    if (trip == null) {
      setCurrentStep(1);
      clearMapData();
      stopAllListeners();
      closeOrderSummary();
      OrderDetailsWebsocketService().disconnect();
      OrderDriverLocationWebsocketService().disconnect();
      setCurrentStep(6);
    }
  }

  Future<void> startHandlingOnGoingTrip() async {
    final trip = state.onGoingOrderTrip;
    if (trip == null || trip.isScheduled) {
      setCurrentStep(1);
      return;
    }
    setCurrentStep(3);
    loadTripUIByOrderStatus();
    if (trip.driverId != null) {
      startDriverDetailsListener();
    }
    if (AppStrings.useWebsocketAssignment) {
      OrderDetailsWebsocketService()
          .connectToOrderChannel("${trip.id}", (data) async {
        final t = state.onGoingOrderTrip;
        final driverId = data["driver_id"];
        if (driverId != null && t?.driverId == null) {
          t?.driverId = driverId;
        }
        if (t?.driver == null && driverId != null) {
          await loadDriverDetails();
        }
        if (t?.driver != null) startDriverDetailsListener();
        t?.status = data["status"] ?? "failed";
        state = state.copyWith(onGoingOrderTrip: t);
        loadTripUIByOrderStatus();
      });
    } else {
      _tripUpdateStream = _firebaseFirestore
          .collection("orders")
          .doc("${trip.code}")
          .snapshots()
          .listen((event) async {
        final t = state.onGoingOrderTrip;
        final driverId =
            event.data() != null ? event.data()!["driver_id"] : null;
        if (driverId != null && t?.driverId == null) {
          t?.driverId = event.data()!["driver_id"];
          t?.driver = event.data()!["driver"];
        }
        if (t?.driver == null) await loadDriverDetails();
        startDriverDetailsListener();
        if (event.exists) {
          t?.status = event.data()?["status"] ?? "failed";
        }
        state = state.copyWith(onGoingOrderTrip: t);
        loadTripUIByOrderStatus();
      });
    }
  }

  Future<void> loadDriverDetails() async {
    try {
      final mDriverId = state.onGoingOrderTrip?.driverId;
      var trip = await _taxiRequest.getOnGoingTrip();
      if (trip?.driver == null && mDriverId != null) {
        trip?.driver = await _taxiRequest.getDriverInfo(mDriverId);
        if (trip?.driver == null) {
          await Future.delayed(const Duration(seconds: 5));
          await loadDriverDetails();
        }
      }
      state = state.copyWith(onGoingOrderTrip: trip);
    } catch (e) {
      // ignore: avoid_print
      print("Taxi loadDriverDetails error: $e");
    }
  }

  Future<void> startDriverDetailsListener() async {
    final trip = state.onGoingOrderTrip;
    if (trip == null) return;
    if (AppStrings.useWebsocketAssignment) {
      OrderDriverLocationWebsocketService().connectToDriverLocationChannel(
        "${trip.driverId}",
        (data) async {
          final lat = data["lat"];
          final lng = data["long"] ?? data["lng"];
          final rotation = data["rotation"] ?? 0;
          if (lat != null && lng != null) {
            final pos = LatLng(
              lat.toString().toDouble(),
              lng.toString().toDouble(),
            );
            state = state.copyWith(
              driverPosition: pos,
              driverPositionRotation: double.parse(rotation.toString()),
            );
            updateDriverMarkerPosition();
            startZoomFocusDriver();
          }
        },
        onSubscribedSuccess: () =>
            OrderRequest().syncDriverLocation(trip.id),
      );
    } else {
      _driverLocationStream = _firebaseFirestore
          .collection("drivers")
          .doc("${trip.driverId}")
          .snapshots()
          .listen((event) {
        if (!event.exists) return;
        final data = event.data()!;
        final pos = LatLng(data["lat"], data["long"]);
        state = state.copyWith(
          driverPosition: pos,
          driverPositionRotation:
              double.parse((data["rotation"] ?? 0).toString()),
        );
        updateDriverMarkerPosition();
        startZoomFocusDriver();
      });
    }
  }

  Future<void> stopDriverListener() async {
    if (AppStrings.useWebsocketAssignment) {
      await OrderDriverLocationWebsocketService().disconnect();
    }
    _driverLocationStream?.cancel();
    _driverLocationStream = null;
  }

  void updateDriverMarkerPosition() {
    final markers = Set<Marker>.from(state.gMapMarkers);
    markers.removeWhere((e) => e.markerId.value == "driverMarker");
    if (state.driverPosition != null && driverIcon != null) {
      markers.add(Marker(
        markerId: const MarkerId('driverMarker'),
        position: state.driverPosition!,
        rotation: state.driverPositionRotation,
        icon: driverIcon!,
        anchor: const Offset(0.5, 0.5),
      ));
    }
    state = state.copyWith(gMapMarkers: markers);
  }

  Future<void> startZoomFocusDriver() async {
    if (state.driverPosition == null || state.onGoingOrderTrip == null) return;
    final trip = state.onGoingOrderTrip!;
    if (trip.canZoomOnPickupLocation && state.pickupLocation != null) {
      updateCameraLocation(
        state.driverPosition!,
        LatLng(
          state.pickupLocation!.latitude!,
          state.pickupLocation!.longitude!,
        ),
        googleMapController,
      );
    } else if (trip.canZoomOnDropoffLocation && state.dropoffLocation != null) {
      updateCameraLocation(
        state.driverPosition!,
        LatLng(
          state.dropoffLocation!.latitude!,
          state.dropoffLocation!.longitude!,
        ),
        googleMapController,
      );
    }
    if (trip.taxiOrder != null) {
      await updateDriverIconDynamically(trip.taxiOrder!.vehicleType);
    }
    updateDriverMarkerPosition();
  }

  Future<void> stopAllListeners() async {
    _tripUpdateStream?.cancel();
    _driverLocationStream?.cancel();
    if (AppStrings.useWebsocketAssignment) {
      await OrderDriverLocationWebsocketService().disconnect();
      await OrderDetailsWebsocketService().disconnect();
    }
    state = state.copyWith(
      selectedVehicleType: null,
      selectedPaymentMethod: state.paymentMethods.firstOrNull,
      possibleDriverETA: null,
    );
  }

  void dismissTripRating() {
    tripReviewTEC.clear();
    setCurrentStep(1);
    zoomToCurrentLocation();
  }

  Future<void> submitTripRating(Order order) async {
    state = state.copyWith(tripBusy: true);
    final apiResponse = await _taxiRequest.rateDriver(
      order.id,
      order.driverId!,
      state.newTripRating,
      tripReviewTEC.text,
    );
    if (apiResponse.allGood) {
      ToastService.toastSuccessful(
        apiResponse.message ?? "Trip rated successfully".tr(),
      );
      dismissTripRating();
    } else {
      ToastService.toastError(
        apiResponse.message ?? "Failed to rate trip".tr(),
      );
    }
    state = state.copyWith(tripBusy: false);
  }

  void closeOrderSummary({bool clear = true}) {
    if (clear) {
      pickupLocationTEC.clear();
      dropoffLocationTEC.clear();
      state = state.copyWith(
        pickupLocation: null,
        dropoffLocation: null,
        selectedVehicleType: null,
        selectedPaymentMethod: state.paymentMethods.firstOrNull,
        possibleDriverETA: null,
      );
    }
    clearMapData();
    setCurrentStep(1);
  }

  void setNewTripRating(double r) {
    state = state.copyWith(newTripRating: r);
  }

  // ===== ORDER FLOW =====
  bool currentStep(int step) => state.currentOrderStep == step;

  void couponCodeChange(String code) {
    state = state.copyWith(canApplyCoupon: code.trim().isNotEmpty);
  }

  void toggleScheduleTaxiOrder(bool enabled) {
    final co = state.checkout;
    if (!enabled) {
      co?.pickupDate = null;
      co?.pickupTime = null;
    }
    state = state.copyWith(
      canScheduleTaxiOrder: enabled,
      checkout: co,
    );
  }

  Future<void> applyCoupon() async {
    state = state.copyWith(couponBusy: true);
    try {
      final coupon = await _cartRequest.fetchCoupon(
        couponTEC.text,
        vendorTypeId: arg.id,
      );
      if (coupon.useLeft <= 0) throw "Coupon use limit exceeded".tr();
      if (coupon.expired) throw "Coupon has expired".tr();
      state = state.copyWith(coupon: coupon, couponError: null);
      calculateTotalAmount();
    } catch (error) {
      state = state.copyWith(couponError: error);
    }
    state = state.copyWith(couponBusy: false);
  }

  Future<void> proceedToStep2(BuildContext context) async {
    if (state.dropoffLocation == null) {
      ToastService.toastError(
        "Please select pickup and drop-off location".tr(),
      );
      return;
    }
    final co = state.checkout;
    if (state.canScheduleTaxiOrder &&
        (co?.pickupDate == null || co?.pickupTime == null)) {
      ToastService.toastError(
        "Please select pickup date and pickup time".tr(),
      );
      return;
    }
    await checkLocationAvailabilityForStep2();
  }

  Future<void> checkLocationAvailabilityForStep2() async {
    state = state.copyWith(isBusy: true);
    final apiResponse = await _taxiRequest.locationAvailable(
      state.pickupLocation?.latitude ?? 0.00,
      state.pickupLocation?.longitude ?? 0.00,
    );
    if (apiResponse.allGood) {
      prepareStep2();
    } else {
      setCurrentStep(0);
    }
    state = state.copyWith(isBusy: false);
  }

  void prepareStep2() {
    setCurrentStep(2);
    drawTripPolyLines();
    fetchVehicleTypes();
  }

  Future<void> fetchVehicleTypes() async {
    state = state.copyWith(vehicleTypesBusy: true);
    try {
      final types = await _taxiRequest.getVehicleTypePricing(
        state.pickupLocation!,
        state.dropoffLocation!,
        countryCode: LocationService.currenctAddress?.countryCode,
        vendorType: arg.slug,
      );
      state = state.copyWith(vehicleTypes: types);
    } catch (e) {
      // ignore: avoid_print
      print("Taxi fetchVehicleTypes error: $e");
    }
    state = state.copyWith(vehicleTypesBusy: false);
  }

  void changeSelectedVehicleType(VehicleType vehicleType) {
    state = state.copyWith(selectedVehicleType: vehicleType);
    calculateTotalAmount();
    generatePossibleDriverETA();
  }

  void calculateTotalAmount() {
    final v = state.selectedVehicleType;
    final co = state.checkout;
    if (v == null) return;
    var sub = v.total;
    if (state.coupon != null) {
      if (state.coupon!.percentage == 1) {
        co?.discount = (state.coupon!.discount / 100) * sub;
      } else {
        co?.discount = state.coupon!.discount;
      }
    } else {
      co?.discount = 0;
    }
    sub = sub - (co?.discount ?? 0);
    sub = sub - v.tax;
    final total = sub + v.tax;
    state = state.copyWith(subTotal: sub, total: total, checkout: co);
  }

  Future<void> generatePossibleDriverETA() async {
    state = state.copyWith(isBusy: true);
    try {
      final eta = await TripService().generatePossibleDriverETA(
        lat: state.pickupLocation!.latitude!,
        lng: state.pickupLocation!.longitude!,
        vehicleTypeId: state.selectedVehicleType?.id,
      );
      state = state.copyWith(possibleDriverETA: eta);
    } catch (e) {
      // ignore: avoid_print
      print("Taxi generatePossibleDriverETA error: $e");
    }
    state = state.copyWith(isBusy: false);
  }

  Future<void> processNewOrder(BuildContext context) async {
    final params = {
      "payment_method_id": state.selectedPaymentMethod?.id,
      "vehicle_type_id": state.selectedVehicleType?.id,
      "pickup": {
        "lat": state.pickupLocation!.latitude,
        "lng": state.pickupLocation!.longitude,
        "address": state.pickupLocation!.address,
      },
      "dropoff": {
        "lat": state.dropoffLocation!.latitude,
        "lng": state.dropoffLocation!.longitude,
        "address": state.dropoffLocation!.address,
      },
      "sub_total": state.subTotal,
      "tax": state.selectedVehicleType?.tax,
      "total": state.total,
      "discount": state.checkout?.discount,
      "tip": state.tip,
      "coupon_code": state.coupon?.code,
      "vehicle_type": state.selectedVehicleType?.encrypted,
      "pickup_date": state.checkout?.pickupDate,
      "pickup_time": state.checkout?.pickupTime,
    };
    state = state.copyWith(isBusy: true);
    final apiResponse = await _taxiRequest.placeNeworder(params: params);
    state = state.copyWith(isBusy: false);
    if (!apiResponse.allGood) {
      AlertService.error(title: "Order failed".tr(), text: apiResponse.message);
    } else {
      final order = Order.fromJson(apiResponse.body["order"]);
      state = state.copyWith(onGoingOrderTrip: order);
      final paymentLink = apiResponse.body["link"];
      if (paymentLink != null && paymentLink.toString().trim().isNotEmpty) {
        await PaymentHelper.openWebpageLink(context, paymentLink.toString());
      }
      if (state.checkout?.pickupDate == null || !state.canScheduleTaxiOrder) {
        startHandlingOnGoingTrip();
      } else {
        closeOrderSummary();
      }
    }
  }

  void openTripChat(BuildContext context) {
    final trip = state.onGoingOrderTrip;
    if (trip == null) return;
    
    final extra = {
      'orderCode': trip.code,
      'chatType': 'customerDriver',
      'receiverId': trip.driver?.id ?? 0,
    };
    context.pushRoute(AppRoutes.chatRoute, extra: extra);
  }

  Future<Order?> getLastTripForRating() async {
    try {
      final order = await _taxiRequest.getLastTripForRating();
      if (order == null || order.driver == null) {
        setCurrentStep(1);
      }
      return order;
    } catch (_) {
      return null;
    }
  }

  // ===== PAYMENT =====
  Future<void> fetchTaxiPaymentOptions() async {
    try {
      final methods = await CheckoutSharedHelpers.getTaxiPaymentOptions();
      state = state.copyWith(paymentMethods: methods);
      _updatePaymentOptionSelection();
    } catch (e) {
      // ignore: avoid_print
      print("Taxi fetchPaymentOptions error: $e");
    }
  }

  void _updatePaymentOptionSelection() {
    if (state.selectedPaymentMethod == null && state.paymentMethods.isNotEmpty) {
      state = state.copyWith(
        selectedPaymentMethod: state.paymentMethods.first,
      );
    }
  }

  void changeSelectedPaymentMethod(
    PaymentMethod? paymentMethod, {
    bool callTotal = true,
  }) {
    final co = state.checkout;
    co?.paymentMethod = paymentMethod;
    state = state.copyWith(
      selectedPaymentMethod: paymentMethod,
      checkout: co,
    );
    if (callTotal) calculateTotalAmount();
  }
}

final taxiControllerProvider = NotifierProvider.autoDispose
    .family<TaxiController, TaxiState, VendorType>(
  TaxiController.new,
);
