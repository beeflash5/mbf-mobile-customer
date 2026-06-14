import 'package:flutter/material.dart';
import 'package:fuodz/utils/utils.dart';

class DirectionalChevron extends StatelessWidget {
  const DirectionalChevron({this.size, this.color, Key? key}) : super(key: key);

  final double? size;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Icon(
      Utils.isArabic ? Icons.chevron_left : Icons.chevron_right,
      color: color ?? Colors.grey.shade500,
      size: size,
    );
  }
}
