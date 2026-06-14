import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:measure_size/measure_size.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/busy_indicator.dart';
import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/models/address.dart';
import 'package:fuodz/providers/ops_map_providers.dart';
import 'package:fuodz/utils/extensions/context.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class OPSMapPage extends ConsumerStatefulWidget {
  const OPSMapPage({
    this.useCurrentLocation,
    this.region,
    this.initialPosition,
    this.initialZoom = 10,
    super.key,
  });

  final bool? useCurrentLocation;
  final String? region;
  final LatLng? initialPosition;
  final double initialZoom;

  @override
  ConsumerState<OPSMapPage> createState() => _OPSMapPageState();
}

class _OPSMapPageState extends ConsumerState<OPSMapPage> {
  final TextEditingController _searchTEC = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(opsMapControllerProvider.notifier)
          .mapCameraMove(
            CameraPosition(
              target: widget.initialPosition ?? const LatLng(0.0, 0.0),
              zoom: widget.initialZoom,
            ),
          );
    });
  }

  @override
  void dispose() {
    _searchTEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(opsMapControllerProvider);
    final notifier = ref.read(opsMapControllerProvider.notifier);
    return BasePage(
      body: SafeArea(
        child: VStack([
          HStack([
            Icon(Icons.arrow_back).p2().onInkTap(() {
              context.pop();
            }),
            UiSpacer.horizontalSpace(),
            TypeAheadField<Address>(
              retainOnLoading: false,
              hideWithKeyboard: false,
              controller: _searchTEC,
              builder: (context, controller, focusNode) {
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(hintText: 'Search address'.tr()),
                );
              },
              debounceDuration: const Duration(milliseconds: 900),
              suggestionsCallback: (keyword) => notifier.fetchPlaces(keyword),
              itemBuilder:
                  (context, suggestion) => ListTile(
                    title:
                        "${suggestion.featureName}".text.base.semiBold.make(),
                    subtitle: "${suggestion.addressLine}".text.sm.make(),
                  ),
              onSelected: (address) {
                _searchTEC.clear();
                notifier.addressSelected(address);
              },
            ).expand(),
          ]).px20().py4().scrollVertical().centered().wFull(context).h(70),
          Stack(
            children: [
              GoogleMap(
                myLocationEnabled: widget.useCurrentLocation ?? true,
                myLocationButtonEnabled: widget.useCurrentLocation ?? true,
                initialCameraPosition: CameraPosition(
                  target: widget.initialPosition ?? const LatLng(0.0, 0.0),
                  zoom: widget.initialZoom,
                ),
                padding: state.googleMapPadding,
                onMapCreated: notifier.onMapCreated,
                onCameraMove: notifier.mapCameraMove,
                markers: Set<Marker>.of(state.gMarkers.values),
              ),
              Positioned(
                bottom: 30,
                left: 30,
                right: 30,
                child: CustomVisibilty(
                  visible: state.isBusy,
                  child: BusyIndicator().centered().p32(),
                ),
              ),
              Positioned(
                bottom: 30,
                left: 30,
                right: 30,
                child: CustomVisibilty(
                  visible: state.selectedAddress != null,
                  child: MeasureSize(
                    onChange: notifier.updateMapPadding,
                    child:
                        VStack([
                              "${state.selectedAddress?.featureName}"
                                  .text
                                  .semiBold
                                  .center
                                  .xl
                                  .maxLines(3)
                                  .overflow(TextOverflow.ellipsis)
                                  .make(),
                              UiSpacer.verticalSpace(space: 5),
                              "${state.selectedAddress?.addressLine}"
                                  .text
                                  .light
                                  .center
                                  .sm
                                  .maxLines(2)
                                  .overflow(TextOverflow.ellipsis)
                                  .make(),
                              UiSpacer.verticalSpace(),
                              CustomButton(
                                title: "Select".tr(),
                                onPressed:
                                    () => context.pop(state.selectedAddress),
                              ),
                            ]).box.shadow2xl
                            .color(context.theme.colorScheme.surface)
                            .p20
                            .make(),
                  ),
                ),
              ),
            ],
          ).expand(),
        ]),
      ),
    );
  }
}
