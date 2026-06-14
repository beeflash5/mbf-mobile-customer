import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/list/package_type.list_item.dart';
import 'package:fuodz/component/list/parcel_vendor.list_item.dart';
import 'package:fuodz/pages/parcel/widgets/form_step_controller.dart';
import 'package:fuodz/providers/new_parcel_providers.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class PackageDeliverySummary extends StatelessWidget {
  const PackageDeliverySummary({
    super.key,
    required this.state,
    required this.controller,
  });

  final NewParcelState state;
  final NewParcelController controller;

  @override
  Widget build(BuildContext context) {
    return VStack([
      VStack([
        "Summary".tr().text.xl2.semiBold.make().py20(),
        "Package Type".tr().text.xl.medium.make().py8(),
        PackageTypeListItem(packageType: state.selectedPackageType!),
        UiSpacer.formVerticalSpace(),
        "Courier Vendor".tr().text.xl.medium.make().py8(),
        ParcelVendorListItem(
          state.selectedVendor!,
          state: state,
          controller: controller,
        ),
        UiSpacer.formVerticalSpace(),
        "Delivery Details".tr().text.xl.medium.make().py8(),
        VStack([
              "FROM".tr().text.semiBold.make(),
              "${state.pickupLocation?.address}".text.make().pOnly(
                bottom: Vx.dp4,
              ),
              UiSpacer.verticalSpace(space: 10),
              Visibility(
                visible: !AppStrings.enableParcelMultipleStops,
                child: VStack([
                  "TO".tr().text.semiBold.make(),
                  "${state.dropoffLocation?.address}".text.make(),
                  UiSpacer.verticalSpace(space: 10),
                ]),
              ),
              Visibility(
                visible: AppStrings.enableParcelMultipleStops,
                child:
                    (state.packageCheckout.stopsLocation != null)
                        ? VStack(
                          state.packageCheckout.stopsLocation!.mapIndexed((
                            stop,
                            index,
                          ) {
                            return VStack([
                              ("Stop".tr() + " ${index + 1}").text.semiBold
                                  .make(),
                              "${stop.deliveryAddress?.address}".text.make(),
                              UiSpacer.verticalSpace(space: 10),
                            ]);
                          }).toList(),
                        )
                        : UiSpacer.emptySpace(),
              ),
              UiSpacer.verticalSpace(space: 10),
              HStack([
                VStack([
                  "DATE".tr().text.semiBold.make(),
                  "${state.pickupDate ?? "ASAP".tr()}".text.make(),
                ]).expand(),
                UiSpacer.horizontalSpace(),
                VStack([
                  "TIME".tr().text.semiBold.make(),
                  "${state.pickupTime ?? "ASAP".tr()}".text.make(),
                ]).expand(),
              ]),
            ])
            .p12()
            .box
            .roundedSM
            .border(color: Colors.grey.shade300, width: 2)
            .make(),
        UiSpacer.formVerticalSpace(),
        "Recipient Info".tr().text.xl.medium.make().py8(),
        CustomListView(
          noScrollPhysics: true,
          dataSet: controller.recipientNamesTEC,
          itemBuilder: (context, index) {
            final recipientNameTEC = controller.recipientNamesTEC[index];
            final recipientPhoneTEC = controller.recipientPhonesTEC[index];
            final noteTEC = controller.recipientNotesTEC[index];
            return VStack([
                  HStack([
                    VStack([
                      "Name".tr().text.semiBold.make(),
                      recipientNameTEC.text.text.make(),
                    ]).expand(),
                    UiSpacer.horizontalSpace(),
                    VStack([
                      "phone".tr().allWordsCapitilize().text.semiBold.make(),
                      recipientPhoneTEC.text.text.make(),
                    ]).expand(),
                  ]),
                  UiSpacer.verticalSpace(space: 5),
                  VStack([
                    "note".tr().allWordsCapitilize().text.semiBold.make(),
                    noteTEC.text.text.make(),
                  ]),
                ])
                .p12()
                .box
                .roundedSM
                .border(color: Colors.grey.shade300, width: 2)
                .make()
                .wFull(context);
          },
          padding: const EdgeInsets.only(top: Vx.dp16),
        ),
        UiSpacer.formVerticalSpace(),
        CustomVisibilty(
          visible: state.requireParcelInfo,
          child: VStack([
            "Package Parameters".tr().text.xl.medium.make().py8(),
            VStack([
                  HStack([
                    VStack([
                      "Weight".tr().text.semiBold.make(),
                      "${controller.packageWeightTEC.text}kg".text.make(),
                    ]).expand(),
                    VStack([
                      "Length".tr().text.semiBold.make(),
                      "${controller.packageLengthTEC.text}cm".text.make(),
                    ]).expand(),
                  ]),
                  UiSpacer.verticalSpace(space: 10),
                  HStack([
                    VStack([
                      "Width".tr().text.semiBold.make(),
                      "${controller.packageWidthTEC.text}cm".text.make(),
                    ]).expand(),
                    VStack([
                      "Height".tr().text.semiBold.make(),
                      "${controller.packageHeightTEC.text}cm".text.make(),
                    ]).expand(),
                  ]),
                ])
                .p12()
                .box
                .roundedSM
                .border(color: Colors.grey.shade300, width: 2)
                .make()
                .wFull(context),
          ]),
        ),
        UiSpacer.formVerticalSpace(),
      ]).scrollVertical().expand(),
      FormStepController(
        onPreviousPressed:
            () => controller.nextForm(state.requireParcelInfo ? 4 : 3),
        onNextPressed: controller.prepareOrderSummary,
      ),
    ]);
  }
}
