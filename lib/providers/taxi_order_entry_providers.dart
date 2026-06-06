import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:fuodz/models/delivery_address.dart';
import 'package:fuodz/models/tax_order_location.history.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/providers/taxi_providers.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/geocoder.service.dart';
import 'package:fuodz/services/location_picker.helper.dart';
import 'package:fuodz/services/taxi.request.dart';
import 'package:fuodz/services/toast.service.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/app_ui_sizes.dart';

class TaxiOrderEntryState {
  const TaxiOrderEntryState({
    this.previousAddresses = const [],
    this.shortPreviousAddressesList = const [],
    this.customViewHeight = AppUISizes.taxiNewOrderIdleHeight,
    this.showChooseOnMap = false,
    this.selectedDate,
    this.selectedTime,
    this.places = const [],
    this.previousAddressesBusy = false,
    this.placesBusy = false,
  });

  final List<TaxiOrderLocationHistory> previousAddresses;
  final List<TaxiOrderLocationHistory> shortPreviousAddressesList;
  final double customViewHeight;
  final bool showChooseOnMap;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final List<Address> places;
  final bool previousAddressesBusy;
  final bool placesBusy;

  TaxiOrderEntryState copyWith({
    List<TaxiOrderLocationHistory>? previousAddresses,
    List<TaxiOrderLocationHistory>? shortPreviousAddressesList,
    double? customViewHeight,
    bool? showChooseOnMap,
    Object? selectedDate = _sentinel,
    Object? selectedTime = _sentinel,
    List<Address>? places,
    bool? previousAddressesBusy,
    bool? placesBusy,
  }) {
    return TaxiOrderEntryState(
      previousAddresses: previousAddresses ?? this.previousAddresses,
      shortPreviousAddressesList:
          shortPreviousAddressesList ?? this.shortPreviousAddressesList,
      customViewHeight: customViewHeight ?? this.customViewHeight,
      showChooseOnMap: showChooseOnMap ?? this.showChooseOnMap,
      selectedDate: identical(selectedDate, _sentinel)
          ? this.selectedDate
          : selectedDate as DateTime?,
      selectedTime: identical(selectedTime, _sentinel)
          ? this.selectedTime
          : selectedTime as TimeOfDay?,
      places: places ?? this.places,
      previousAddressesBusy:
          previousAddressesBusy ?? this.previousAddressesBusy,
      placesBusy: placesBusy ?? this.placesBusy,
    );
  }

  static const _sentinel = Object();
}

