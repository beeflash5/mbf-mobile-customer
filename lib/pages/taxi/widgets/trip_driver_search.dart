import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:measure_size/measure_size.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/busy_indicator.dart';
import 'package:fuodz/component/button/custom_text_button.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/providers/taxi_providers.dart';
import 'package:fuodz/utils/app_colors.dart';

class TripDriverSearch extends ConsumerWidget {
  const TripDriverSearch({super.key, required this.vendorType});

  final VendorType vendorType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taxiState = ref.watch(taxiControllerProvider(vendorType));
    final taxiController = ref.read(
      taxiControllerProvider(vendorType).notifier,
    );
    return Positioned(
      bottom: Vx.dp20,
      left: Vx.dp20,
      right: Vx.dp20,
      child: MeasureSize(
        onChange: (size) {
          taxiController.updateGoogleMapPadding(height: size.height);
        },
        child:
            VStack([
                  "Searching for a driver. Please wait..."
                      .tr()
                      .text
                      .makeCentered(),
                  const BusyIndicator().centered().py12(),
                  Visibility(
                    visible: taxiState.onGoingOrderTrip?.canCancelTaxi ?? false,
                    child:
                        CustomTextButton(
                          title: "Cancel Booking".tr(),
                          titleColor: AppColor.getStausColor("failed"),
                          loading: taxiState.tripBusy,
                          onPressed: taxiController.cancelTrip,
                        ).centered(),
                  ),
                ])
                .p20()
                .box
                .color(context.theme.colorScheme.surface)
                .roundedSM
                .outerShadow2Xl
                .make(),
      ),
    );
  }
}
