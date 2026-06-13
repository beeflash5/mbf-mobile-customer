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

  @override
  Widget build(BuildContext context) {
    final bool isServiceBooking = ["service", "tour", "booking", "bookings", "accommodation"]
        .contains(vendor.vendorType.slug.toLowerCase());
    final bool isTattoo = vendor.vendorType.slug.toLowerCase() == "tattoo";
    return Visibility(
      visible: vendor.allowScheduleOrder || isServiceBooking || isTattoo || vendor.isFoodOrBeverage,
      child: VStack([
        if (!isServiceBooking)
          VStack([
            vendor.isFoodOrBeverage
                ? "Reservation".tr().text.lg.semiBold.make()
                : "Schedule Order".tr().text.lg.semiBold.make(),
            UiSpacer.verticalSpace(space: 10),
            HStack([
              Checkbox(
                value: isScheduled,
                onChanged: onToggleScheduled,
                activeColor: AppColor.primaryColor,
              ).pOnly(right: 10),
              (vendor.isFoodOrBeverage
                      ? "I want to make a reservation for a future date/time."
                      : "I want to schedule this order for a future date/time.")
                  .tr()
                  .text
                  .color(const Color(0xff808080))
                  .make()
                  .expand(),
            ]).onInkTap(() => onToggleScheduled(!isScheduled)),
          ]).wFull(context),
        Visibility(
          visible: isScheduled || isServiceBooking,
          child: VStack([
            UiSpacer.verticalSpace(),
            "Date".tr().text.lg.make(),
            UiSpacer.verticalSpace(space: 10),
            vendor.isFoodOrBeverage
                ? CustomTextFormField(
                    isReadOnly: true,
                    hintText: selectedDate ?? "mm/dd/yyyy",
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        onSelectDate(DateFormat('yyyy-MM-dd', 'en').format(picked), 0);
                      }
                    },
                  )
                : DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    hint: "Select date".tr().text.make(),
                    value: vendor.deliverySlots.indexWhere((s) => DateFormat('yyyy-MM-dd', 'en').format(s.date) == selectedDate) >= 0 
                           ? vendor.deliverySlots.indexWhere((s) => DateFormat('yyyy-MM-dd', 'en').format(s.date) == selectedDate) 
                           : null,
                    items: vendor.deliverySlots.asMap().entries.map((entry) {
                      final index = entry.key;
                      final slot = entry.value;
                      final formatted = DateFormat('yyyy-MM-dd', 'en').format(slot.date);
                      final isFull = dateFull.contains(formatted);
                      final label = Jiffy.parseFromDateTime(slot.date).format(pattern: 'EEEE dd MMM yyyy');
                      return DropdownMenuItem<int>(
                        value: index,
                        enabled: !isFull,
                        child: (isFull ? "$label (Unavailable)" : label).text.color(isFull ? Colors.grey : null).make(),
                      );
                    }).toList(),
                    onChanged: (index) {
                      if (index != null) {
                        final slot = vendor.deliverySlots[index];
                        final formatted = DateFormat('yyyy-MM-dd', 'en').format(slot.date);
                        if (!dateFull.contains(formatted)) {
                          onSelectDate(formatted, index);
                        }
                      }
                    },
                  ),
            UiSpacer.verticalSpace(space: 10),
            "Time".tr().text.lg.make(),
            UiSpacer.verticalSpace(space: 10),
            vendor.isFoodOrBeverage
                ? CustomTextFormField(
                    isReadOnly: true,
                    hintText: selectedTime != null 
                        ? Jiffy.parse('2024-01-01 $selectedTime').format(pattern: 'hh:mm a') 
                        : "--:-- --",
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        final now = DateTime.now();
                        final dt = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
                        onSelectTime(DateFormat('HH:mm:ss', 'en').format(dt));
                      }
                    },
                  )
                : (loadingTime
                    ? Center(child: BusyIndicator(color: AppColor.primaryColor))
                    : DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        hint: "Select time".tr().text.make(),
                        value: availableTimeSlots.any((t) {
                                  final today = DateFormat('yyyy-MM-dd', 'en').format(DateTime.now());
                                  return DateFormat('HH:mm:ss', 'en').format(DateTime.parse('$today $t')) == selectedTime;
                               })
                               ? selectedTime
                               : null,
                        items: availableTimeSlots.map((time) {
                          final today = DateFormat('yyyy-MM-dd', 'en').format(DateTime.now());
                          final formattedTime = DateFormat('HH:mm:ss', 'en').format(DateTime.parse('$today $time'));
                          final isFull = timeFull.contains(formattedTime);
                          final label = Jiffy.parse('$today $time').format(pattern: 'hh:mm a');
                          return DropdownMenuItem<String>(
                            value: formattedTime,
                            enabled: !isFull,
                            child: (isFull ? "$label (Unavailable)" : label).text.color(isFull ? Colors.grey : null).make(),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null && !timeFull.contains(val)) {
                            onSelectTime(val);
                          }
                        },
                      )),
            if (vendor.isFoodOrBeverage &&
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
                  if (vendor.can_dinein == true && onSelectTable != null)
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
                                    onTap: table['available'] == false
                                        ? null
                                        : () => onSelectTable!(table['name']),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppColor.primaryColor,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        color: selected
                                            ? AppColor.primaryColor
                                            : Colors.transparent,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          "Table"
                                              .text
                                              .semiBold
                                              .color(selected
                                                  ? Colors.white
                                                  : null)
                                              .make(),
                                          "${table['name']}"
                                              .text
                                              .bold
                                              .color(selected
                                                  ? Colors.white
                                                  : null)
                                              .make(),
                                          table['available'] == true
                                              ? "Available".text.sm
                                                  .color(selected
                                                      ? Colors.white
                                                      : null)
                                                  .make()
                                              : "Not Available".text.sm
                                                  .color(selected
                                                      ? Colors.white
                                                      : Colors.red)
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
