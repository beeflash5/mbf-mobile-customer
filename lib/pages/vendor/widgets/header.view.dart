import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/bottom_sheet/delivery_address_picker.bottomsheet.dart';
import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/models/search.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/pages/search/search.page.dart';
import 'package:fuodz/providers/location_providers.dart';

class VendorHeader extends ConsumerStatefulWidget {
  const VendorHeader({
    super.key,
    this.vendorType,
    this.showSearch = true,
    this.bottomPadding = true,
    required this.onrefresh,
  });

  final VendorType? vendorType;
  final bool showSearch;
  final bool bottomPadding;
  final Function onrefresh;

  @override
  ConsumerState<VendorHeader> createState() => _VendorHeaderState();
}

class _VendorHeaderState extends ConsumerState<VendorHeader> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cur = ref.read(currentDeliveryAddressControllerProvider).valueOrNull;
      if (cur == null) {
        ref
            .read(currentDeliveryAddressControllerProvider.notifier)
            .fetchCurrentLocation();
      }
    });
  }

  void _openPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DeliveryAddressPicker(
        vendorCheckRequired: false,
        onSelectDeliveryAddress: (addr) {
          ref
              .read(currentDeliveryAddressControllerProvider.notifier)
              .setAddress(addr);
          Navigator.of(context).pop();
          widget.onrefresh();
        },
      ),
    );
  }

  void _openSearch() {
    final search = Search(
      vendorType: widget.vendorType,
      showProductsTag: true,
    );
    context.pushWidget(SearchPage(search: search));
  }

  @override
  Widget build(BuildContext context) {
    final asyncAddr = ref.watch(currentDeliveryAddressControllerProvider);
    final address = asyncAddr.valueOrNull;

    return HStack([
      HStack([
        const Icon(Icons.location_on, size: 24).onInkTap(() {
          ref
              .read(currentDeliveryAddressControllerProvider.notifier)
              .useUserLocation();
        }),
        VStack([
          HStack([
            "Delivery Location".tr().text.sm.semiBold.make(),
            const Icon(Icons.keyboard_arrow_down).px4(),
          ]),
          "${address?.address ?? ''}".text.maxLines(1).ellipsis.base.make(),
        ]).onInkTap(_openPicker).px12().expand(),
      ]).expand(),
      CustomVisibilty(
        visible: widget.showSearch,
        child: const Icon(Icons.search, size: 20)
            .p8()
            .onInkTap(_openSearch)
            .box
            .roundedSM
            .clip(Clip.antiAlias)
            .color(context.theme.colorScheme.surface)
            .outerShadowSm
            .make(),
      ),
    ])
        .p12()
        .box
        .color(context.theme.colorScheme.surface)
        .bottomRounded()
        .outerShadowSm
        .make()
        .pOnly(bottom: widget.bottomPadding ? Vx.dp20 : 0);
  }
}
