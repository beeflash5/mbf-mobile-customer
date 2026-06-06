import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/bottom_sheet/cart.bottomsheet.dart';
import 'package:fuodz/component/button/custom_rounded_leading.dart';
import 'package:fuodz/component/button/share.btn.dart';
import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/component/cart_page_action.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/pages/vendor_details/service_vendor_details.page.dart';
import 'package:fuodz/pages/vendor_details/widgets/vendor_with_subcategory.view.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class VendorPlainDetailsView extends StatelessWidget {
  const VendorPlainDetailsView(this.vendor, {super.key});

  final Vendor vendor;

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      showCart: true,
      elevation: 0,
      extendBodyBehindAppBar: true,
      appBarColor: Colors.transparent,
      backgroundColor: context.theme.colorScheme.surface,
      leading: CustomRoundedLeading(),
      actions: [
        SizedBox(
          width: 50,
          height: 50,
          child: FittedBox(child: ShareButton(vendor: vendor)),
        ),
        UiSpacer.hSpace(10),
        PageCartAction(),
      ],
      body: VStack([
        CustomVisibilty(
          visible: vendor.hasSubcategories && !vendor.isServiceType,
          child: VendorDetailsWithSubcategoryPage(vendor: vendor),
        ),
        CustomVisibilty(
          visible: vendor.isServiceType,
          child: ServiceVendorDetailsPage(vendor: vendor),
        ),
      ]),
      bottomSheet: CartViewBottomSheet(),
    );
  }
}
