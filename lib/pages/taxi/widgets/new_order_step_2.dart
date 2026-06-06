import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/providers/taxi_order_summary_providers.dart';
import 'package:fuodz/providers/taxi_providers.dart';

import 'step_two/new_taxi_order_summary.collapsed.dart';

class NewTaxiOrderSummaryView extends ConsumerStatefulWidget {
  const NewTaxiOrderSummaryView({super.key, required this.vendorType});

  final VendorType vendorType;

  @override
  ConsumerState<NewTaxiOrderSummaryView> createState() =>
      _NewTaxiOrderSummaryViewState();
}

class _NewTaxiOrderSummaryViewState
    extends ConsumerState<NewTaxiOrderSummaryView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(taxiOrderSummaryControllerProvider(widget.vendorType).notifier)
          .initialise();
    });
  }

  @override
  Widget build(BuildContext context) {
    final taxiState = ref.watch(taxiControllerProvider(widget.vendorType));
    return Visibility(
      visible: taxiState.currentOrderStep == 2,
      child: Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Padding(
          padding: EdgeInsets.only(bottom: context.mq.viewInsets.bottom),
          child: NewTaxiOrderSummaryCollapsed(vendorType: widget.vendorType),
        ),
      ),
    );
  }
}
