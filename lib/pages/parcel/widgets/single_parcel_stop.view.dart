import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import 'package:fuodz/pages/parcel/widgets/parcel_form_input.dart';
import 'package:fuodz/providers/new_parcel_providers.dart';
import 'package:fuodz/services/validator.service.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class SingleParcelDeliveryStopsView extends StatelessWidget {
  const SingleParcelDeliveryStopsView({
    super.key,
    required this.state,
    required this.controller,
  });

  final NewParcelState state;
  final NewParcelController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ParcelFormInput(
          iconData: Icons.directions_car,
          iconColor: Colors.green[700],
          labelText: "FROM".tr(),
          hintText: "Pickup Location".tr(),
          tec: controller.fromTEC,
          onInputTap: () => controller.handlePickupStop(context),
          formValidator:
              (value) => FormValidator.validateCustom(
                value,
                name: "Pickup Location".tr(),
              ),
        ),
        UiSpacer.formVerticalSpace(),
        ParcelFormInput(
          iconData: Icons.location_on,
          iconColor: Colors.red[700],
          labelText: "TO".tr(),
          hintText: "Dropoff Location".tr(),
          tec: controller.toTEC,
          onInputTap: () => controller.handleDropoffStop(context),
          formValidator:
              (value) => FormValidator.validateCustom(
                value,
                name: "Dropoff Location".tr(),
              ),
        ),
        UiSpacer.formVerticalSpace(),
      ],
    );
  }
}
