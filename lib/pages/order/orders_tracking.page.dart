import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/custom_image.view.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/providers/order_tracking_providers.dart';
import 'package:fuodz/services/location.service.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_ui_settings.dart';

class OrderTrackingPage extends ConsumerWidget {
  const OrderTrackingPage({required this.order, super.key});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(orderTrackingControllerProvider(order));
    final notifier = ref.read(orderTrackingControllerProvider(order).notifier);
    final state = asyncState.valueOrNull;
    final markers = state?.mapMarkers ?? const <Marker>{};
    final polylines = state?.polylines ?? const <PolylineId, Polyline>{};

    return BasePage(
      title: "Order Tracking".tr(),
      showAppBar: true,
      showLeadingAction: true,
      isLoading: asyncState.isLoading,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                LocationService.currenctAddress?.coordinates?.latitude ?? 0.0,
                LocationService.currenctAddress?.coordinates?.longitude ?? 0.0,
              ),
              zoom: 15,
            ),
            padding: EdgeInsets.only(bottom: Vx.dp64 * 2),
            myLocationEnabled: true,
            markers: markers,
            polylines: Set<Polyline>.of(polylines.values),
            onMapCreated: notifier.setMapController,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: HStack([
                CustomImage(imageUrl: order.driver!.photo)
                    .wh(Vx.dp56, Vx.dp56)
                    .box
                    .roundedFull
                    .shadowXs
                    .clip(Clip.antiAlias)
                    .make(),
                VStack([
                  order.driver!.name.text.xl.semiBold.make(),
                  order.driver!.phone.text.make(),
                ]).px12().expand(),
                Visibility(
                  visible: AppUISettings.canCallDriver,
                  child: CustomButton(
                    icon: Icons.phone,
                    iconColor: Colors.white,
                    title: "",
                    color: AppColor.primaryColor,
                    shapeRadius: Vx.dp24,
                    onPressed: notifier.callDriver,
                  ).wh(Vx.dp64, Vx.dp40).p12(),
                ),
              ])
                  .p12()
                  .box
                  .color(context.theme.colorScheme.surface)
                  .roundedSM
                  .shadowXl
                  .outerShadow3Xl
                  .make()
                  .wFull(context)
                  .h(Vx.dp64 * 1.3)
                  .p12(),
            ),
          ),
        ],
      ),
    );
  }
}
