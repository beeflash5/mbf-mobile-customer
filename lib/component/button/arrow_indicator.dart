import 'package:flutter/material.dart';
import 'package:fuodz/utils/utils.dart';

class ArrowIndicator extends StatelessWidget {
  const ArrowIndicator({this.size, this.color, this.leading = false, Key? key})
    : super(key: key);

  final double? size;
  final Color? color;
  final bool leading;
  @override
  Widget build(BuildContext context) {
    IconData? iconData;
    if (leading) {
      iconData =
          !Utils.isArabic
              ? Icons.keyboard_arrow_left
              : Icons.keyboard_arrow_right;
    } else {
      iconData =
          Utils.isArabic
              ? Icons.keyboard_arrow_left
              : Icons.keyboard_arrow_right;
    }
    return Icon(iconData, size: size ?? 32, color: color);
  }
}
