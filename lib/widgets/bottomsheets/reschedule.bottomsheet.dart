import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/app_images.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/extensions/dynamic.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/reschedule.vm.dart';
import 'package:fuodz/view_models/vendor_rating.vm.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/busy_indicator.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:fuodz/widgets/custom_grid_view.dart';
import 'package:fuodz/widgets/custom_list_view.dart';
import 'package:fuodz/widgets/custom_text_form_field.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

class RescheduleBottomSheet extends StatelessWidget {
  const RescheduleBottomSheet({
    Key? key,
    required this.onSubmitted,
    required this.order,
  }) : super(key: key);

  //
  final Order order;
  final Function onSubmitted;

  //
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ResechuldeViewModel>.reactive(
      viewModelBuilder: () => ResechuldeViewModel(context, order, onSubmitted),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return BasePage(
          body:
              VStack([
                "Reschedule Reservation"
                    .tr()
                    .fill([order.vendor!.name])
                    .text
                    .center
                    .xl
                    .semiBold
                    .makeCentered(),
                "You can reschedule your reservation. Please note that ${AppStrings.reschedule_fee}% of the deposit will be deducted."
                    .tr()
                    .fill([order.vendor!.name])
                    .text
                    .center
                    .makeCentered()
                    .py12(),
                // "${order.vendor?.deliverySlots.length}".text.make(),
                UiSpacer.verticalSpace(),
                "Date slot".tr().text.lg.make(),
                vm.isBusy
                    ? BusyIndicator(color: AppColor.primaryColor).centered()
                    : CustomListView(
                      scrollDirection: Axis.horizontal,
                      dataSet: vm.currentOrderVendor!.deliverySlots,
                      itemBuilder: (context, index) {
                        final dateDeliverySlot =
                            vm.currentOrderVendor?.deliverySlots[index];

                        final formmatedDeliverySlot = DateFormat(
                          "yyyy-MM-dd",
                          "en",
                        ).format(dateDeliverySlot!.date);
                        bool selected =
                            (formmatedDeliverySlot == vm.deliverySlotDate);
                        //

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
                            .color(
                              selected
                                  ? AppColor.primaryColor
                                  : Colors.transparent,
                            )
                            .make()
                            .onInkTap(
                              () => vm.changeSelectedDeliveryDate(
                                formmatedDeliverySlot,
                                index,
                              ),
                            );
                      },
                    ).h(Vx.dp32).py8(),
                UiSpacer.verticalSpace(space: 10),
                "Time slot".tr().text.lg.make(),
                UiSpacer.verticalSpace(space: 10),
                CustomGridView(
                  // scrollDirection: Axis.horizontal,
                  noScrollPhysics: true,
                  // padding: EdgeInsets.symmetric(horizontal: 10),
                  dataSet: vm.availableTimeSlots,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 3,
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
                        formmatedDeliveryTimeSlot == vm.deliverySlotTime;
                    //
                    return Jiffy.parse("$today $availableTimeSlot")
                        .format(pattern: "hh:mm a")
                        .text
                        .color(selected ? Colors.white : null)
                        .makeCentered()
                        .box
                        .roundedSM
                        .border(color: AppColor.primaryColor)
                        .color(
                          selected ? AppColor.primaryColor : Colors.transparent,
                        )
                        .make()
                        .onInkTap(
                          () => vm.changeSelectedDeliveryTime(
                            formmatedDeliveryTimeSlot,
                          ),
                        );
                  },
                ),
                UiSpacer.verticalSpace(space: 20),
                "Dine-in".tr().text.lg.make(),
                "Select your preferred table for reservation"
                    .tr()
                    .text
                    .sm
                    .make(),
                UiSpacer.verticalSpace(space: 10),
                vm.busy(vm.getTableUse)
                    ? Center(child: BusyIndicator(color: AppColor.primaryColor))
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
                        bool selected = table['name'] == vm.tableSelected;
                        //
                        return InkWell(
                          onTap:
                              table['available'] == false
                                  ? null
                                  : () {
                                    vm.selectTableSelecte(table['name']);
                                  },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColor.primaryColor),
                              borderRadius: BorderRadius.circular(8),
                              color:
                                  selected
                                      ? AppColor.primaryColor
                                      : Colors.transparent,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                "Table".text.semiBold
                                    .color(selected ? Colors.white : null)
                                    .make(),
                                "${table['name']}".text.bold
                                    .color(selected ? Colors.white : null)
                                    .make(),
                                table['available'] == true
                                    ? "Available".text.sm
                                        .color(selected ? Colors.white : null)
                                        .make()
                                    : "Not Available".text.sm
                                        .color(
                                          selected ? Colors.white : Colors.red,
                                        )
                                        .make(),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                vm.tableSelected == null
                    ? SizedBox()
                    : SafeArea(
                      child:
                          CustomButton(
                            title: "Submit".tr(),
                            onPressed: vm.reschudule,
                            loading: vm.isBusy,
                          ).centered().py16(),
                    ),
              ]).p20().scrollVertical(),
        ).hTwoThird(context).pOnly(bottom: context.mq.viewInsets.bottom);
      },
    );
  }
}
