import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/pages/parcel/parcel_vendor_details.page.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/pages/vendor_details/widgets/vendor_plain_details.view.dart';
import 'package:fuodz/pages/vendor_details/widgets/vendor_with_menu.view.dart';
import 'package:fuodz/providers/vendor_details_providers.dart';

class VendorDetailsPage extends ConsumerStatefulWidget {
  const VendorDetailsPage({required this.vendor, super.key});

  final Vendor vendor;

  @override
  ConsumerState<VendorDetailsPage> createState() => _VendorDetailsPageState();
}

class _VendorDetailsPageState extends ConsumerState<VendorDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.vendor.isParcelType) {
        context.replaceRoute(
          '/_w',
          extra: ParcelVendorDetailsPage(vendor: widget.vendor),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncVendor =
        ref.watch(vendorDetailsControllerProvider(widget.vendor.id));
    final detail = asyncVendor.valueOrNull ?? widget.vendor;
    return (!detail.hasSubcategories && !detail.isServiceType)
        ? VendorDetailsWithMenuPage(vendor: detail)
        : VendorPlainDetailsView(detail);
  }
}
