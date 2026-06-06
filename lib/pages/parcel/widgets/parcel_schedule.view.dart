import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/custom_grid_view.dart';
import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/providers/new_parcel_providers.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class ParcelScheduleView extends StatelessWidget {
  const ParcelScheduleView({
    super.key,
    required this.state,
    required this.controller,
  });

  final NewParcelState state;
  final NewParcelController controller;

  @override
  Widget build(BuildContext context) {
    final vendor = state.selectedVendor;
    return Visibility(
      visible: vendor != null && vendor.allowScheduleOrder,
      child: VStack([
        HStack([
          Checkbox(
            value: state.isScheduled,
            onChanged: controller.toggleScheduledOrder,
          ),
          VStack([
            "Schedule Order".tr().text.base.semiBold.make(),
            "If you want your order to be delivered/prepared at scheduled date/time"
                .tr()
                .text
                .sm
                .make(),
          ]).expand(),
        ], crossAlignment: CrossAxisAlignment.start)
            .wFull(context)
            .onInkTap(() => controller.toggleScheduledOrder(!state.isScheduled)),
        Visibility(
          visible: state.isScheduled && vendor != null,
          child: VStack([
            UiSpacer.verticalSpace(),
            "Date slot".tr().text.lg.make(),
            CustomListView(
              scrollDirection: Axis.horizontal,
              dataSet: vendor?.deliverySlots ?? [],
              itemBuilder: (context, index) {
                final dateDeliverySlot = vendor!.deliverySlots[index];
                final formattedDeliverySlot = DateFormat(
                  "yyyy-MM-dd",
                  "en",
                ).format(dateDeliverySlot.date);
                final selected = formattedDeliverySlot ==
                    state.packageCheckout.deliverySlotDate;
                return Jiffy.parseFromDateTime(dateDeliverySlot.date)
                    .format(pattern: "EEEE dd MMM yyyy")
                    .text
                    .color(selected ? Colors.white : null)
                    .makeCentered()
                    .px8()
                    .py4()
                    .box
                    .roundedSM
                    .border(color: AppColor.primaryColor)
                    .color(selected
                        ? AppColor.primaryColor
                        : Colors.transparent)
                    .make()
                    .onInkTap(() => controller.changeSelectedDeliveryDate(
                          formattedDeliverySlot,
                          index,
                        ));
              },
            ).h(Vx.dp32).py8(),
            UiSpacer.verticalSpace(space: 10),
            "Time slot".tr().text.lg.make(),
            UiSpacer.verticalSpace(space: 10),
            CustomGridView(
              noScrollPhysics: true,
              dataSet: state.availableTimeSlots,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3,
              crossAxisCount: 3,
              itemBuilder: (context, index) {
                final today = DateFormat("yyyy-MM-dd", "en").format(
                  DateTime.now(),
                );
                final availableTimeSlot = state.availableTimeSlots[index];
                final formattedTime = DateFormat("HH:mm:ss", "en").format(
                  DateTime.parse("$today $availableTimeSlot"),
                );
                final selected = formattedTime ==
                    state.packageCheckout.deliverySlotTime;
                return Jiffy.parse("$today $availableTimeSlot")
                    .format(pattern: "hh:mm a")
                    .text
                    .color(selected ? Colors.white : null)
                    .makeCentered()
                    .box
                    .roundedSM
                    .border(color: AppColor.primaryColor)
                    .color(selected
                        ? AppColor.primaryColor
                        : Colors.transparent)
                    .make()
                    .onInkTap(() =>
                        controller.changeSelectedDeliveryTime(formattedTime));
              },
            ),
          ]),
        ),
      ])
          .p12()
          .box
          .roundedSM
          .border(color: Colors.grey.shade300)
          .make()
          .pOnly(),
    );
  }
}
