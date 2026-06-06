import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:measure_size/measure_size.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/busy_indicator.dart';
import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/list/taxi_order_location_history.list_item.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/providers/taxi_order_entry_providers.dart';
import 'package:fuodz/providers/taxi_providers.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class NewTaxiOrderEntryCollapsed extends ConsumerWidget {
  const NewTaxiOrderEntryCollapsed({super.key, required this.vendorType});

  final VendorType vendorType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taxiState = ref.watch(taxiControllerProvider(vendorType));
    final taxiController =
        ref.read(taxiControllerProvider(vendorType).notifier);
    final entryState =
        ref.watch(taxiOrderEntryControllerProvider(vendorType));
    final entryController = ref.read(
      taxiOrderEntryControllerProvider(vendorType).notifier,
    );
    return MeasureSize(
      onChange: (size) {
        taxiController.updateGoogleMapPadding(
          height: entryState.customViewHeight + 30,
        );
      },
      child: VxBox(
        child: taxiState.isBusy
            ? const BusyIndicator().centered().p20()
            : VStack(
                [
                  UiSpacer.swipeIndicator(),
                  UiSpacer.vSpace(),
                  HStack(
                    [
                      Icon(
                        Icons.search,
                        size: 24,
                        color: AppColor.primaryColor,
                      ),
                      "Where to?".tr().text.semiBold.lg.make().px12().expand(),
                      CustomVisibilty(
                        visible: AppStrings.canScheduleTaxiOrder,
                        child: Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: AppColor.primaryColor,
                        )
                            .onInkTap(() =>
                                entryController.onScheduleOrderPressed(context))
                            .p2(),
                      ),
                    ],
                  )
                      .px12()
                      .py8()
                      .box
                      .color(context.theme.colorScheme.surface)
                      .shadowXs
                      .withRounded(value: 5)
                      .border(color: AppColor.primaryColor)
                      .make()
                      .onTap(entryController.onDestinationPressed),
                  Padding(
                    padding: entryState.shortPreviousAddressesList.isEmpty
                        ? const EdgeInsets.all(5)
                        : const EdgeInsets.symmetric(vertical: 5),
                    child: CustomListView(
                      isLoading: entryState.previousAddressesBusy,
                      dataSet: entryState.shortPreviousAddressesList,
                      padding: EdgeInsets.zero,
                      itemBuilder: (ctx, index) {
                        final orderAddressHistory =
                            entryState.shortPreviousAddressesList[index];
                        return TaxiOrderHistoryListItem(
                          orderAddressHistory,
                          onPressed: (value) =>
                              entryController.onDestinationSelected(
                            context,
                            value,
                          ),
                        );
                      },
                      separatorBuilder: (ctx, index) => UiSpacer.divider(),
                    ),
                  ),
                ],
              ),
      )
          .p20
          .color(context.theme.colorScheme.surface)
          .topRounded(value: 25)
          .outerShadow2Xl
          .make(),
    );
  }
}
