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

class TopVendors extends ConsumerStatefulWidget {
  const TopVendors(
    this.vendorType, {
    this.scrollDirection = Axis.horizontal,
    this.noScrollPhysics = true,
    super.key,
  });

  final VendorType vendorType;
  final Axis scrollDirection;
  final bool noScrollPhysics;

  @override
  ConsumerState<TopVendors> createState() => _TopVendorsState();
}

class _TopVendorsState extends ConsumerState<TopVendors> {
  int _selectedType = 1;

  @override
  Widget build(BuildContext context) {
    final args = (
      vendorTypeId: widget.vendorType.id,
      selectedType: _selectedType,
      enableFilter: true,
      type: '',
    );
    final asyncVendors = ref.watch(topVendorsControllerProvider(args));
    final vendors = asyncVendors.valueOrNull ?? const [];

    return VStack([
      HStack([
        "Top Vendors".tr().text.xl.semiBold.make().expand(),
        CustomButton(
          title: "Delivery".tr(),
          titleStyle: context.textTheme.bodyLarge!.copyWith(
            fontSize: 12,
            color: Colors.white,
          ),
          onPressed: () => setState(() => _selectedType = 1),
          color:
              _selectedType == 1 ? AppColor.primaryColor : Colors.grey.shade600,
        ).h(32).px8(),
        CustomButton(
          title: "Pickup".tr(),
          titleStyle: context.textTheme.bodyLarge!.copyWith(
            fontSize: 12,
            color: Colors.white,
          ),
          color:
              _selectedType == 2 ? AppColor.primaryColor : Colors.grey.shade600,
          onPressed: () => setState(() => _selectedType = 2),
        ),
      ]).h(32).p12(),
      CustomVisibilty(
        visible: widget.scrollDirection == Axis.horizontal,
        child: CustomListView(
          scrollDirection: widget.scrollDirection,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          dataSet: vendors,
          isLoading: asyncVendors.isLoading,
          itemBuilder: (context, index) {
            final vendor = vendors[index];
            return VendorListItem(
              vendor: vendor,
              onPressed:
                  (v) => context.pushWidget(VendorDetailsPage(vendor: v)),
            );
          },
          emptyWidget: EmptyVendor(),
        ).h(195),
      ),
      CustomVisibilty(
        visible: widget.scrollDirection != Axis.horizontal,
        child: CustomListView(
          scrollDirection: widget.scrollDirection,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          dataSet: vendors,
          isLoading: asyncVendors.isLoading,
          noScrollPhysics: widget.noScrollPhysics,
          itemBuilder: (context, index) {
            final vendor = vendors[index];
            return VendorListItem(
              vendor: vendor,
              onPressed:
                  (v) => context.pushWidget(VendorDetailsPage(vendor: v)),
            );
          },
          emptyWidget: EmptyVendor(),
        ),
      ),
    ]).py12();
  }
}
