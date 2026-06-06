import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/busy_indicator.dart';
import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/custom_grid_view.dart';
import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/providers/reschedule_providers.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/extensions/dynamic.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class RescheduleBottomSheet extends ConsumerWidget {
  const RescheduleBottomSheet({
    Key? key,
    required this.onSubmitted,
    required this.order,
  }) : super(key: key);

  final Order order;
  final Function onSubmitted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(rescheduleControllerProvider(order));
    final notifier = ref.read(rescheduleControllerProvider(order).notifier);
    final s = asyncState.valueOrNull;
    final isLoading = asyncState.isLoading;
    final currentVendor = s?.vendor;

    return BasePage(
      body: VStack([
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
        UiSpacer.verticalSpace(),
        "Date slot".tr().text.lg.make(),
        (isLoading || currentVendor == null)
            ? BusyIndicator(color: AppColor.primaryColor).centered()
            : CustomListView(
                scrollDirection: Axis.horizontal,
                dataSet: currentVendor.deliverySlots,
                itemBuilder: (context, index) {
                  final slot = currentVendor.deliverySlots[index];
                  final formatted =
                      DateFormat('yyyy-MM-dd', 'en').format(slot.date);
                  final selected = formatted == s?.deliverySlotDate;
                  return Jiffy.parseFromDateTime(slot.date)
                      .format(pattern: 'EEEE dd MMM yyyy')
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
                      .onInkTap(
                        () =>
                            notifier.selectDeliveryDate(formatted, index),
                      );
                },
              ).h(Vx.dp32).py8(),
        UiSpacer.verticalSpace(space: 10),
        "Time slot".tr().text.lg.make(),
        UiSpacer.verticalSpace(space: 10),
        CustomGridView(
          noScrollPhysics: true,
          dataSet: s?.availableTimeSlots ?? const <String>[],
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 3,
          crossAxisCount: 3,
          itemBuilder: (context, index) {
            final today = DateFormat('yyyy-MM-dd', 'en').format(DateTime.now());
            final availableTimeSlot = s!.availableTimeSlots[index];
            final formattedTime = DateFormat('HH:mm:ss', 'en')
                .format(DateTime.parse('$today $availableTimeSlot'));
            final selected = formattedTime == s.deliverySlotTime;
            return Jiffy.parse('$today $availableTimeSlot')
                .format(pattern: 'hh:mm a')
                .text
                .color(selected ? Colors.white : null)
                .makeCentered()
                .box
                .roundedSM
                .border(color: AppColor.primaryColor)
                .color(selected ? AppColor.primaryColor : Colors.transparent)
                .make()
                .onInkTap(() => notifier.selectDeliveryTime(formattedTime));
          },
        ),
        UiSpacer.verticalSpace(space: 20),
        "Dine-in".tr().text.lg.make(),
        "Select your preferred table for reservation".tr().text.sm.make(),
        UiSpacer.verticalSpace(space: 10),
        (s?.loadingTables ?? false)
            ? Center(child: BusyIndicator(color: AppColor.primaryColor))
            : CustomGridView(
                noScrollPhysics: true,
                dataSet: s?.tables ?? const <Map<String, dynamic>>[],
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.9,
                crossAxisCount: 3,
                itemBuilder: (context, index) {
                  final table = s!.tables[index];
                  final selected = table['name'] == s.tableSelected;
                  return InkWell(
                    onTap: table['available'] == false
                        ? null
                        : () => notifier.selectTable(table['name']),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColor.primaryColor),
                        borderRadius: BorderRadius.circular(8),
                        color: selected
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
                                      selected ? Colors.white : Colors.red)
                                  .make(),
                        ],
                      ),
                    ),
                  );
                },
              ),
        (s?.tableSelected == null)
            ? const SizedBox()
            : SafeArea(
                child: CustomButton(
                  title: "Submit".tr(),
                  onPressed: () async {
                    final result = await notifier.submit();
                    if (!context.mounted) return;
                    AlertService.dynamic(
                      type: switch (result) {
                        RescheduleSuccess() => AlertType.success,
                        RescheduleFailure() => AlertType.error,
                      },
                      title: 'Reschedule'.tr(),
                      text: switch (result) {
                        RescheduleSuccess(:final message) => message,
                        RescheduleFailure(:final message) => message,
                      },
                      onConfirm: switch (result) {
                        RescheduleSuccess() => () => onSubmitted(),
                        RescheduleFailure() => null,
                      },
                    );
                  },
                  loading: isLoading,
                ).centered().py16(),
              ),
      ]).p20().scrollVertical(),
    ).hTwoThird(context).pOnly(bottom: context.mq.viewInsets.bottom);
  }
}
