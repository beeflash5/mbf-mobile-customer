import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/custom_text_form_field.dart';
import 'package:fuodz/component/list/delivery_address.list_item.dart';
import 'package:fuodz/models/delivery_address.dart';
import 'package:fuodz/pages/delivery_address/new_delivery_addresses.page.dart';
import 'package:fuodz/providers/delivery_address_picker_providers.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/delivery_address.helper.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class DeliveryAddressPicker extends ConsumerWidget {
  const DeliveryAddressPicker({
    required this.onSelectDeliveryAddress,
    this.allowOnMap = false,
    this.vendorCheckRequired = true,
    super.key,
  });

  final Function(DeliveryAddress) onSelectDeliveryAddress;
  final bool allowOnMap;
  final bool vendorCheckRequired;

  Future<void> _pickFromMap(BuildContext context) async {
    final result = await DeliveryAddressHelper.newPlacePicker(context);
    if (result == null) return;
    final addr = DeliveryAddress();
    await DeliveryAddressHelper.applyPickerResult(
      result,
      addr,
      TextEditingController(),
    );
    onSelectDeliveryAddress(addr);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(
      deliveryAddressPickerControllerProvider(vendorCheckRequired),
    );
    final notifier = ref.read(
      deliveryAddressPickerControllerProvider(vendorCheckRequired).notifier,
    );
    final filtered = asyncState.valueOrNull?.filtered ?? const [];

    return VStack([
          UiSpacer.swipeIndicator().py12(),
          HStack([
            VStack([
              "Delivery address".tr().text.make(),
              "Select order delivery address".tr().text.make(),
            ]).expand(),
            AuthServices.authenticated()
                ? CustomButton(
                  title: "New".tr(),
                  icon: Icons.add,
                  onPressed: () async {
                    await context.pushWidget(const NewDeliveryAddressesPage());
                    notifier.refresh();
                  },
                )
                : UiSpacer.emptySpace(),
          ]).p16().box.outerShadow.color(context.cardColor).make(),
          CustomTextFormField(
            hintText: "Search".tr(),
            prefixIcon: Icon(
              Icons.search,
              size: 20,
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
            ),
            onChanged: notifier.filter,
          ).p20(),
          CustomVisibilty(
            visible: asyncState.isLoading || filtered.isNotEmpty,
            child: SafeArea(
              top: false,
              child: CustomListView(
                dataSet: filtered,
                isLoading: asyncState.isLoading,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemBuilder: (context, index) {
                  final addr = filtered[index];
                  return DeliveryAddressListItem(
                    deliveryAddress: addr,
                    action: false,
                    borderColor: Colors.grey.shade300,
                  ).onInkTap(
                    (addr.can_deliver == null || addr.can_deliver!)
                        ? () => onSelectDeliveryAddress(addr)
                        : null,
                  );
                },
                separatorBuilder: (context, index) => UiSpacer.verticalSpace(),
              ),
            ),
          ).expand(),
          allowOnMap
              ? SafeArea(
                child:
                    TextButton.icon(
                      style: TextButton.styleFrom(alignment: Alignment.center),
                      label: "Choose on map".tr().text.make(),
                      icon: const Icon(Icons.location_on),
                      onPressed: () => _pickFromMap(context),
                    ).wFull(context).px20(),
              )
              : UiSpacer.emptySpace(),
        ]).box
        .color(context.theme.colorScheme.surface)
        .topRounded()
        .clip(Clip.antiAlias)
        .make()
        .h(context.percentHeight * 95);
  }
}
