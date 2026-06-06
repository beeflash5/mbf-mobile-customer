import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/custom_image.view.dart';
import 'package:fuodz/component/directional_chevron.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/providers/taxi_order_summary_providers.dart';
import 'package:fuodz/providers/taxi_providers.dart';
import 'package:fuodz/utils/utils.dart';

class NewTaxiOrderPaymentMethodSelectionView extends ConsumerWidget {
  const NewTaxiOrderPaymentMethodSelectionView({
    super.key,
    required this.vendorType,
  });

  final VendorType vendorType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taxiState = ref.watch(taxiControllerProvider(vendorType));
    final summaryController = ref.read(
      taxiOrderSummaryControllerProvider(vendorType).notifier,
    );
    final pm = taxiState.selectedPaymentMethod;
    if (pm == null) return const SizedBox.shrink();
    return HStack(
      [
        CustomImage(
          imageUrl: pm.photo,
          boxFit: BoxFit.cover,
        ).wh(40, 40),
        pm.name.text.make().px12().expand(),
        const DirectionalChevron(),
      ],
    )
        .onInkTap(() => summaryController.openPaymentMethodSelection(context))
        .px8()
        .py4()
        .box
        .roundedSM
        .color(Utils.systemGreyColor())
        .make();
  }
}
