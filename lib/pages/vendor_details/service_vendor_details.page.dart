import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/custom_masonry_grid_view.dart';
import 'package:fuodz/component/list/home_services.list_item.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/pages/service/service_details.page.dart';
import 'package:fuodz/pages/vendor_details/widgets/vendor_details_header.view.dart';
import 'package:fuodz/providers/service_vendor_details_providers.dart';

class ServiceVendorDetailsPage extends ConsumerWidget {
  const ServiceVendorDetailsPage({required this.vendor, super.key});

  final Vendor vendor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncServices =
        ref.watch(serviceVendorDetailsControllerProvider(vendor.id));
    final services = asyncServices.valueOrNull ?? const [];

    return VStack([
      VendorDetailsHeader(vendor),
      CustomMasonryGridView(
        isLoading: asyncServices.isLoading,
        crossAxisSpacing: 10,
        mainAxisSpacing: 20,
        childAspectRatio: 1.1,
        items: services
            .map(
              (service) => HomeServicesListItem(
                height: 290,
                width: 170,
                service: service,
                onPressed: (s) => context.pushWidget(ServiceDetailsPage(s)),
              ),
            )
            .toList(),
      ).p20(),
    ]).scrollVertical().expand();
  }
}
