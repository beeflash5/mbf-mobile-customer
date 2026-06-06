import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/custom_text_form_field.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/providers/taxi_providers.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class TaxiDiscountSection extends ConsumerWidget {
  const TaxiDiscountSection({
    super.key,
    required this.vendorType,
    this.fullView = false,
  });

  final VendorType vendorType;
  final bool fullView;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taxiState = ref.watch(taxiControllerProvider(vendorType));
    final taxiController =
        ref.read(taxiControllerProvider(vendorType).notifier);
    return VStack(
      [
        HStack(
          [
            "Add Coupon".tr().text.make().expand(),
            UiSpacer.hSpace(5),
            if (!fullView)
              Icon(
                Icons.add,
                color: AppColor.primaryColor,
                size: 20,
              )
            else
              UiSpacer.emptySpace(),
          ],
          crossAlignment: CrossAxisAlignment.center,
          alignment: MainAxisAlignment.center,
        ).p(!fullView ? 10 : 0),
        Visibility(
          visible: fullView,
          child: UiSpacer.verticalSpace(space: 10),
        ),
        Visibility(
          visible: fullView,
          child: HStack(
            [
              CustomTextFormField(
                hintText: "Coupon Code".tr(),
                textEditingController: taxiController.couponTEC,
                errorText: taxiState.couponError?.toString(),
                onChanged: taxiController.couponCodeChange,
              ).expand(flex: 2),
              UiSpacer.horizontalSpace(),
              Column(
                children: [
                  CustomButton(
                    title: "Apply".tr(),
                    isFixedHeight: true,
                    loading: taxiState.couponBusy,
                    onPressed: taxiState.canApplyCoupon
                        ? taxiController.applyCoupon
                        : null,
                  ).h(Vx.dp56),
                  taxiState.couponError != null
                      ? UiSpacer.verticalSpace(space: 12)
                      : UiSpacer.verticalSpace(space: 1),
                ],
              ).expand(),
            ],
          ),
        ),
      ],
      crossAlignment: CrossAxisAlignment.center,
      alignment: MainAxisAlignment.center,
    );
  }
}
