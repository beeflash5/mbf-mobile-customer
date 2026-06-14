import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/button/custom_leading.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/pages/taxi/widgets/new_order_step_1.dart';
import 'package:fuodz/pages/taxi/widgets/new_order_step_2.dart';
import 'package:fuodz/pages/taxi/widgets/taxi_rate_driver.view.dart';
import 'package:fuodz/pages/taxi/widgets/taxi_trip_ready.view.dart';
import 'package:fuodz/pages/taxi/widgets/trip_driver_search.dart';
import 'package:fuodz/pages/taxi/widgets/unsupported_taxi_location.view.dart';
import 'package:fuodz/providers/taxi_providers.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/utils.dart';

class TaxiPage extends ConsumerStatefulWidget {
  const TaxiPage(this.vendorType, {super.key});

  final VendorType vendorType;

  @override
  ConsumerState<TaxiPage> createState() => _TaxiPageState();
}

class _TaxiPageState extends ConsumerState<TaxiPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taxiControllerProvider(widget.vendorType).notifier).initialise();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    ref
        .read(taxiControllerProvider(widget.vendorType).notifier)
        .setGoogleMapStyle(context);
  }

  @override
  Widget build(BuildContext context) {
    final taxiState = ref.watch(taxiControllerProvider(widget.vendorType));
    final taxiController = ref.read(
      taxiControllerProvider(widget.vendorType).notifier,
    );
    return BasePage(
      showAppBar: false,
      showLeadingAction: !AppStrings.isSingleVendorMode,
      elevation: 0,
      title: widget.vendorType.name,
      appBarColor: context.theme.colorScheme.surface,
      appBarItemColor: AppColor.primaryColor,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          SafeArea(
            child: GoogleMap(
              initialCameraPosition: taxiController.mapCameraPosition,
              onMapCreated:
                  (controller) =>
                      taxiController.onMapCreated(controller, context),
              padding: taxiState.googleMapPadding,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              markers: taxiState.gMapMarkers,
              polylines: taxiState.gMapPolylines,
              style: taxiState.mapStyle,
            ),
          ),
          Visibility(
            visible: !AppStrings.isSingleVendorMode,
            child: CustomLeading(
              padding: 10,
              size: 24,
              color: AppColor.primaryColor,
              bgColor: Utils.textColorByTheme(),
            ).safeArea().positioned(
              top: 0,
              left: !Utils.isArabic ? 20 : null,
              right: Utils.isArabic ? 20 : null,
            ),
          ),
          UnSupportedTaxiLocationView(vendorType: widget.vendorType),
          NewTaxiOrderLocationEntryView(vendorType: widget.vendorType),
          NewTaxiOrderSummaryView(vendorType: widget.vendorType),
          Visibility(
            visible: taxiState.currentOrderStep == 3,
            child: TripDriverSearch(vendorType: widget.vendorType),
          ),
          Visibility(
            visible: taxiState.currentOrderStep == 4,
            child: TaxiTripReadyView(vendorType: widget.vendorType),
          ),
          if (taxiState.currentOrderStep == 6)
            TaxiRateDriverView(vendorType: widget.vendorType),
        ],
      ),
    );
  }
}
