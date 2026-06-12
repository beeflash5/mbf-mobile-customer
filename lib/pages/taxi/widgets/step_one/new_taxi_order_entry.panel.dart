import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/busy_indicator.dart';
import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/custom_timeline_connector.dart';
import 'package:fuodz/component/list/address.list_item.dart';
import 'package:fuodz/component/taxi_custom_text_form_field.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/pages/taxi/widgets/step_one/new_taxi_order_schedule.view.dart';
import 'package:fuodz/pages/taxi/widgets/step_one/new_taxi_pick_on_map.view.dart';
import 'package:fuodz/providers/taxi_order_entry_providers.dart';
import 'package:fuodz/providers/taxi_providers.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class NewTaxiOrderEntryPanel extends ConsumerWidget {
  const NewTaxiOrderEntryPanel({super.key, required this.vendorType});

  final VendorType vendorType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taxiState = ref.watch(taxiControllerProvider(vendorType));
    final taxiController = ref.read(
      taxiControllerProvider(vendorType).notifier,
    );
    final entryState = ref.watch(taxiOrderEntryControllerProvider(vendorType));
    final entryController = ref.read(
      taxiOrderEntryControllerProvider(vendorType).notifier,
    );
    return VxBox(
          child:
              taxiState.isBusy
                  ? const BusyIndicator().centered().p20()
                  : VStack([
                    VStack([
                          HStack([
                            const Icon(
                              Icons.close,
                            ).onTap(() => entryController.closePanel(context)),
                            "Your route"
                                .tr()
                                .text
                                .bold
                                .xl
                                .make()
                                .px12()
                                .expand(),
                          ]),
                          UiSpacer.verticalSpace(),
                          NewTaxiOrderScheduleView(vendorType: vendorType),
                          HStack([
                            const CustomTimelineConnector(height: 50),
                            UiSpacer.hSpace(10),
                            VStack([
                              TaxiCustomTextFormField(
                                hintText: "Pickup Location".tr(),
                                controller: taxiController.pickupLocationTEC,
                                focusNode:
                                    taxiController.pickupLocationFocusNode,
                                onChanged: entryController.searchPlace,
                                clear: true,
                                onClearPressed:
                                    entryController.clearAlreadySelected,
                              ),
                              UiSpacer.vSpace(5),
                              TaxiCustomTextFormField(
                                hintText: "Drop-off Location".tr(),
                                controller: taxiController.dropoffLocationTEC,
                                focusNode:
                                    taxiController.dropoffLocationFocusNode,
                                onChanged: entryController.searchPlace,
                                clear: true,
                                onClearPressed:
                                    entryController.clearAlreadySelected,
                              ),
                            ]).expand(),
                          ]),
                        ])
                        .p20()
                        .safeArea()
                        .box
                        .shadowSm
                        .color(context.theme.colorScheme.surface)
                        .make(),
                    CustomListView(
                      padding: EdgeInsets.zero,
                      isLoading: entryState.placesBusy,
                      dataSet: entryState.places,
                      itemBuilder: (ctx, index) {
                        final place = entryState.places[index];
                        return AddressListItem(
                          place,
                          onAddressSelected:
                              (addr) => entryController.onAddressSelected(
                                context,
                                addr,
                              ),
                        );
                      },
                      separatorBuilder: (ctx, index) => UiSpacer.divider(),
                    ).box.make().expand(),
                    NewTaxiPickOnMapButton(vendorType: vendorType),
                    Visibility(
                      visible:
                          !taxiController.pickupLocationFocusNode.hasFocus &&
                          !taxiController.dropoffLocationFocusNode.hasFocus,
                      child: CustomButton(
                        title: "Next".tr(),
                        onPressed: entryController.moveToNextStep,
                      ).p8().safeArea(top: false),
                    ),
                  ]),
        )
        .color(
          taxiState.isBusy
              ? context.theme.colorScheme.surface.withOpacity(0.5)
              : context.theme.colorScheme.surface,
        )
        .make();
  }
}
