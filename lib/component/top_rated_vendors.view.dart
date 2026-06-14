import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/busy_indicator.dart';
import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/list/top_rated_vendor.list_item.dart';
import 'package:fuodz/component/states/vendor.empty.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/pages/vendor_details/vendor_details.page.dart';
import 'package:fuodz/providers/vendor_lists_providers.dart';

class TopRatedVendors extends ConsumerWidget {
  const TopRatedVendors(this.vendorType, {super.key});

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
        child:
            VStack([
              "Top Rated".tr().text.lg.medium.make().p12(),
              CustomListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                dataSet: vendors,
                isLoading: asyncVendors.isLoading,
                itemBuilder: (context, index) {
                  final vendor = vendors[index];
                  return TopRatedVendorListItem(
                    vendor: vendor,
                    onPressed:
                        (v) => context.pushWidget(VendorDetailsPage(vendor: v)),
                  );
                },
                emptyWidget: EmptyVendor(),
              ).h(vendors.isEmpty ? 220 : 140),
            ]).py12(),
      ),
    ]);
  }
}
