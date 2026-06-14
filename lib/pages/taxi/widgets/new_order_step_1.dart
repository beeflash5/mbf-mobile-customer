import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/providers/taxi_order_entry_providers.dart';
import 'package:fuodz/providers/taxi_providers.dart';

import 'step_one/new_taxi_order_entry.collapsed.dart';
import 'step_one/new_taxi_order_entry.panel.dart';

class NewTaxiOrderLocationEntryView extends ConsumerStatefulWidget {
  const NewTaxiOrderLocationEntryView({super.key, required this.vendorType});

  final VendorType vendorType;

  @override
  ConsumerState<NewTaxiOrderLocationEntryView> createState() =>
      _NewTaxiOrderLocationEntryViewState();
}

class _NewTaxiOrderLocationEntryViewState
    extends ConsumerState<NewTaxiOrderLocationEntryView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(taxiOrderEntryControllerProvider(widget.vendorType).notifier)
          .initialise();
    });
  }

  @override
  Widget build(BuildContext context) {
    final taxiState = ref.watch(taxiControllerProvider(widget.vendorType));
    final entryState = ref.watch(
      taxiOrderEntryControllerProvider(widget.vendorType),
    );
    final entryController = ref.read(
      taxiOrderEntryControllerProvider(widget.vendorType).notifier,
    );
    return Visibility(
      visible: taxiState.currentOrderStep == 1,
      child: Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: SlidingUpPanel(
          color: Colors.transparent,
          panel: NewTaxiOrderEntryPanel(vendorType: widget.vendorType),
          collapsed: NewTaxiOrderEntryCollapsed(vendorType: widget.vendorType),
          controller: entryController.panelController,
          minHeight: entryState.customViewHeight,
          maxHeight: context.screenHeight,
        ),
      ),
    );
  }
}
