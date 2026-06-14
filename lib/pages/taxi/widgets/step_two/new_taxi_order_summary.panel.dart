import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:measure_size/measure_size.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/button/custom_text_button.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/pages/taxi/widgets/order_taxi.button.dart';
import 'package:fuodz/pages/taxi/widgets/step_two/new_taxi_order_payment_method.selection_view.dart';
import 'package:fuodz/pages/taxi/widgets/step_two/new_taxi_order_vehicle_type.list_view.dart';
import 'package:fuodz/pages/taxi/widgets/taxi_discount_section.dart';
import 'package:fuodz/providers/taxi_order_summary_providers.dart';
import 'package:fuodz/providers/taxi_providers.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class NewTaxiOrderSummaryPanel extends ConsumerWidget {
  const NewTaxiOrderSummaryPanel({super.key, required this.vendorType});

  final VendorType vendorType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taxiController = ref.read(
      taxiControllerProvider(vendorType).notifier,
    );
    final summaryController = ref.read(
      taxiOrderSummaryControllerProvider(vendorType).notifier,
    );
    return MeasureSize(
      onChange: (size) {
        taxiController.updateGoogleMapPadding(height: size.height + Vx.dp40);
      },
      child:
          VStack([
                VStack([
                  HStack([
                    CustomTextButton(
                      padding: EdgeInsets.zero,
                      title: "Back".tr(),
                      onPressed: () => summaryController.closePanel(context),
                    ).h(24),
                    UiSpacer.swipeIndicator().px12().expand(),
                    CustomTextButton(
                      padding: EdgeInsets.zero,
                      title: "Cancel".tr(),
                      titleColor: Colors.red,
                      onPressed: taxiController.closeOrderSummary,
                    ).h(24),
                  ]),
                  UiSpacer.verticalSpace(),
                  TaxiVehicleTypeListView(
                    vendorType: vendorType,
                    min: false,
                  ).expand(),
                  UiSpacer.vSpace(),
                ]).safeArea().p20().expand(),
                VStack([
                      TaxiDiscountSection(
                        vendorType: vendorType,
                        fullView: true,
                      ).box.p8.make().py8(),
                      NewTaxiOrderPaymentMethodSelectionView(
                        vendorType: vendorType,
                      ),
                      UiSpacer.vSpace(10),
                      OrderTaxiButton(vendorType: vendorType),
                    ])
                    .safeArea(top: false)
                    .pSymmetric(h: 20, v: 12)
                    .box
                    .shadow2xl
                    .color(context.theme.colorScheme.surface)
                    .make(),
              ]).box
              .color(context.theme.colorScheme.surface)
              .topRounded(value: 5)
              .make(),
    );
  }
}