class TaxiOrderEntryController
    extends AutoDisposeFamilyNotifier<TaxiOrderEntryState, VendorType> {
  final TaxiRequest _taxiRequest = TaxiRequest();
  final GeocoderService _geocoderService = GeocoderService();
  final PanelController panelController = PanelController();
  Timer? _debounce;

  @override
  TaxiOrderEntryState build(VendorType arg) {
    ref.onDispose(() => _debounce?.cancel());
    return const TaxiOrderEntryState();
  }

  void initialise() {
    fetchHistoryAddresses();
    _handleEntryFocusChanges();
  }

  void _handleEntryFocusChanges() {
    final taxi = ref.read(taxiControllerProvider(arg).notifier);
    taxi.pickupLocationFocusNode.addListener(() {
      if (taxi.pickupLocationFocusNode.hasFocus ||
          taxi.dropoffLocationFocusNode.hasFocus) {
        state = state.copyWith(showChooseOnMap: true);
        taxi.setCurrentAddressSelectionStep(1);
      } else {
        state = state.copyWith(showChooseOnMap: false);
      }
    });
    taxi.dropoffLocationFocusNode.addListener(() {
      if (taxi.pickupLocationFocusNode.hasFocus ||
          taxi.dropoffLocationFocusNode.hasFocus) {
        state = state.copyWith(showChooseOnMap: true);
        taxi.setCurrentAddressSelectionStep(2);
      } else {
        state = state.copyWith(showChooseOnMap: false);
      }
    });
  }

  Future<void> fetchHistoryAddresses() async {
    updateLoadingHeight();
    state = state.copyWith(previousAddressesBusy: true);
    try {
      final list = await _taxiRequest.locationHistory();
      final shortList =
          list.length > 3 ? list.sublist(0, 3) : List<TaxiOrderLocationHistory>.from(list);
      state = state.copyWith(
        previousAddresses: list,
        shortPreviousAddressesList: shortList,
      );
      final extraHeight = shortList.length * 55.0;
      resetStateViewHeight(extraHeight);
    } catch (e) {
      // ignore: avoid_print
      print("TaxiOrderEntry fetchHistoryAddresses error: $e");
      resetStateViewHeight();
    }
    state = state.copyWith(previousAddressesBusy: false);
  }

  void updateLoadingHeight() {
    state = state.copyWith(customViewHeight: AppUISizes.taxiNewOrderHistoryHeight);
  }

  void resetStateViewHeight([double height = 0]) {
    state = state.copyWith(
      customViewHeight: AppUISizes.taxiNewOrderIdleHeight + height,
    );
  }

  Future<void> closePanel(BuildContext context) async {
    clearFocus(context);
    await panelController.close();
  }

  void clearFocus(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  Future<void> openPanel() async {
    await panelController.open();
  }

  Future<void> onDestinationSelected(
    BuildContext context,
    TaxiOrderLocationHistory value,
  ) async {
    final taxi = ref.read(taxiControllerProvider(arg).notifier);
    final taxiState = ref.read(taxiControllerProvider(arg));
    var addr = DeliveryAddress(
      address: value.address,
      latitude: value.latitude,
      longitude: value.longitude,
    );
    taxiState.checkout?.deliveryAddress = addr;
    state = state.copyWith(previousAddressesBusy: true);
    addr = await LocationPickerHelper.getLocationCityName(addr);
    state = state.copyWith(previousAddressesBusy: false);
    taxi.setDeliveryAddress(addr);
    taxi.setDropoffLocation(addr);
    taxi.dropoffLocationTEC.text = addr.address ?? "";
    await panelController.open();
  }

  Future<void> onDestinationPressed() async {
    final taxi = ref.read(taxiControllerProvider(arg).notifier);
    await openPanel();
    taxi.dropoffLocationFocusNode.requestFocus();
  }

  Future<void> onScheduleOrderPressed(BuildContext context) async {
    await openPanel();
    await showSchedulePeriodPicker(context);
  }

  Future<void> showSchedulePeriodPicker(BuildContext context) async {
    final taxi = ref.read(taxiControllerProvider(arg).notifier);
    final taxiState = ref.read(taxiControllerProvider(arg));
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: state.selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        Duration(days: AppStrings.taxiMaxScheduleDays.toInt()),
      ),
      fieldLabelText: 'Date'.tr(),
    );
    if (pickedDate == null) return;
    state = state.copyWith(selectedDate: pickedDate);
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: state.selectedTime ?? TimeOfDay.now(),
    );
    if (pickedTime == null) return;
    state = state.copyWith(selectedTime: pickedTime);
    final formattedDate = DateFormat("y-MM-d", "en").format(pickedDate);
    taxiState.checkout?.pickupDate = formattedDate;
    final pTime =
        "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
    taxiState.checkout?.pickupTime = pTime;
    taxi.calculateTotalAmount();
  }

  void clearScheduleSelection() {
    final taxiState = ref.read(taxiControllerProvider(arg));
    taxiState.checkout?.pickupTime = null;
    taxiState.checkout?.pickupDate = null;
    state = state.copyWith(selectedDate: null, selectedTime: null);
  }

  Future<void> handleChooseOnMap(BuildContext context) async {
    final taxi = ref.read(taxiControllerProvider(arg).notifier);
    if (taxi.pickupLocationFocusNode.hasFocus) {
      taxi.setCurrentAddressSelectionStep(1);
      taxi.pickupLocationFocusNode.unfocus();
    } else {
      taxi.setCurrentAddressSelectionStep(2);
      taxi.dropoffLocationFocusNode.unfocus();
    }
    final taxiState = ref.read(taxiControllerProvider(arg));
    if (taxiState.deliveryAddress == null) {
      taxi.setDeliveryAddress(DeliveryAddress());
    }
    await taxi.showDeliveryAddressPicker(context);
  }

  void searchPlace(String keyword) {
    clearAlreadySelected();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      state = state.copyWith(placesBusy: true);
      try {
        final results = await _geocoderService.findAddressesFromQuery(keyword);
        state = state.copyWith(places: results);
      } catch (e) {
        state = state.copyWith(places: []);
      }
      state = state.copyWith(placesBusy: false);
    });
  }

  Future<void> onAddressSelected(
    BuildContext context,
    Address address,
  ) async {
    AlertService.showLoading();
    try {
      final filled = await GeocoderService().fecthPlaceDetails(address);
      final mDeliveryAddress = DeliveryAddress(
        address: filled.addressLine,
        latitude: filled.coordinates?.latitude,
        longitude: filled.coordinates?.longitude,
        city: filled.locality,
        state: filled.adminArea,
        country: filled.countryName,
      );
      final taxi = ref.read(taxiControllerProvider(arg).notifier);
      final taxiState = ref.read(taxiControllerProvider(arg));
      taxi.setDeliveryAddress(mDeliveryAddress);
      taxiState.checkout?.deliveryAddress = mDeliveryAddress;
      await taxi.openLocationSelector(
        context,
        taxiState.currentAddressSelectionStep,
        showpicker: false,
      );
      state = state.copyWith(places: []);
    } catch (e) {
      // ignore: avoid_print
      print("TaxiOrderEntry onAddressSelected error: $e");
    }
    AlertService.stopLoading();
    if (context.mounted) clearFocus(context);
  }

  void clearAlreadySelected() {
    final taxi = ref.read(taxiControllerProvider(arg).notifier);
    final taxiState = ref.read(taxiControllerProvider(arg));
    if (taxiState.currentAddressSelectionStep == 1) {
      taxi.setPickupLocation(null);
    } else {
      taxi.setDropoffLocation(null);
    }
  }

  Future<void> moveToNextStep() async {
    final taxiState = ref.read(taxiControllerProvider(arg));
    if (taxiState.dropoffLocation == null) {
      ToastService.toastError(
        "Please select pickup and drop-off location".tr(),
      );
      return;
    }
    await ref
        .read(taxiControllerProvider(arg).notifier)
        .checkLocationAvailabilityForStep2();
  }
}

final taxiOrderEntryControllerProvider = NotifierProvider.autoDispose
    .family<TaxiOrderEntryController, TaxiOrderEntryState, VendorType>(
  TaxiOrderEntryController.new,
);
