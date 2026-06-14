import 'package:flutter/material.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_routes.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/sizes.dart';
import 'package:fuodz/models/search.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class ViewAllVendorsView extends StatelessWidget {
  const ViewAllVendorsView({Key? key, required this.vendorType})
    : super(key: key);
  final VendorType vendorType;

  @override
  Widget build(BuildContext context) {
    return VStack([
      CustomVisibilty(
        visible: !AppStrings.enableSingleVendor,
        child:
            HStack([
                  UiSpacer.horizontalSpace(),
                  "View all vendors"
                      .tr()
                      .text
                      .center
                      .color(Utils.textColorByPrimaryColor())
                      .size(Sizes.fontSizeDefault)
                      .make()
                      .expand(),
                  Icon(
                    Icons.chevron_right,
                    color: Utils.textColorByPrimaryColor(),
                  ),
                ])
                .p8()
                .onInkTap(() {
                  //open search with vendor type
                  context.pushRoute(
                    AppRoutes.search,
                    extra: Search(
                      vendorType: vendorType,
                      byLocation: false,
                      showProductsTag: false,
                      showVendorsTag: !vendorType.isService,
                      showServicesTag: false,
                      showProvidesTag: vendorType.isService,
                      type: "vendor",
                      // showType: vendorType.isService ? 5 : 4,
                    ),
                  );
                })
                .box
                .withRounded(value: Sizes.radiusSmall)
                .color(AppColor.primaryColor)
                .make()
                .p12(),
      ),
      CustomVisibilty(
        visible: AppStrings.enableSingleVendor,
        child:
            HStack([
                  UiSpacer.horizontalSpace(),
                  (!vendorType.isService
                          ? "View all products".tr()
                          : "View all services".tr())
                      .text
                      .center
                      .color(Utils.textColorByPrimaryColor())
                      .size(Sizes.fontSizeDefault)
                      .make()
                      .expand(),
                  Icon(
                    Utils.isArabic ? Icons.chevron_left : Icons.chevron_right,
                    color: Utils.textColorByPrimaryColor(),
                  ),
                ])
                .p8()
                .onInkTap(() {
                  //open search with vendor type
                  context.pushRoute(
                    AppRoutes.search,
                    extra: Search(
                      vendorType: vendorType,
                      byLocation: false,
                      showProductsTag: !vendorType.isService,
                      showVendorsTag: !vendorType.isService,
                      showProvidesTag: vendorType.isService,
                      showServicesTag: vendorType.isService,
                      // showType: vendorType.isService ? 3 : 2,
                    ),
                  );
                })
                .box
                .withRounded(value: Sizes.radiusSmall)
                .color(AppColor.primaryColor)
                .make()
                .p12(),
      ),
    ]);
  }
}
