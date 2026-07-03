import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuodz/services/app_currency_system.service.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/list/new_horizontal_vehicle_type.list_item.dart';
import 'package:fuodz/component/states/loading_indicator.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/providers/taxi_providers.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/component/custom_image.view.dart';
import 'package:fuodz/component/currency_hstack.dart';
import 'package:fuodz/utils/extensions/string.dart';

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
        constraints: BoxConstraints(maxHeight: context.percentHeight * 30),
        child: Scrollbar(
          thumbVisibility: true,
          trackVisibility: true,
          child: ListView.separated(
            scrollDirection: Axis.vertical,
            padding: const EdgeInsets.all(12),
            shrinkWrap: true,
            itemCount: taxiState.vehicleTypes.length,
            itemBuilder: (context, index) {
              final vehicleType = taxiState.vehicleTypes[index];
              final taxiController = ref.read(
                taxiControllerProvider(vendorType).notifier,
              );
              final selected =
                  taxiState.selectedVehicleType?.id == vehicleType.id;
              final currencySymbol =
                  vehicleType.currency != null
                      ? vehicleType.currency?.symbol
                      : AppStrings.currentCurrencySymbol;

              return ListTile(
                onTap:
                    () => taxiController.changeSelectedVehicleType(vehicleType),
                selected: selected,
                selectedTileColor: AppColor.primaryColor.withOpacity(0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color:
                        selected ? AppColor.primaryColor : Colors.grey.shade200,
                  ),
                ),
                leading: CustomImage(
                  imageUrl: vehicleType.photo,
                  width: 50,
                  height: 50,
                  boxFit: BoxFit.contain,
                ),
                title: vehicleType.name.text.bold.make(),
                subtitle:
                    vehicleType.hasSurge
                        ? HStack([
                          Icon(
                            Icons.trending_up_outlined,
                            color: Colors.red.shade300,
                            size: 12,
                          ),
                          " ${vehicleType.surgeRate}x ".text.sm.red500.bold
                              .make(),
                        ])
                        : const SizedBox.shrink(),
                trailing: CurrencyHStack([
                  " $currencySymbol ".text.lg.bold.make(),
                  " ${vehicleType.total.convertIf(vehicleType.currency == null)} "
                      .currencyValueFormat()
                      .text
                      .lg
                      .bold
                      .make(),
                ]),
              );
            },
            separatorBuilder: (ctx, index) => 10.heightBox,
          ),
        ),
      ),
    );
  }
}
