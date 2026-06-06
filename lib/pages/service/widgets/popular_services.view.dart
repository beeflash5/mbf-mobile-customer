import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/button/custom_text_button.dart';
import 'package:fuodz/component/list/service.gridview_item.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/pages/service/service_details.page.dart';
import 'package:fuodz/providers/vendor_sections_providers.dart';
import 'package:fuodz/services/navigation.service.dart';
import 'package:fuodz/utils/app_strings.dart';

class PopularServicesView extends ConsumerStatefulWidget {
  const PopularServicesView(this.vendorType, {super.key});

  final VendorType vendorType;

  @override
  ConsumerState<PopularServicesView> createState() =>
      _PopularServicesViewState();
}

class _PopularServicesViewState extends ConsumerState<PopularServicesView> {
  bool showGrid = true;

  @override
  Widget build(BuildContext context) {
    final vendorTypeId = widget.vendorType.id;
    final asyncServices =
        ref.watch(popularServicesControllerProvider(vendorTypeId));
    final services = asyncServices.valueOrNull ?? const [];
    final isLoading = asyncServices.isLoading;

    if (!isLoading && services.isEmpty) return const SizedBox.shrink();

    return VStack([
      HStack([
        ("Popular".tr() + " ${widget.vendorType.name}")
            .text
            .xl
            .bold
            .make()
            .expand(),
        CustomTextButton(
          title: "See all".tr(),
          onPressed: () => NavigationService.openServiceSearch(
            context,
            byLocation: AppStrings.enableFatchByLocation,
            vendorType: widget.vendorType,
            showServices: true,
            showVendors: false,
          ),
        ),
      ], spacing: 20).px12(),
      Builder(builder: (context) {
        const double spacing = 20;
        final double eachWidth = (context.screenWidth - (spacing * 2)) / 2;
        final List<Widget> children = services.map((service) {
          return ServiceGridViewItem(
            service: service,
            onPressed: (s) => context.pushWidget(ServiceDetailsPage(s)),
          ).w(eachWidth);
        }).toList();
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
    ]);
  }
}
