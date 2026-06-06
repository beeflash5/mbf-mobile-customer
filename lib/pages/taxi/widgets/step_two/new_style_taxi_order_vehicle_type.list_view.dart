import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/list/new_horizontal_vehicle_type.list_item.dart';
import 'package:fuodz/component/states/loading_indicator.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/providers/taxi_providers.dart';

class NewTaxiVehicleTypeListView extends ConsumerWidget {
  const NewTaxiVehicleTypeListView({
    super.key,
    this.min = false,
    required this.vendorType,
    this.axis = Axis.vertical,
  });

  final VendorType vendorType;
  final bool min;
  final Axis axis;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taxiState = ref.watch(taxiControllerProvider(vendorType));
    return LoadingIndicator(
      loading: taxiState.vehicleTypesBusy,
      child: Container(
        constraints: BoxConstraints(maxHeight: context.percentHeight * 20),
        child: Scrollbar(
          thumbVisibility: true,
          trackVisibility: true,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            physics: const PageScrollPhysics(),
            itemCount: taxiState.vehicleTypes.length,
            itemBuilder: (context, index) {
              final vehicleType = taxiState.vehicleTypes[index];
              return SizedBox(
                width: context.percentWidth * 35,
                child: NewHorizontalVehicleTypeListItem(
                  vehicleType: vehicleType,
                  vendorType: vendorType,
                ),
              );
            },
            separatorBuilder: (ctx, index) => 10.widthBox,
          ),
        ),
      ),
    );
  }
}
