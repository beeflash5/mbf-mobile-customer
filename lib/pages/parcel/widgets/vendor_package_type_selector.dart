import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/list/parcel_vendor.list_item.dart';
import 'package:fuodz/component/states/vendor.empty.dart';
import 'package:fuodz/pages/parcel/widgets/form_step_controller.dart';
import 'package:fuodz/providers/new_parcel_providers.dart';

class VendorPackageTypeSelector extends StatelessWidget {
  const VendorPackageTypeSelector({
    super.key,
    required this.state,
    required this.controller,
  });

  final NewParcelState state;
  final NewParcelController controller;

  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        "Select Courier Vendor".tr().text.xl.medium.make().py20(),
        CustomListView(
          isLoading: state.vendorsBusy,
          dataSet: state.vendors,
          emptyWidget: EmptyVendor(showDescription: false),
          noScrollPhysics: true,
          itemBuilder: (context, index) {
            final vendor = state.vendors[index];
            return ParcelVendorListItem(
              vendor,
              selected: state.selectedVendor == vendor,
              onPressed: controller.changeSelectedVendor,
              state: state,
              controller: controller,
            );
          },
        ).box.make().scrollVertical().expand(),
        FormStepController(
          onPreviousPressed: () => controller.nextForm(1),
          onNextPressed: state.selectedVendor != null
              ? () => controller.validateSelectedVendor(context)
              : null,
        ),
      ],
    );
  }
}
