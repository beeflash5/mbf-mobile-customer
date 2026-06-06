import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/vendor_type_categories.view.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/utils/app_strings.dart';

class GroceryCategories extends StatelessWidget {
  const GroceryCategories(this.vendorType, {super.key});

  final VendorType vendorType;

  @override
  Widget build(BuildContext context) {
    return VStack([
      VendorTypeCategories(
        vendorType,
        showTitle: true,
        title: "What are you getting today?".tr(),
        childAspectRatio: 1.4,
        crossAxisCount: AppStrings.categoryPerRow,
        headerPadding: const EdgeInsets.symmetric(horizontal: 12),
        listPadding: const EdgeInsets.symmetric(horizontal: 10),
      ),
    ]);
  }
}
