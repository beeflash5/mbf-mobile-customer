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
import 'package:fuodz/utils/sizes.dart';

class NewHorizontalVehicleTypeListItem extends ConsumerWidget {
  const NewHorizontalVehicleTypeListItem({
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
    final currencySymbol = vehicleType.currency != null
        ? vehicleType.currency?.symbol
        : AppStrings.currentCurrencySymbol;

    return VStack(
      [
        CustomImage(
          imageUrl: vehicleType.photo,
          height: context.percentWidth * 12,
          boxFit: BoxFit.fitWidth,
        ).centered(),
        Sizes.paddingSizeDefault.heightBox,
        VStack([
          CurrencyHStack([
            " $currencySymbol ".text.lg.bold.make(),
            " ${vehicleType.total.convertIf(vehicleType.currency == null)} "
                .currencyValueFormat()
                .text
                .lg
                .bold
                .make(),
          ]),
          if (vehicleType.hasSurge)
            HStack([
              Icon(
                Icons.trending_up_outlined,
                color: Colors.red.shade300,
                size: 12,
              ),
              " ${vehicleType.surgeRate}x ".text.sm.red500.bold.make(),
            ]),
        ]),
        vehicleType.name.text.bold.maxLines(1).ellipsis.make(),
      ],
      alignment: MainAxisAlignment.center,
      crossAlignment: CrossAxisAlignment.center,
      spacing: Sizes.paddingSizeExtraSmall,
    )
        .box
        .p4
        .border(
          color: selected ? AppColor.primaryColor : Colors.grey.shade200,
          width: 1,
        )
        .color(
          selected
              ? AppColor.primaryColor.withOpacity(0.20)
              : AppColor.primaryColor.withOpacity(0.05),
        )
        .roundedSM
        .make()
        .onTap(() => taxiController.changeSelectedVehicleType(vehicleType))
        .wFull(context);
  }
}
