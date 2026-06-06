import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/button/custom_outline_button.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/services/share.helper.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/utils.dart';

class ShareButton extends StatelessWidget {
  const ShareButton({
    super.key,
    this.product,
    this.vendor,
    this.service,
    this.child,
  });

  final Product? product;
  final Vendor? vendor;
  final Service? service;
  final Widget? child;

  Future<void> _onTap() async {
    if (product != null) return ShareHelper.shareProduct(product!);
    if (vendor != null) return ShareHelper.shareVendor(vendor!);
    if (service != null) return ShareHelper.shareService(service!);
  }

  @override
  Widget build(BuildContext context) {
    if (child != null) {
      return child!.onTap(_onTap);
    }
    return CustomOutlineButton(
      color: Colors.transparent,
      child: Icon(
        Icons.share,
        color: AppColor.primaryColorDark,
      ),
      onPressed: _onTap,
    ).p2().box.color(Utils.textColorByTheme()).roundedFull.make();
  }
}
