import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/currency_hstack.dart';
import 'package:fuodz/component/directional_chevron.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/pages/cart/widgets/amount_tile.dart';
import 'package:fuodz/providers/taxi_providers.dart';
import 'package:fuodz/services/app_currency_system.service.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/extensions/string.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';

class OrderTaxiButton extends ConsumerWidget {
  const OrderTaxiButton({super.key, required this.vendorType});

  final VendorType vendorType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taxiState = ref.watch(taxiControllerProvider(vendorType));
    final taxiController =
        ref.read(taxiControllerProvider(vendorType).notifier);
    final selectedVehicleType = taxiState.selectedVehicleType;
    final currencySymbol = selectedVehicleType?.currency != null
        ? selectedVehicleType?.currency?.symbol
        : AppStrings.currentCurrencySymbol;
    final textColor = Utils.textColorByTheme();

    return Visibility(
      visible: selectedVehicleType != null,
      child: VStack([
        5.heightBox,
        if (taxiState.possibleDriverETA != null)
          AmountTile(
            "Avg. Driver ETA".tr(),
            "~ ${taxiState.possibleDriverETA}" + "min(s)".tr(),
            amountStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ).px(12),
        if (selectedVehicleType != null && selectedVehicleType.hasSurge)
          AmountTile(
            "Surge".tr(),
            "x${selectedVehicleType.surgeRate}",
            amountStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.red,
            ),
          ).px(12),
        5.heightBox,
        CustomButton(
          loading: taxiState.isBusy,
          shapeRadius: 0,
          isFixedHeight: false,
          height: context.percentHeight * 7,
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: HStack(
              [
                "Book".tr().text.medium.color(textColor).xl.make().expand(),
                UiSpacer.hSpace(10),
                CurrencyHStack([
                  "$currencySymbol ".text.bold.color(textColor).xl2.make(),
                  Visibility(
                    visible: taxiState.subTotal > taxiState.total,
                    child: HStack([
                      taxiState.subTotal
                          .convertIf(
                            selectedVehicleType?.currency == null,
                          )
                          .currencyValueFormat()
                          .text
                          .color(textColor)
                          .medium
                          .lineThrough
                          .make(),
                      taxiState.total
                          .convertIf(
                            selectedVehicleType?.currency == null,
                          )
                          .currencyValueFormat()
                          .text
                          .color(textColor)
                          .semiBold
                          .xl
                          .make(),
                    ]),
                  ),
                  Visibility(
                    visible: !(taxiState.subTotal > taxiState.total),
                    child: taxiState.total
                        .convertIf(selectedVehicleType?.currency == null)
                        .currencyValueFormat()
                        .text
                        .color(textColor)
                        .bold
                        .xl
                        .make(),
                  ),
                ]),
                const DirectionalChevron()
                    .centered()
                    .box
                    .roundedFull
                    .color(textColor)
                    .make(),
              ],
              spacing: 10,
              crossAlignment: CrossAxisAlignment.center,
            ),
          ),
          onPressed: selectedVehicleType != null
              ? () => taxiController.processNewOrder(context)
              : null,
        ).wFull(context),
      ], spacing: 5),
    );
  }
}
