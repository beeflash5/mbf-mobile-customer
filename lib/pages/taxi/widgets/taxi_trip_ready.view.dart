import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:measure_size/measure_size.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/button/call.button.dart';
import 'package:fuodz/component/button/custom_text_button.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/pages/order/widgets/taxi_order_trip_verification.view.dart';
import 'package:fuodz/pages/taxi/widgets/driver_info.view.dart';
import 'package:fuodz/pages/taxi/widgets/safety.view.dart';
import 'package:fuodz/providers/taxi_providers.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_ui_settings.dart';
import 'package:fuodz/utils/sizes.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';

class TaxiTripReadyView extends ConsumerWidget {
  const TaxiTripReadyView({super.key, required this.vendorType});

  final VendorType vendorType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taxiState = ref.watch(taxiControllerProvider(vendorType));
    final taxiController =
        ref.read(taxiControllerProvider(vendorType).notifier);
    final trip = taxiState.onGoingOrderTrip;
    if (trip == null) return const SizedBox.shrink();
    return SlidingUpPanel(
      backdropColor: Colors.transparent,
      minHeight: 300,
      maxHeight: context.percentHeight * 70,
      panelBuilder: (sc) {
        return MeasureSize(
          onChange: (size) {
            taxiController.updateGoogleMapPadding(height: 320);
          },
          child: VStack(
            [
              UiSpacer.swipeIndicator(),
              20.heightBox,
              TaxiDriverInfoView(
                trip.driver!,
                order: trip,
              ),
              HStack(
                [
                  if (AppUISettings.canDriverChat)
                    Icon(
                      Icons.message,
                      size: 24,
                      color: Utils.textColorByColor(AppColor.primaryColor),
                    )
                        .p8()
                        .box
                        .color(AppColor.primaryColor)
                        .roundedFull
                        .make()
                        .onInkTap(() => taxiController.openTripChat(context)),
                  if (AppUISettings.canCallDriver)
                    CallButton(
                      null,
                      phone: trip.driver!.phone,
                    ),
                ],
                crossAlignment: CrossAxisAlignment.center,
                alignment: MainAxisAlignment.center,
                spacing: 20,
              ).wFull(context).py16(),
              UiSpacer.divider().py12(),
              "Pickup Location".tr().text.sm.light.make(),
              "${trip.taxiOrder?.pickupAddress}".text.lg.medium.make(),
              UiSpacer.verticalSpace(),
              "Dropoff Location".tr().text.sm.light.make(),
              "${trip.taxiOrder?.dropoffAddress}".text.lg.medium.make(),
              UiSpacer.divider().py12(),
              TaxiOrderTripVerificationView(trip),
              SafetyView(),
              UiSpacer.divider().py12(),
              Visibility(
                visible: trip.canCancelTaxi,
                child: CustomTextButton(
                  title: "Cancel Booking".tr(),
                  titleColor: AppColor.getStausColor("failed"),
                  loading: taxiState.tripBusy,
                  onPressed: taxiController.cancelTrip,
                ).centered(),
              ),
            ],
          )
              .p20()
              .scrollVertical(controller: sc)
              .box
              .color(context.theme.colorScheme.surface)
              .topRounded(value: Sizes.radiusSmall)
              .shadow5xl
              .make(),
        );
      },
    );
  }
}
