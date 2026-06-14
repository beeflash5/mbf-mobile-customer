import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:timelines_plus/timelines_plus.dart';
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

class HorizontalVehicleTypeListItem extends ConsumerWidget {
  const HorizontalVehicleTypeListItem({
    super.key,
    required this.vehicleType,
    required this.vendorType,
  });

  final VehicleType vehicleType;
  final VendorType vendorType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taxiState = ref.watch(taxiControllerProvider(vendorType));
    final taxiController = ref.read(
      taxiControllerProvider(vendorType).notifier,
    );
    final selected = taxiState.selectedVehicleType?.id == vehicleType.id;
    final currencySymbol =
        vehicleType.currency != null
            ? vehicleType.currency?.symbol
            : AppStrings.currentCurrencySymbol;

    return HStack([
          CustomImage(
            imageUrl: vehicleType.photo,
            width: 55,
            height: 40,
            boxFit: BoxFit.contain,
          ),
          VStack([
            vehicleType.name.text.bold.maxLines(1).ellipsis.make(),
            UiSpacer.vSpace(3),
            HStack([
              CurrencyHStack(
                [
                  "min".tr(),
                  " ",
                  "$currencySymbol",
                  vehicleType.minFare
                      .convertIf(vehicleType.currency == null)
                      .currencyValueFormat(),
                ],
                textSize: 12,
                textColor: Colors.grey.shade600,
              ),
              DotIndicator(size: 5, color: Colors.grey.shade600).px8(),
              CurrencyHStack(
                [
                  "base".tr(),
                  " ",
                  "$currencySymbol",
                  vehicleType.baseFare
                      .convertIf(vehicleType.currency == null)
                      .currencyValueFormat(),
                ],
                textSize: 12,
                textColor: Colors.grey.shade600,
              ),
            ]),
          ]).px8().expand(),
          VStack([
            CurrencyHStack([
              " $currencySymbol ".text.extraBold.make(),
              " ${vehicleType.total.convertIf(vehicleType.currency == null)} "
                  .currencyValueFormat()
                  .text
                  .extraBold
                  .make(),
            ]),
          ]),
        ], alignment: MainAxisAlignment.center).box.p12
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
