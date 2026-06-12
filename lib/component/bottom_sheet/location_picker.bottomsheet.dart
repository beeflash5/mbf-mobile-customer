import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:fuodz/services/location_picker.helper.dart';
import 'package:google_maps_place_picker_mb_v2/google_maps_place_picker.dart';

import 'package:fuodz/providers/location_providers.dart';
import 'package:fuodz/services/geocoder.service.dart';
import 'package:fuodz/services/location.service.dart';
import 'package:fuodz/utils/app_map_settings.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/component/busy_indicator.dart';
import 'package:fuodz/component/filters/ops_autocomplete.dart';

/// Location picker bottom sheet — mirrors Next.js LocationPicker.tsx.
///
/// Features:
/// - Google Places Autocomplete search (if Google Maps is enabled)
/// - OPS Geocoder text search (fallback)
/// - "Use Current Location" button
/// - Updates [LocationService.currenctAddress] + notifies [currenctAddressSubject]
///
/// Usage:
/// ```dart
/// showLocationPickerSheet(context, ref);
/// ```
Future<void> showLocationPickerSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (_) => ProviderScope(
          parent: ProviderScope.containerOf(context),
          child: _LocationPickerSheet(containerRef: ref),
        ),
  );
}

class _LocationPickerSheet extends ConsumerStatefulWidget {
  const _LocationPickerSheet({required this.containerRef});
  final WidgetRef containerRef;

  @override
  ConsumerState<_LocationPickerSheet> createState() =>
      _LocationPickerSheetState();
}

class _LocationPickerSheetState extends ConsumerState<_LocationPickerSheet> {
  final TextEditingController _searchTEC = TextEditingController();
  bool _locating = false;
  String? _error;

  @override
  void dispose() {
    _searchTEC.dispose();
    super.dispose();
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  void _applyAddress(Address address) {
    LocationService.currenctAddress = address;
    LocationService.currenctAddressSubject.add(address);
    // Also push to delivery address subject so vendor lists refresh
    widget.containerRef
        .read(currentDeliveryAddressControllerProvider.notifier)
        .fetchCurrentLocation();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _locating = true;
      _error = null;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() => _error = 'Location permission was denied.'.tr());
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final addresses = await GeocoderService().findAddressesFromCoordinates(
        Coordinates(pos.latitude, pos.longitude),
        limit: 1,
      );

      if (addresses.isNotEmpty) {
        _applyAddress(addresses.first);
      } else {
        setState(() => _error = "Couldn't resolve your location.".tr());
      }
    } catch (e) {
      setState(() => _error = "Couldn't get current location.".tr());
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── drag handle ──────────────────────────────────────────────
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // ── header ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Set your location".tr(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Divider(height: 1, color: Colors.grey.shade200),
              const SizedBox(height: 16),

              // ── search field ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child:
                    AppMapSettings.useGoogleOnApp
                        ? _GoogleSearchField(
                          tec: _searchTEC,
                          onPredictionPicked: (prediction) async {
                            if (prediction.placeId == null) return;
                            // convert prediction to Address via geocoder detail
                            final tmpAddr = Address();
                            tmpAddr.gMapPlaceId = prediction.placeId!;
                            tmpAddr.addressLine = prediction.description;
                            tmpAddr.featureName =
                                prediction.structuredFormatting?.mainText ??
                                prediction.description;
                            final detailed = await GeocoderService()
                                .fecthPlaceDetails(tmpAddr);
                            _applyAddress(detailed);
                          },
                        )
                        : _OpsSearchField(
                          tec: _searchTEC,
                          onAddressSelected: _applyAddress,
                        ),
              ),
              const SizedBox(height: 16),

              // ── use current location button ───────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _locating ? null : _useCurrentLocation,
                    icon:
                        _locating
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Icon(Icons.my_location, size: 18),
                    label: Text(
                      _locating
                          ? "Locating...".tr()
                          : "Use current location".tr(),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // ── choose on map button ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final result = await LocationPickerHelper.newPlacePicker(context);
                      if (result == null) return;
                      if (result is PickResult) {
                        String? locality;
                        String? adminArea;
                        String? countryName;
                        if (result.addressComponents != null && result.addressComponents!.isNotEmpty) {
                          for (final c in result.addressComponents!) {
                            if (c.types.contains('locality')) locality = c.longName;
                            if (c.types.contains('administrative_area_level_1')) {
                              adminArea = c.longName;
                            }
                            if (c.types.contains('country')) countryName = c.longName;
                          }
                        }
                        final address = Address(
                          addressLine: result.formattedAddress,
                          featureName: result.name ?? result.formattedAddress,
                          coordinates: Coordinates(
                            result.geometry?.location.lat ?? 0.0,
                            result.geometry?.location.lng ?? 0.0,
                          ),
                          locality: locality,
                          adminArea: adminArea,
                          countryName: countryName,
                        );
                        _applyAddress(address);
                      } else if (result is Address) {
                        _applyAddress(result);
                      }
                    },
                    icon: const Icon(Icons.map, size: 18),
                    label: Text("Choose on Map".tr()),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),

              // ── error ─────────────────────────────────────────────────────
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

              const Spacer(),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Google Places Autocomplete field
// ─────────────────────────────────────────────────────────────────────────────
class _GoogleSearchField extends StatefulWidget {
  const _GoogleSearchField({
    required this.tec,
    required this.onPredictionPicked,
  });

  final TextEditingController tec;
  final Future<void> Function(Prediction) onPredictionPicked;

  @override
  State<_GoogleSearchField> createState() => _GoogleSearchFieldState();
}

class _GoogleSearchFieldState extends State<_GoogleSearchField> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GooglePlaceAutoCompleteTextField(
          textEditingController: widget.tec,
          googleAPIKey: AppStrings.googleMapApiKey,
          inputDecoration: InputDecoration(
            hintText: "Search for location / address".tr(),
            prefixIcon: const Icon(Icons.search, size: 20),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 1.5,
              ),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          debounceTime: 600,
          countries: null,
          isLatLngRequired: false,
          getPlaceDetailWithLatLng: (Prediction prediction) async {
            setState(() => _isLoading = true);
            await widget.onPredictionPicked(prediction);
            if (mounted) setState(() => _isLoading = false);
          },
          itemClick: (Prediction prediction) {
            widget.tec.text = prediction.description ?? '';
            widget.tec.selection = TextSelection.fromPosition(
              TextPosition(offset: prediction.description?.length ?? 0),
            );
          },
        ),
        if (_isLoading)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: BusyIndicator().centered(),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OPS (backend geocoder) search field
// ─────────────────────────────────────────────────────────────────────────────
class _OpsSearchField extends StatelessWidget {
  const _OpsSearchField({required this.tec, required this.onAddressSelected});

  final TextEditingController tec;
  final void Function(Address) onAddressSelected;

  @override
  Widget build(BuildContext context) {
    return OPSAutocompleteTextField(
      textEditingController: tec,
      inputDecoration: InputDecoration(
        hintText: "Search for location / address".tr(),
        prefixIcon: const Icon(Icons.search, size: 20),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 1.5,
          ),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      debounceTime: 600,
      onselected: onAddressSelected,
    );
  }
}
