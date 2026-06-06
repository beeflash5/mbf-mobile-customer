import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:measure_size/measure_size.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/busy_indicator.dart';
import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/providers/taxi_providers.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';

class UnSupportedTaxiLocationView extends ConsumerWidget {
  const UnSupportedTaxiLocationView({super.key, required this.vendorType});

  final VendorType vendorType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taxiState = ref.watch(taxiControllerProvider(vendorType));
    final taxiController =
        ref.read(taxiControllerProvider(vendorType).notifier);
    return Visibility(
      visible: taxiState.currentOrderStep == 0,
      child: Positioned(
        bottom: Vx.dp20,
        left: Vx.dp20,
        right: Vx.dp20,
        child: MeasureSize(
          onChange: (size) {
            taxiController.updateGoogleMapPadding(
              height: size.height + Vx.dp20 + Vx.dp20,
            );
          },
          child: taxiState.isBusy
              ? const BusyIndicator().centered()
              : VStack(
                  [
                    "Not available".tr().text.semiBold.xl.make(),
                    "Taxi booking is currently not available in the selected location. Please another location"
                        .tr()
                        .text
                        .sm
                        .light
                        .make()
                        .py4(),
                    UiSpacer.vSpace(10),
                    SafeArea(
                      top: false,
                      child: CustomButton(
                        child: "Try another location"
                            .tr()
                            .text
                            .color(Utils.textColorByPrimaryColor())
                            .makeCentered(),
                        onPressed: () =>
                            taxiController.closeOrderSummary(clear: true),
                      ).wFull(context),
                    ),
                  ],
                )
                  .p20()
                  .box
                  .color(context.theme.colorScheme.surface)
                  .roundedSM
                  .outerShadow2Xl
                  .make(),
        ),
      ),
    );
  }
}
