import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:measure_size/measure_size.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/button/custom_text_button.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/providers/taxi_providers.dart';
import 'package:fuodz/utils/app_colors.dart';

class OnGoingTaxiOrderDetails extends ConsumerWidget {
  const OnGoingTaxiOrderDetails({super.key, required this.vendorType});

  final VendorType vendorType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taxiState = ref.watch(taxiControllerProvider(vendorType));
    final taxiController = ref.read(
      taxiControllerProvider(vendorType).notifier,
    );
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: MeasureSize(
        onChange: (size) {
          taxiController.updateGoogleMapPadding(height: size.height);
        },
        child:
            VStack([
                  Visibility(
                    visible: taxiState.onGoingOrderTrip?.canCancelTaxi ?? false,
                    child:
                        CustomTextButton(
                          title: "Cancel Booking".tr(),
                          titleColor: AppColor.getStausColor("failed"),
                        ).centered(),
                  ),
                ])
                .p20()
                .scrollVertical()
                .box
                .color(context.theme.colorScheme.surface)
                .topRounded(value: 30)
                .shadow5xl
                .make(),
      ),
    );
  }
}
