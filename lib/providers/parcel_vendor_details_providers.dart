import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/models/package_type_pricing.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/services/package.request.dart';

final _packageRequestProvider = Provider<PackageRequest>(
  (_) => PackageRequest(),
);

class ParcelVendorState {
  const ParcelVendorState({
    this.pricings = const [],
    this.countries = const [],
    this.states = const [],
    this.cities = const [],
  });
  final List<PackageTypePricing> pricings;
  final List<String> countries;
  final List<String> states;
  final List<String> cities;

  ParcelVendorState copyWith({
    List<PackageTypePricing>? pricings,
    List<String>? countries,
    List<String>? states,
    List<String>? cities,
  }) => ParcelVendorState(
    pricings: pricings ?? this.pricings,
    countries: countries ?? this.countries,
    states: states ?? this.states,
    cities: cities ?? this.cities,
  );
}

class ParcelVendorDetailsController
    extends FamilyAsyncNotifier<ParcelVendorState, Vendor> {
  @override
  Future<ParcelVendorState> build(Vendor arg) async {
    final req = ref.read(_packageRequestProvider);
    final pricingsFuture = req.fetchVendorPackageTypePricings(vendor: arg);
    final areasFuture = req.fetchVendorPackageAreaOfOperations(vendor: arg);
    final pricings = await pricingsFuture;
    final areas = await areasFuture;
    return ParcelVendorState(
      pricings: pricings,
      cities: areas[0],
      states: areas[1],
      countries: areas[2],
    );
  }
}

final parcelVendorDetailsControllerProvider = AsyncNotifierProvider.family<
  ParcelVendorDetailsController,
  ParcelVendorState,
  Vendor
>(ParcelVendorDetailsController.new);
