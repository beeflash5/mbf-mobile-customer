import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/input/search_bar.input2.dart';
import 'package:fuodz/utils/extensions/context.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class SearchHeader extends StatelessWidget {
  const SearchHeader({
    super.key,
    required this.searchTEC,
    required this.onSubmitted,
    required this.onFilterPressed,
    this.subtitle,
    this.showCancel = true,
  });

  final TextEditingController searchTEC;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onFilterPressed;
  final bool showCancel;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return VStack([
      HStack([
        VStack([
          "Search".tr().text.semiBold.xl2.make(),
          Visibility(visible: subtitle != null, child: "$subtitle".text.make()),
          Visibility(
            visible: subtitle == null,
            child: "Ordered by Nearby first".tr().text.make(),
          ),
        ]).expand(),
        showCancel
            ? Icon(Icons.close).p4().onInkTap(context.pop)
            : UiSpacer.emptySpace(),
      ]).pOnly(bottom: 10),
      SearchBarInput2(
        readOnly: false,
        showFilter: true,
        searchTEC: searchTEC,
        onSubmitted: onSubmitted,
        onFilterPressed: onFilterPressed,
      ),
    ]);
  }
}
