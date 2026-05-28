import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/checkout_base.vm.dart';
import 'package:fuodz/widgets/busy_indicator.dart';
import 'package:fuodz/widgets/custom_grid_view.dart';
import 'package:fuodz/widgets/custom_list_view.dart';
import 'package:fuodz/widgets/custom_text_form_field.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class ScheduleOrderView extends StatelessWidget {
  const ScheduleOrderView(this.vm, {Key? key}) : super(key: key);
  final CheckoutBaseViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: vm.vendor!.allowScheduleOrder,
      child: VStack([
        HStack([
              //

              //
              vm.vendor?.vendorType.slug == 'food'
                  ? VStack([
                    "Reservation".tr().text.lg.semiBold.make(),
                    "Do you want to make a reservation?".tr().text.make(),
                  ]).expand()
                  : VStack([
                    "Schedule Order".tr().text.lg.semiBold.make(),
                    "When do you want to book this service?"
                        .tr()
                        .text
                        .color(Color(0xff808080))
                        .make(),
                  ]).expand(),

              Checkbox(
                value: vm.isScheduled,
                onChanged: vm.toggleScheduledOrder,
              ),
            ], crossAlignment: CrossAxisAlignment.start)
            .wFull(context)
            .onInkTap(() => vm.toggleScheduledOrder(!vm.isScheduled)),

        //delivery time slots
        Visibility(
          visible: vm.isScheduled,
          child: VStack([
            //date slot
            UiSpacer.verticalSpace(),
            "Date slot".tr().text.lg.make(),

            CustomListView(
              scrollDirection: Axis.horizontal,
              dataSet: vm.vendor!.deliverySlots,
              itemBuilder: (context, index) {
                final dateDeliverySlot = vm.vendor!.deliverySlots[index];

                final formmatedDeliverySlot = DateFormat(
                  "yyyy-MM-dd",
                  "en",
                ).format(dateDeliverySlot.date);
                bool selected =
                    (formmatedDeliverySlot == vm.checkout?.deliverySlotDate);
                //

                final dateFullList = vm.date_full ?? [];

                final isFull = dateFullList.contains(formmatedDeliverySlot);
                return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Jiffy.parseFromDateTime(dateDeliverySlot.date)
                            .format(pattern: "EEEE dd MMM yyyy")
                            .text
                            .color(
                              isFull
                                  ? Colors.grey
                                  : (selected ? Colors.white : null),
                            )
                            .makeCentered(),

                        if (isFull)
                          "Full".text.bold
                              .size(10)
                              .color(selected ? Colors.white70 : Colors.red)
                              .make(),
                      ],
                    )
                    .px8()
                    .py4()
                    .box
                    .roundedSM
                    .border(color: AppColor.primaryColor)
                    .color(
                      isFull
                          ? Colors.grey.withOpacity(0.2)
                          : (selected
                              ? AppColor.primaryColor
                              : Colors.transparent),
                    )
                    .make()
                    .onInkTap(
                      isFull
                          ? null // 🔥 disable klik
                          : () => vm.changeSelectedDeliveryDate(
                            formmatedDeliverySlot,
                            index,
                          ),
                    );
                // return Jiffy.parseFromDateTime(dateDeliverySlot.date)
                //     .format(pattern: "EEEE dd MMM yyyy")
                //     .text
                //     .color(selected ? Colors.white : null)
                //     .makeCentered()
                //     .px8()
                //     .py4()
                //     .box
                //     .roundedSM
                //     .border(color: AppColor.primaryColor)
                //     .color(
                //       selected ? AppColor.primaryColor : Colors.transparent,
                //     )
                //     .make()
                //     .onInkTap(
                //       () => vm.changeSelectedDeliveryDate(
                //         formmatedDeliverySlot,
                //         index,
                //       ),
                //     );
              },
            ).h(Vx.dp56).py8(),
            //
            UiSpacer.verticalSpace(space: 10),
            "Time slot".tr().text.lg.make(),
            UiSpacer.verticalSpace(space: 10),
            vm.busy(vm.getTimeUse)
                ? Center(child: BusyIndicator(color: AppColor.primaryColor))
                : CustomGridView(
                  // scrollDirection: Axis.horizontal,
                  noScrollPhysics: true,
                  // padding: EdgeInsets.symmetric(horizontal: 10),
                  dataSet: vm.availableTimeSlots,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.7,
                  crossAxisCount: 3,
                  itemBuilder: (context, index) {
                    //
                    final today = DateFormat(
                      "yyyy-MM-dd",
                      "en",
                    ).format(DateTime.now());
                    final availableTimeSlot = vm.availableTimeSlots[index];
                    final formmatedDeliveryTimeSlot = DateFormat(
                      "HH:mm:ss",
                      "en",
                    ).format(DateTime.parse("$today $availableTimeSlot"));

                    //check if selected
                    bool selected =
                        formmatedDeliveryTimeSlot ==
                        vm.checkout?.deliverySlotTime;

                    final timeFullList = vm.time_full ?? [];

                    // ubah availableTimeSlot ke format backend (HH:mm:ss)
                    final formattedSlot =
                        Jiffy.parse(
                          "$today $availableTimeSlot",
                        ).format(pattern: "HH:mm:ss").toString();

                    final isFull = timeFullList.contains(formattedSlot);

                    return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Jiffy.parse("$today $availableTimeSlot")
                                .format(pattern: "hh:mm a")
                                .text
                                .color(selected ? Colors.white : null)
                                .make(),

                            if (isFull)
                              "Full".text.bold
                                  .size(10)
                                  .color(selected ? Colors.white70 : Colors.red)
                                  .make(),
                          ],
                        ).box.roundedSM
                        .border(color: AppColor.primaryColor)
                        .color(
                          isFull
                              ? Colors.grey.withOpacity(0.2)
                              : (selected
                                  ? AppColor.primaryColor
                                  : Colors.transparent),
                        )
                        .padding(const EdgeInsets.symmetric(vertical: 6))
                        .make()
                        .onInkTap(
                          isFull
                              ? null // 🔥 disable kalau full
                              : () => vm.changeSelectedDeliveryTime(
                                formmatedDeliveryTimeSlot,
                              ),
                        );
                    //
                    // return Jiffy.parse("$today $availableTimeSlot")
                    //     .format(pattern: "hh:mm a")
                    //     .text
                    //     .color(selected ? Colors.white : null)
                    //     .makeCentered()
                    //     .box
                    //     .roundedSM
                    //     .border(color: AppColor.primaryColor)
                    //     .color(
                    //       selected ? AppColor.primaryColor : Colors.transparent,
                    //     )
                    //     .make()
                    //     .onInkTap(
                    //       () => vm.changeSelectedDeliveryTime(
                    //         formmatedDeliveryTimeSlot,
                    //       ),
                    //     );
                  },
                ),

            vm.vendor?.vendorType.slug == 'food'
                ? Column(
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
                      textEditingController: vm.guest_count,
                    ),

                    UiSpacer.verticalSpace(space: 20),
                    vm.vendor?.can_dinein == true
                        ? Column(
                          children: [
                            "Dine-in".tr().text.lg.make(),
                            "Select your preferred table for reservation"
                                .tr()
                                .text
                                .sm
                                .make(),
                            UiSpacer.verticalSpace(space: 10),
                            vm.busy(vm.getTableUse)
                                ? Center(
                                  child: BusyIndicator(
                                    color: AppColor.primaryColor,
                                  ),
                                )
                                : CustomGridView(
                                  // scrollDirection: Axis.horizontal,
                                  noScrollPhysics: true,
                                  // padding: EdgeInsets.symmetric(horizontal: 10),
                                  dataSet: vm.tables,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 0.9,
                                  crossAxisCount: 3,
                                  itemBuilder: (context, index) {
                                    final table = vm.tables[index];
                                    bool selected =
                                        table['name'] == vm.tableSelected;
                                    //
                                    return InkWell(
                                      onTap:
                                          table['available'] == false
                                              ? null
                                              : () {
                                                vm.selectTableSelecte(
                                                  table['name'],
                                                );
                                              },
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

                                    // "".text
                                    //     .color(selected ? Colors.white : null)
                                    //     .makeCentered()
                                    //     .box
                                    //     .roundedSM
                                    //     .border(color: AppColor.primaryColor)
                                    //     .color(
                                    //       selected ? AppColor.primaryColor : Colors.transparent,
                                    //     )
                                    //     .make()
                                    //     .onInkTap(() {});
                                    //
                                    // final today = DateFormat(
                                    //   "yyyy-MM-dd",
                                    //   "en",
                                    // ).format(DateTime.now());
                                    // final availableTimeSlot = vm.availableTimeSlots[index];
                                    // final formmatedDeliveryTimeSlot = DateFormat(
                                    //   "HH:mm:ss",
                                    //   "en",
                                    // ).format(DateTime.parse("$today $availableTimeSlot"));

                                    // //check if selected
                                    // bool selected =
                                    //     formmatedDeliveryTimeSlot ==
                                    //     vm.checkout?.deliverySlotTime;
                                    // //
                                    // return Jiffy.parse("$today $availableTimeSlot")
                                    //     .format(pattern: "hh:mm a")
                                    //     .text
                                    //     .color(selected ? Colors.white : null)
                                    //     .makeCentered()
                                    //     .box
                                    //     .roundedSM
                                    //     .border(color: AppColor.primaryColor)
                                    //     .color(
                                    //       selected
                                    //           ? AppColor.primaryColor
                                    //           : Colors.transparent,
                                    //     )
                                    //     .make()
                                    //     .onInkTap(
                                    //       () => vm.changeSelectedDeliveryTime(
                                    //         formmatedDeliveryTimeSlot,
                                    //       ),
                                    //     );
                                  },
                                ),
                          ],
                        )
                        : SizedBox(),
                  ],
                )
                : SizedBox(),
            // CustomGridView(dataSet: dataSet, itemBuilder: itemBuilder),
          ]),
        ),
      ]).p12().box.roundedSM.border(color: Color(0xffD9D9D9)).make().pOnly(bottom: Vx.dp20),
    );
  }
}
