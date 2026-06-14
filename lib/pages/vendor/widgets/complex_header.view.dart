import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/bottom_sheet/delivery_address_picker.bottomsheet.dart';
import 'package:fuodz/providers/location_providers.dart';

class ComplexVendorHeader extends ConsumerWidget {
  const ComplexVendorHeader({
    super.key,
    required this.onrefresh,
    required this.onSearchPressed,
  });

  final Function onrefresh;
  final VoidCallback onSearchPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAddr = ref.watch(currentDeliveryAddressControllerProvider);
    final address = asyncAddr.valueOrNull;
    return HStack([
      Icon(Icons.location_on, size: 24).onInkTap(() {
        ref
            .read(currentDeliveryAddressControllerProvider.notifier)
            .useUserLocation();
      }),
      VStack([
            "Delivery Location".tr().text.lg.semiBold.make(),
            "${address?.address ?? '---'}".text.base.maxLines(1).make(),
          ])
          .onInkTap(() {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder:
                  (_) => DeliveryAddressPicker(
                    vendorCheckRequired: false,
                    onSelectDeliveryAddress: (addr) {
                      ref
                          .read(
                            currentDeliveryAddressControllerProvider.notifier,
                          )
                          .setAddress(addr);
                      Navigator.of(context).pop();
                      onrefresh();
                    },
                  ),
            );
          })
          .px12()
          .expand(),
      Icon(Icons.search, size: 24)
          .p8()
          .onInkTap(onSearchPressed)
          .box
          .roundedSM
          .clip(Clip.antiAlias)
          .color(context.theme.colorScheme.surface)
          .shadowXs
          .make(),
    ]).p8().px16().py8();
  }
}
