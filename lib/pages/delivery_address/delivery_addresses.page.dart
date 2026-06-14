import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/list/delivery_address.list_item.dart';
import 'package:fuodz/component/states/delivery_address.empty.dart';
import 'package:fuodz/component/states/error.state.dart';
import 'package:fuodz/pages/delivery_address/edit_delivery_addresses.page.dart';
import 'package:fuodz/pages/delivery_address/new_delivery_addresses.page.dart';
import 'package:fuodz/providers/delivery_addresses_providers.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class DeliveryAddressesPage extends ConsumerWidget {
  const DeliveryAddressesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(deliveryAddressesControllerProvider);
    final notifier = ref.read(deliveryAddressesControllerProvider.notifier);
    final addresses = asyncState.valueOrNull ?? const [];

    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: "Delivery Addresses".tr(),
      isLoading: asyncState.isLoading && addresses.isEmpty,
      fab: FloatingActionButton(
        backgroundColor: AppColor.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await context.pushWidget(const NewDeliveryAddressesPage());
          notifier.refresh();
        },
      ),
      body: CustomListView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, context.percentHeight * 20),
        dataSet: addresses,
        isLoading: asyncState.isLoading && addresses.isEmpty,
        emptyWidget: EmptyDeliveryAddress(),
        errorWidget: LoadingError(onrefresh: notifier.refresh),
        itemBuilder: (context, index) {
          final addr = addresses[index];
          return DeliveryAddressListItem(
            deliveryAddress: addr,
            onEditPressed: () async {
              await context.pushWidget(
                EditDeliveryAddressesPage(deliveryAddress: addr),
              );
              notifier.refresh();
            },
            onDeletePressed: () {
              AlertService.confirm(
                title: "Delete Delivery Address".tr(),
                text:
                    "Are you sure you want to delete this delivery address?"
                        .tr(),
                confirmBtnText: "Delete".tr(),
                onConfirm: () async {
                  final result = await notifier.deleteAddress(addr);
                  if (!context.mounted) return;
                  AlertService.dynamic(
                    type: switch (result) {
                      DeliveryAddressDeleteSuccess() => AlertType.success,
                      DeliveryAddressDeleteFailure() => AlertType.error,
                    },
                    title: "Delete Delivery Address".tr(),
                    text: switch (result) {
                      DeliveryAddressDeleteSuccess(:final message) => message,
                      DeliveryAddressDeleteFailure(:final message) => message,
                    },
                  );
                },
              );
            },
          );
        },
        separatorBuilder: (context, index) => UiSpacer.verticalSpace(space: 10),
      ),
    );
  }
}
