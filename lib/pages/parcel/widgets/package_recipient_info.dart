import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/models/delivery_address.dart';
import 'package:fuodz/pages/parcel/widgets/form_step_controller.dart';
import 'package:fuodz/pages/parcel/widgets/list_item/package_stop_recipient.view.dart';
import 'package:fuodz/providers/new_parcel_providers.dart';
import 'package:fuodz/utils/app_strings.dart';

class PackageRecipientInfo extends StatelessWidget {
  const PackageRecipientInfo({
    super.key,
    required this.state,
    required this.controller,
  });

  final NewParcelState state;
  final NewParcelController controller;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.recipientInfoFormKey,
      child: VStack([
        CustomListView(
          dataSet: !AppStrings.enableParcelMultipleStops
              ? [0, 1]
              : controller.recipientNamesTEC,
          itemBuilder: (context, index) {
            DeliveryAddress stop;
            if (index == 0) {
              stop = state.packageCheckout.pickupLocation!;
            } else if (!AppStrings.enableParcelMultipleStops) {
              stop = state.packageCheckout.dropoffLocation!;
            } else {
              stop = state
                  .packageCheckout.stopsLocation![index - 1].deliveryAddress!;
            }
            return PackageStopRecipientView(
              stop,
              controller.recipientNamesTEC[index],
              controller.recipientPhonesTEC[index],
              controller.recipientNotesTEC[index],
              isOpen: index == state.openedRecipientFormIndex,
              index: index + 1,
            );
          },
          padding: const EdgeInsets.only(top: Vx.dp16),
        ).expand(),
        FormStepController(
          onPreviousPressed: () => controller.nextForm(2),
          onNextPressed: () => controller.validateRecipientInfo(context),
        ),
      ]),
    );
  }
}
