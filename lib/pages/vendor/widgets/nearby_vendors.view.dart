import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/list/vendor.list_item.dart';
import 'package:fuodz/component/states/vendor.empty.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/pages/vendor_details/vendor_details.page.dart';
import 'package:fuodz/providers/vendor_lists_providers.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_strings.dart';

class NearByVendors extends ConsumerStatefulWidget {
  const NearByVendors(this.vendorType, {super.key});

  final VendorType vendorType;

  @override
  ConsumerState<NearByVendors> createState() => _NearByVendorsState();
}

class _NearByVendorsState extends ConsumerState<NearByVendors> {
  int _selectedType = 1;

  @override
  Widget build(BuildContext context) {
    final args = (
      vendorTypeId: widget.vendorType.id,
      selectedType: _selectedType,
    );
    final asyncVendors = ref.watch(nearbyVendorsControllerProvider(args));
    final vendors = asyncVendors.valueOrNull ?? const [];

    return CustomVisibilty(
      visible: !AppStrings.enableSingleVendor,
      child: VStack([
        HStack([
          "Nearby Vendors".tr().text.semiBold.lg.make().expand(),
          CustomButton(
            title: "Delivery".tr(),
            titleStyle: context.textTheme.bodyLarge!.copyWith(
              fontSize: 12,
              color: Colors.white,
            ),
            onPressed: () => setState(() => _selectedType = 1),
            color: _selectedType == 1
                ? AppColor.primaryColor
                : Colors.grey.shade600,
          ).h(32).px8(),
          CustomButton(
            title: "Pickup".tr(),
            titleStyle: context.textTheme.bodyLarge!.copyWith(
              fontSize: 12,
              color: Colors.white,
            ),
            color: _selectedType == 2
                ? AppColor.primaryColor
                : Colors.grey.shade600,
            onPressed: () => setState(() => _selectedType = 2),
          ).h(32),
        ]).p12(),
        CustomListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          dataSet: vendors,
          isLoading: asyncVendors.isLoading,
          itemBuilder: (context, index) {
            final vendor = vendors[index];
            return FittedBox(
              child: VendorListItem(
                vendor: vendor,
                onPressed: (v) => context.pushWidget(VendorDetailsPage(vendor: v)),
              ),
            );
          },
          emptyWidget: EmptyVendor(),
        ).h(vendors.isEmpty ? 240 : 195),
      ], spacing: 10),
    );
  }
}
