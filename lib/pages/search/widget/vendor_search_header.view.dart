import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/pages/search/widget/search_type.tag.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class VendorSearchHeaderview extends StatefulWidget {
  const VendorSearchHeaderview({
    super.key,
    required this.selectedTagId,
    required this.onSelectTag,
    this.showProducts = false,
    this.showVendors = false,
    this.showProviders = false,
    this.showServices = false,
    this.padding = 12.0,
    this.defaultIndex,
  });

  final int selectedTagId;
  final ValueChanged<int> onSelectTag;
  final bool showVendors;
  final bool showProviders;
  final bool showProducts;
  final bool showServices;
  final double padding;
  final int? defaultIndex;

  @override
  State<VendorSearchHeaderview> createState() => _VendorSearchHeaderviewState();
}

class _VendorSearchHeaderviewState extends State<VendorSearchHeaderview> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.defaultIndex != null) {
        widget.onSelectTag(widget.defaultIndex!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return HStack([
      if (widget.showServices)
        SearchTypeTag(
          title: "Services".tr(),
          onPressed: () => widget.onSelectTag(3),
          selected: widget.selectedTagId == 3,
        ),
      if (widget.showProducts)
        SearchTypeTag(
          title: "Products".tr(),
          onPressed: () => widget.onSelectTag(2),
          selected: widget.selectedTagId == 2,
        ),
      if (widget.showVendors)
        SearchTypeTag(
          title: "Vendors".tr(),
          onPressed: () => widget.onSelectTag(1),
          selected: widget.selectedTagId == 1,
        ),
      if (widget.showProviders)
        SearchTypeTag(
          title: "Providers".tr(),
          onPressed: () => widget.onSelectTag(1),
          selected: widget.selectedTagId == 1,
        ),
      UiSpacer.horizontalSpace().expand(),
    ]).py(widget.padding);
  }
}
