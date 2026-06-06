import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/busy_indicator.dart';
import 'package:fuodz/component/list/top_service_vendor.hz.list_item.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/pages/vendor_details/vendor_details.page.dart';
import 'package:fuodz/providers/vendor_lists_providers.dart';

class TopServiceVendors extends ConsumerWidget {
  const TopServiceVendors(this.vendorType, {super.key});

  final VendorType vendorType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = (
      vendorTypeId: vendorType.id,
      selectedType: 0,
      enableFilter: false,
      type: 'rated',
    );
    final asyncVendors = ref.watch(topVendorsControllerProvider(args));
    final vendors = asyncVendors.valueOrNull ?? const [];

    return VStack([
      Visibility(
        visible: asyncVendors.isLoading,
        child: BusyIndicator().centered(),
      ),
      Visibility(
        visible: vendors.isNotEmpty,
        child: VStack([
          "Top Rated Providers".tr().text.xl.bold.make().px20(),
          12.heightBox,
          Builder(builder: (context) {
            const double spacing = 20;
            final double eachWidth =
                (context.screenWidth - (spacing * 2)) / 1.15;
            final List<Widget> children = vendors
                .map(
                  (vendor) => TopServiceVendorHorizontalListItem(
                    vendor: vendor,
                    onPressed: (v) => context.pushWidget(VendorDetailsPage(vendor: v)),
                  ).w(eachWidth),
                )
                .toList();
            children.insert(0, 0.widthBox);
            children.add(0.widthBox);
            return Scrollbar(
              thumbVisibility: false,
              trackVisibility: false,
              interactive: true,
              child: HStack(
                children,
                spacing: spacing,
                axisSize: MainAxisSize.min,
                alignment: MainAxisAlignment.start,
                crossAlignment: CrossAxisAlignment.start,
              ).scrollHorizontal(physics: const BouncingScrollPhysics()),
            );
          }),
        ]),
      ),
    ]);
  }
}
