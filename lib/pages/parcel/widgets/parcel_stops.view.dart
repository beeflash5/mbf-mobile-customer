import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/pages/parcel/widgets/parcel_form_input.dart';
import 'package:fuodz/providers/new_parcel_providers.dart';
import 'package:fuodz/services/validator.service.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class ParcelDeliveryStopsView extends StatelessWidget {
  const ParcelDeliveryStopsView({
    super.key,
    required this.state,
    required this.controller,
  });

  final NewParcelState state;
  final NewParcelController controller;

  @override
  Widget build(BuildContext context) {
    return VStack([
          ParcelFormInput(
            centered: true,
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
          ..._getStopsInputs(context),
          CustomButton(
            title: "Add Stop".tr(),
            onPressed:
                !(AppStrings.maxParcelStops > (controller.toTECs.length - 1))
                    ? null
                    : controller.addNewStop,
          ).py12(),
        ])
        .p12()
        .box
        .roundedSM
        .border(color: Colors.grey.shade300)
        .make()
        .pOnly(bottom: Vx.dp20);
  }

  List<Widget> _getStopsInputs(BuildContext context) {
    final stopsInput = <Widget>[];
    for (int index = 0; index < controller.toTECs.length; index++) {
      final tec = controller.toTECs[index];
      final lastStop = index == (controller.toTECs.length - 1);
      final stopInput = ParcelFormInput(
        centered: true,
        icon: Icon(
          lastStop ? Icons.location_on : Icons.near_me,
          size: 20,
          color:
              lastStop ? Colors.red[700] : context.textTheme.bodyLarge!.color,
        ),
        hintText: "Where to ...".tr(),
        tec: tec,
        onInputTap: () => controller.handleOtherStop(context, index),
        formValidator:
            (value) =>
                FormValidator.validateCustom(value, name: "Stop Location".tr()),
        suffix:
            controller.toTECs.length <= 1
                ? null
                : Icon(
                  Icons.close,
                  color: context.textTheme.bodyLarge!.color,
                  size: 18,
                ).onInkTap(() => controller.removeStop(index)).centered().px4(),
      ).pOnly(bottom: Vx.dp10);
      stopsInput.add(stopInput);
    }
    return stopsInput;
  }
}
