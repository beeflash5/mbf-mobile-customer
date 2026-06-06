import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/list/package_type.list_item.dart';
import 'package:fuodz/pages/parcel/widgets/form_step_controller.dart';
import 'package:fuodz/providers/new_parcel_providers.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class PackageTypeSelector extends StatelessWidget {
  const PackageTypeSelector({
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
        "Select Package Type".tr().text.xl.medium.make().py20(),
        CustomListView(
          isLoading: state.packageTypesBusy,
          dataSet: state.packageTypes,
          noScrollPhysics: true,
          itemBuilder: (context, index) {
            final packageType = state.packageTypes[index];
            return PackageTypeListItem(
              packageType: packageType,
              selected: state.selectedPackageType == packageType,
              onPressed: controller.changeSelectedPackageType,
            );
          },
          separatorBuilder: (context, index) =>
              UiSpacer.verticalSpace(space: 5),
        ).box.make().scrollVertical().expand(),
        FormStepController(
          showPrevious: false,
          showLoadingNext: state.vendorsBusy,
          onNextPressed: state.selectedPackageType != null
              ? () => controller.nextForm(1)
              : null,
        ),
      ],
    );
  }
}
