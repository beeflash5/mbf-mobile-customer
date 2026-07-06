import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/custom_text_form_field.dart';
import 'package:fuodz/providers/new_parcel_providers.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class ParcelDeliveryDiscountSection extends StatefulWidget {
  const ParcelDeliveryDiscountSection({
    super.key,
    required this.state,
    required this.controller,
  });

  final NewParcelState state;
  final NewParcelController controller;

  @override
  State<ParcelDeliveryDiscountSection> createState() =>
      _ParcelDeliveryDiscountSectionState();
}

class _ParcelDeliveryDiscountSectionState
    extends State<ParcelDeliveryDiscountSection> {
  bool showClearButton = false;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final controller = widget.controller;
    return VStack([
      "Add Coupon".tr().text.semiBold.xl.make(),
      UiSpacer.verticalSpace(space: 10),
      HStack([
        CustomTextFormField(
          hintText: "Coupon Code".tr(),
          textEditingController: controller.couponTEC,
          errorText: state.couponError?.toString() ?? "",
          onChanged: controller.couponCodeChange,
        ).expand(),
        Column(
          children: [
            Visibility(
              visible: !showClearButton,
              child: CustomButton(
                title: "Apply".tr(),
                shapeRadius: 0,
                isFixedHeight: true,
                loading: state.couponBusy,
                onPressed:
                    state.canApplyCoupon
                        ? () async {
                            if (controller.couponTEC.text.isEmpty) return;
                            final success = await controller.applyCoupon();
                            if (success) {
                              setState(() => showClearButton = true);
                              AlertService.success(
                                title: "Coupon Applied".tr(),
                                text: "Coupon applied successfully".tr(),
                              );
                            }
                          }
                        : null,
              ).h(48),
            ),
            Visibility(
              visible: showClearButton,
              child: CustomButton(
                icon: Icons.clear,
                padding: const EdgeInsets.all(0),
                child: const Icon(Icons.clear, color: Colors.white, size: 20),
                color: Colors.red,
                onPressed: () {
                  controller.clearCoupon();
                  setState(() => showClearButton = false);
                },
              ).h(Vx.dp32).w(32).pOnly(left: 8),
            ),
          ],
        ),
      ], crossAlignment: CrossAxisAlignment.start),
    ]);
  }
}
