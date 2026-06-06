import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/component/custom_image.view.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/pages/parcel/widgets/parcel_schedule.view.dart';
import 'package:fuodz/providers/new_parcel_providers.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class ParcelVendorListItem extends StatelessWidget {
  const ParcelVendorListItem(
    this.vendor, {
    super.key,
    this.selected = false,
    this.onPressed,
    this.state,
    this.controller,
  });

  final Vendor vendor;
  final bool selected;
  final void Function(Vendor)? onPressed;
  final NewParcelState? state;
  final NewParcelController? controller;

  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        HStack(
          [
            CustomImage(
              imageUrl: vendor.logo,
            ).wh(Vx.dp56, Vx.dp56).pOnly(
                  right: AppService.isDirectionRTL(context) ? Vx.dp0 : Vx.dp12,
                  left: AppService.isDirectionRTL(context) ? Vx.dp12 : Vx.dp0,
                ),
            VStack(
              [
                vendor.name.text.semiBold.make(),
                vendor.description.text.sm.make(),
              ],
            ).expand(),
          ],
          crossAlignment: CrossAxisAlignment.start,
        ),
        if (selected && state != null && controller != null)
          VStack(
            [
              if (state!.selectedVendor != null)
                ParcelScheduleView(state: state!, controller: controller!),
              if (state!.selectedVendor != null &&
                  !state!.selectedVendor!.allowScheduleOrder)
                VStack(
                  [
                    UiSpacer.divider().py4(),
                    "DATE & TIME".tr().text.semiBold.base.make(),
                    "Vendor does not allow order scheduling. So you order will be processed as soon as you place them"
                        .tr()
                        .text
                        .color(context.textTheme.bodyLarge!.color)
                        .sm
                        .make(),
                  ],
                ),
            ],
          ).py12()
        else
          CustomVisibilty(visible: false, child: const SizedBox.shrink()),
      ],
    )
        .p12()
        .onInkTap(() {
          if (onPressed != null) onPressed!(vendor);
        })
        .box
        .roundedSM
        .border(
          color: selected ? AppColor.primaryColor : Colors.grey.shade300,
          width: selected ? 2 : 1,
        )
        .make();
  }
}
