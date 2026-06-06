import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/list/horizontal_vehicle_type.list_item.dart';
import 'package:fuodz/models/vehicle_type.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/providers/taxi_providers.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class TaxiVehicleTypeListView extends ConsumerWidget {
  const TaxiVehicleTypeListView({
    super.key,
    this.min = true,
    required this.vendorType,
  });

  final VendorType vendorType;
  final bool min;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taxiState = ref.watch(taxiControllerProvider(vendorType));
    final List<VehicleType> mVehicleTypes;
    if (min && taxiState.vehicleTypes.length > 3) {
      mVehicleTypes = taxiState.vehicleTypes.sublist(0, 3);
    } else {
      mVehicleTypes = taxiState.vehicleTypes;
    }
    return CustomListView(
      padding: EdgeInsets.zero,
      noScrollPhysics: true,
      dataSet: mVehicleTypes,
      isLoading: taxiState.vehicleTypesBusy,
      itemBuilder: (context, index) {
        final vehicleType = mVehicleTypes[index];
        return HorizontalVehicleTypeListItem(
          vehicleType: vehicleType,
          vendorType: vendorType,
        );
      },
      separatorBuilder: (ctx, index) => UiSpacer.emptySpace(),
    );
  }
}
