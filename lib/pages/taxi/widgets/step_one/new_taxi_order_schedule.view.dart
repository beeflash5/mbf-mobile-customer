import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/jiffy.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/providers/taxi_order_entry_providers.dart';
import 'package:fuodz/providers/taxi_providers.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';

class NewTaxiOrderScheduleView extends ConsumerWidget {
  const NewTaxiOrderScheduleView({super.key, required this.vendorType});

  final VendorType vendorType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taxiState = ref.watch(taxiControllerProvider(vendorType));
    final entryController = ref.read(
      taxiOrderEntryControllerProvider(vendorType).notifier,
    );
    final pickupDate = taxiState.checkout?.pickupDate;
    final pickupTime = taxiState.checkout?.pickupTime;
    return CustomVisibilty(
      visible: AppStrings.canScheduleTaxiOrder,
      child: VStack([
        HStack([
          "Schedule Order".tr().text.medium.lg.make().expand(),
          UiSpacer.hSpace(),
          Visibility(
            visible: pickupDate != null,
            child: HStack([
              const Icon(
                Icons.close,
                color: Colors.red,
                size: 20,
              ).onInkTap(entryController.clearScheduleSelection),
              UiSpacer.hSpace(10),
            ]),
          ),
          HStack(
                [
                  const Icon(Icons.calendar_today, size: 18),
                  UiSpacer.hSpace(5),
                  (pickupDate != null
                          ? (!Utils.isArabic
                              ? Jiffy.parse(
                                "$pickupDate $pickupTime",
                                pattern: "yyyy-MM-dd HH:mm",
                              ).format(pattern: "d MMM, y hh:mm a")
                              : "$pickupDate $pickupTime")
                          : "Now".tr())
                      .text
                      .sm
                      .semiBold
                      .make(),
                ],
                crossAlignment: CrossAxisAlignment.center,
                alignment: MainAxisAlignment.center,
              ).box.roundedSM
              .padding(const EdgeInsets.symmetric(vertical: 5, horizontal: 10))
              .border(color: AppColor.primaryColor, width: 0.88)
              .color(context.theme.colorScheme.surface)
              .shadowXs
              .make(),
        ]).onTap(() => entryController.showSchedulePeriodPicker(context)),
        UiSpacer.vSpace(10),
      ]),
    );
  }
}
