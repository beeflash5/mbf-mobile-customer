import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/pages/parcel/widgets/form_step_controller.dart';
import 'package:fuodz/pages/parcel/widgets/parcel_stops.view.dart';
import 'package:fuodz/pages/parcel/widgets/single_parcel_stop.view.dart';
import 'package:fuodz/providers/new_parcel_providers.dart';
import 'package:fuodz/utils/app_strings.dart';

class PackageDeliveryInfo extends StatelessWidget {
  const PackageDeliveryInfo({
    super.key,
    required this.state,
    required this.controller,
  });

  final NewParcelState state;
  final NewParcelController controller;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.deliveryInfoFormKey,
      child: VStack(
        [
          VStack(
            [
              "Delivery Info".tr().text.xl.medium.make().py20(),
              Visibility(
                visible: !AppStrings.enableParcelMultipleStops,
                child: SingleParcelDeliveryStopsView(
                  state: state,
                  controller: controller,
                ),
              ),
              Visibility(
                visible: AppStrings.enableParcelMultipleStops,
                child: ParcelDeliveryStopsView(
                  state: state,
                  controller: controller,
                ),
              ),
            ],
          ).scrollVertical().expand(),
          FormStepController(
            onPreviousPressed: () => controller.nextForm(0),
            onNextPressed: controller.validateDeliveryInfo,
          ),
        ],
      ),
    );
  }
}
