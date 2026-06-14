import 'package:flutter/material.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:fuodz/utils/app_colors.dart';

class CallButton extends StatelessWidget {
  const CallButton(this.vendor, {this.phone, this.size, Key? key})
    : super(key: key);

  final Vendor? vendor;
  final double? size;
  final String? phone;
  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.phone,
      size: size ?? 24,
      color: Colors.white,
    ).p8().box.color(AppColor.primaryColor).roundedFull.make().onInkTap(() {
      launchUrlString("tel://${vendor != null ? vendor?.phone : phone}");
    });
  }
}
