import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/providers/taxi_order_entry_providers.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/utils.dart';

class NewTaxiPickOnMapButton extends ConsumerWidget {
  const NewTaxiPickOnMapButton({super.key, required this.vendorType});

  final VendorType vendorType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryState = ref.watch(taxiOrderEntryControllerProvider(vendorType));
    final entryController = ref.read(
      taxiOrderEntryControllerProvider(vendorType).notifier,
    );
    return Visibility(
      visible: entryState.showChooseOnMap,
      child: HStack([
            Icon(Icons.map, color: AppColor.primaryColor),
            "Choose a place on the map"
                .tr()
                .text
                .lg
                .medium
                .make()
                .px16()
                .expand(),
            Icon(
              Utils.isArabic ? Icons.chevron_left : Icons.chevron_right,
              color: Colors.grey.shade300,
            ),
          ])
          .safeArea(top: false)
          .p12()
          .box
          .color(Utils.textColorByBrightness(context, true))
          .shadowSm
          .make()
          .onInkTap(() => entryController.handleChooseOnMap(context)),
    );
  }
}
