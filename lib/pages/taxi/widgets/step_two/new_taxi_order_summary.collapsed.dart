import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:measure_size/measure_size.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/button/custom_text_button.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/pages/taxi/widgets/order_taxi.button.dart';
import 'package:fuodz/pages/taxi/widgets/step_two/new_style_taxi_order_vehicle_type.list_view.dart';
import 'package:fuodz/pages/taxi/widgets/step_two/new_taxi_order_payment_method.selection_view.dart';
import 'package:fuodz/pages/taxi/widgets/taxi_discount_section.dart';
import 'package:fuodz/providers/taxi_order_summary_providers.dart';
import 'package:fuodz/providers/taxi_providers.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';

class NewTaxiOrderSummaryCollapsed extends ConsumerWidget {
  const NewTaxiOrderSummaryCollapsed({super.key, required this.vendorType});

  final VendorType vendorType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taxiState = ref.watch(taxiControllerProvider(vendorType));
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
                      titleColor: Utils.textColorByBrightness(),
                      padding: EdgeInsets.zero,
                      title: "Back".tr(),
                      onPressed:
                          () => taxiController.closeOrderSummary(clear: false),
                    ).h(24),
                    const Spacer(),
                    CustomTextButton(
                      padding: EdgeInsets.zero,
                      title: "Cancel".tr(),
                      titleColor: Colors.red,
                      onPressed: taxiController.closeOrderSummary,
                    ).h(24),
                  ], alignment: MainAxisAlignment.spaceBetween).py(20),
                  NewTaxiVehicleTypeListView(
                    vendorType: vendorType,
                  ).wFull(context),
                ]),
                Divider(
                  color: Colors.grey.shade300,
                  height: 10,
                  thickness: 0.8,
                ).pOnly(bottom: 8),
                VStack([
                  TaxiDiscountSection(
                    vendorType: vendorType,
                    fullView: true,
                  ).box.p8.make().py8(),
                  HStack([
                    NewTaxiOrderPaymentMethodSelectionView(
                      vendorType: vendorType,
                    ).expand(flex: 6),
                    UiSpacer.hSpace(),
                    VxBadge(
                      child:
                          IconButton(
                                onPressed:
                                    () => summaryController.openCouponDialog(
                                      context,
                                    ),
                                icon: Icon(
                                  Icons.local_offer,
                                  color: Utils.systemGreyColor(true),
                                ),
                              ).box.roundedSM
                              .color(Utils.systemGreyColor())
                              .px8
                              .make(),
                      color: AppColor.primaryColor,
                      size: 20,
                      count: taxiState.coupon != null ? 1 : 0,
                    ),
                  ]).px(12),
                  UiSpacer.vSpace(10),
                  OrderTaxiButton(vendorType: vendorType),
                ], spacing: 10).safeArea(top: false).pOnly(bottom: 12),
              ]).box
              .color(context.theme.colorScheme.surface)
              .topRounded(value: 5)
              .outerShadowXl
              .make(),
    );
  }
}
