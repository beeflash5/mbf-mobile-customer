import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/pages/pharmacy/pharmacy_upload_prescription.page.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';

class UploadPrescriptionFab extends StatelessWidget {
  const UploadPrescriptionFab(this.vendor, {super.key});

  final Vendor vendor;

  @override
  Widget build(BuildContext context) {
    if (!vendor.isPharmacyType || !AppStrings.enableUploadPrescription) {
      return UiSpacer.emptySpace();
    }
    return FloatingActionButton.extended(
      onPressed: () => context.pushWidget(PharmacyUploadPrescription(vendor)),
      backgroundColor: AppColor.primaryColor,
      label: "Upload Prescription"
          .tr()
          .text
          .color(Utils.textColorByPrimaryColor())
          .make(),
      icon: Icon(
        Icons.medication,
        color: Utils.textColorByPrimaryColor(),
        size: 22,
      ),
      extendedIconLabelSpacing: 20,
    );
  }
}
