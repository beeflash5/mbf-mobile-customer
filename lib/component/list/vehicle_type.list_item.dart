import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/currency_hstack.dart';
import 'package:fuodz/component/custom_image.view.dart';
import 'package:fuodz/models/vehicle_type.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/providers/taxi_providers.dart';
import 'package:fuodz/services/app_currency_system.service.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/extensions/string.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class VehicleTypeListItem extends ConsumerWidget {
  const VehicleTypeListItem({
    super.key,
    required this.vehicleType,
    required this.vendorType,
  });

  final VehicleType vehicleType;
  final VendorType vendorType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taxiState = ref.watch(taxiControllerProvider(vendorType));
    final taxiController =
        ref.read(taxiControllerProvider(vendorType).notifier);
    final selected = taxiState.selectedVehicleType?.id == vehicleType.id;
    final symbol = vehicleType.currency != null
        ? vehicleType.currency!.symbol
        : AppStrings.currentCurrencySymbol;

    return HStack(
      [
        CustomImage(
          imageUrl: vehicleType.photo,
          width: 50,
          height: 70,
          boxFit: BoxFit.contain,
        ),
        UiSpacer.horizontalSpace(space: 10),
        VStack([
          vehicleType.name.text
              .fontWeight(selected ? FontWeight.w600 : FontWeight.w400)
              .maxLines(1)
              .overflow(TextOverflow.ellipsis)
              .make(),
          CurrencyHStack([
            symbol.text
                .fontWeight(selected ? FontWeight.w600 : FontWeight.w400)
                .make(),
            "${vehicleType.currency != null ? vehicleType.total : vehicleType.total.convertCurrency}"
                .currencyValueFormat()
                .text
                .fontWeight(selected ? FontWeight.w600 : FontWeight.w400)
                .make(),
          ]),
        ]),
      ],
      alignment: MainAxisAlignment.center,
    )
        .box
        .p8
        .color(
          selected
              ? AppColor.primaryColor.withOpacity(0.15)
              : AppColor.primaryColor.withOpacity(0.01),
        )
        .roundedSM
        .make()
        .onTap(() => taxiController.changeSelectedVehicleType(vehicleType));
  }
}
