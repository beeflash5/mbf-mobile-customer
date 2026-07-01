import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/busy_indicator.dart';
import 'package:fuodz/component/custom_grid_view.dart';
import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/custom_text_form_field.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class ScheduleOrderView extends StatelessWidget {
  const ScheduleOrderView({
    super.key,
    required this.vendor,
    required this.isScheduled,
    required this.onToggleScheduled,
    required this.selectedDate,
    required this.selectedTime,
    required this.availableTimeSlots,
    required this.dateFull,
    required this.timeFull,
    required this.onSelectDate,
    required this.onSelectTime,
    required this.loadingTime,
    this.loadingTables = false,
    this.tables = const [],
    this.tableSelected,
    this.guestCountController,
    this.onSelectTable,
    // Explicit override – caller knows better than vendor.isFoodOrBeverage
    this.isFoodOverride,
  });

  final Vendor vendor;
  final bool isScheduled;
  final ValueChanged<bool?> onToggleScheduled;
  final String? selectedDate;
  final String? selectedTime;
  final List<String> availableTimeSlots;
  final List<String> dateFull;
  final List<String> timeFull;
  final void Function(String, int) onSelectDate;
  final ValueChanged<String> onSelectTime;
  final bool loadingTime;
  final bool loadingTables;
  final List<Map<String, dynamic>> tables;
  final String? tableSelected;
  final TextEditingController? guestCountController;
  final ValueChanged<String>? onSelectTable;
  final bool? isFoodOverride;

  @override
  Widget build(BuildContext context) {
    final bool isTattoo =
        vendor.vendorType.slug.toLowerCase() == "tattoo" ||
        vendor.vendorType.id == 13;
    final bool isServiceBooking =
        [
          "service",
          "tour",
          "booking",
          "bookings",
          "accommodation",
        ].contains(vendor.vendorType.slug.toLowerCase()) &&
        !isTattoo;
    // Use explicit override from caller if provided, otherwise compute locally
    final bool isFood =
        isFoodOverride ??
        (vendor.isFoodOrBeverage &&
        !isTattoo &&
        !isServiceBooking);

    return Visibility(
      visible:
          (isFoodOverride == true) ||
          vendor.allowScheduleOrder ||
          isServiceBooking ||
          isTattoo ||
          vendor.isFoodOrBeverage,
      child: VStack([
            VStack([
              isFood
                  ? "Reservation".tr().text.lg.semiBold.make()
                  : "Schedule Order".tr().text.lg.semiBold.make(),
              UiSpacer.verticalSpace(space: 10),
              if (!isFood && !isTattoo)
                HStack([
                  Checkbox(
                    value: isScheduled,
                    onChanged: onToggleScheduled,
                    activeColor: AppColor.primaryColor,
                  ).pOnly(right: 10),
                  "I want to schedule this order for a future date/time."
                      .tr()
                      .text
                      .color(const Color(0xff808080))
                      .make()
                      .expand(),
                ]).onInkTap(() => onToggleScheduled(!isScheduled)),
            ]).wFull(context),
            Visibility(
              visible: isScheduled,
              child: VStack([
                UiSpacer.verticalSpace(),
                "Date".tr().text.lg.make(),
                UiSpacer.verticalSpace(space: 10),
                (isTattoo || vendor.deliverySlots.isNotEmpty)
                    ? DropdownButtonFormField<String>(
                      value:
                          (selectedDate != null &&
                                  vendor.deliverySlots.any(
                                    (slot) =>
                                        DateFormat(
                                          'yyyy-MM-dd',
                                          'en',
                                        ).format(slot.date) ==
                                        selectedDate,
                                  ))
                              ? selectedDate
                              : null,
                      items:
                          vendor.deliverySlots
                              .where(
                                (slot) =>
                                    !dateFull.contains(
                                      DateFormat(
                                        'yyyy-MM-dd',
                                        'en',
                                      ).format(slot.date),
                                    ),
                              )
                              .map((slot) {
                                final formattedDate = DateFormat(
                                  'yyyy-MM-dd',
                                  'en',
                                ).format(slot.date);
                                return DropdownMenuItem(
                                  value: formattedDate,
                                  child: Text(formattedDate),
                                );
                              })
                              .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          final index = vendor.deliverySlots.indexWhere(
                            (slot) =>
                                DateFormat(
                                  'yyyy-MM-dd',
                                  'en',
                                ).format(slot.date) ==
                                val,
                          );
                          onSelectDate(val, index >= 0 ? index : 0);
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "Select Date".tr(),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColor.primaryColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    )
                    : CustomTextFormField(
                      isReadOnly: true,
                      hintText: selectedDate ?? "mm/dd/yyyy",
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          onSelectDate(
                            DateFormat('yyyy-MM-dd', 'en').format(picked),
                            0,
                          );
                        }
                      },
                    ),
                UiSpacer.verticalSpace(space: 10),
                "Time".tr().text.lg.make(),
                UiSpacer.verticalSpace(space: 10),
                (isTattoo || availableTimeSlots.isNotEmpty)
                    ? DropdownButtonFormField<String>(
                      value:
                          availableTimeSlots.contains(selectedTime)
                              ? selectedTime
                              : null,
                      items:
                          availableTimeSlots
                              .where((time) => !timeFull.contains(time))
                              .map(
                                (time) => DropdownMenuItem(
                                  value: time,
                                  child: Text(
                                    Jiffy.parse(
                                      '2024-01-01 $time',
                                    ).format(pattern: 'hh:mm a'),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (val) {
                        if (val != null) onSelectTime(val);
                      },
                      decoration: InputDecoration(
                        hintText: "Select Time".tr(),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColor.primaryColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    )
                    : CustomTextFormField(
                      isReadOnly: true,
                      hintText:
                          (selectedTime != null &&
                                  selectedTime!.trim().isNotEmpty)
                              ? Jiffy.parse(
                                '2024-01-01 ${selectedTime!.trim()}',
                              ).format(pattern: 'hh:mm a')
                              : "--:-- --",
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          final now = DateTime.now();
                          final dt = DateTime(
                            now.year,
                            now.month,
                            now.day,
                            picked.hour,
                            picked.minute,
                          );
                          onSelectTime(DateFormat('HH:mm:ss', 'en').format(dt));
                        }
                      },
                    ),

                if ((isFood || vendor.can_dinein == true) &&
                    !isTattoo &&
                    guestCountController != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UiSpacer.verticalSpace(space: 20),
                      "Number of Guests".tr().text.lg.make(),
                      "Enter the number of people for your reservation"
                          .tr()
                          .text
                          .sm
                          .make(),
                      UiSpacer.verticalSpace(space: 10),
                      CustomTextFormField(
                        keyboardType: TextInputType.number,
                        labelText: "Number of Guests".tr(),
                        textEditingController: guestCountController,
                      ),
                      UiSpacer.verticalSpace(space: 20),
                      if (vendor.can_dinein == true &&
                          (vendor.qty_tables ?? 0) > 0 &&
                          onSelectTable != null)
                        Column(
                          children: [
                            "Dine-in".tr().text.lg.make(),
                            "Select your preferred table for reservation"
                                .tr()
                                .text
                                .sm
                                .make(),
                            UiSpacer.verticalSpace(space: 10),
                            loadingTables
                                ? Center(
                                  child: BusyIndicator(
                                    color: AppColor.primaryColor,
                                  ),
                                )
                                : CustomGridView(
                                  noScrollPhysics: true,
                                  dataSet: tables,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 0.9,
                                  crossAxisCount: 3,
                                  itemBuilder: (context, index) {
                                    final table = tables[index];
                                    final selected =
                                        table['name'] == tableSelected;
                                    return InkWell(
                                      onTap:
                                          table['available'] == false
                                              ? null
                                              : () =>
                                                  onSelectTable!(table['name']),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: AppColor.primaryColor,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          color:
                                              selected
                                                  ? AppColor.primaryColor
                                                  : Colors.transparent,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            "Table".text.semiBold
                                                .color(
                                                  selected
                                                      ? Colors.white
                                                      : null,
                                                )
                                                .make(),
                                            "${table['name']}".text.bold
                                                .color(
                                                  selected
                                                      ? Colors.white
                                                      : null,
                                                )
                                                .make(),
                                            table['available'] == true
                                                ? "Available".text.sm
                                                    .color(
                                                      selected
                                                          ? Colors.white
                                                          : null,
                                                    )
                                                    .make()
                                                : "Not Available".text.sm
                                                    .color(
                                                      selected
                                                          ? Colors.white
                                                          : Colors.red,
                                                    )
                                                    .make(),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                          ],
                        ),
                    ],
                  ),
              ]),
            ),
          ])
          .p12()
          .box
          .roundedSM
          .border(color: const Color(0xffD9D9D9))
          .make()
          .pOnly(bottom: Vx.dp20),
    );
  }
}
