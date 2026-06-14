import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/utils/utils.dart';

class AddToCartButton extends StatelessWidget {
  const AddToCartButton({
    super.key,
    required this.onPressed,
    this.loading = false,
  });

  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      loading: loading,
      child:
          "Add to cart"
              .tr()
              .text
              .color(Utils.textColorByTheme())
              .semiBold
              .make()
              .p12(),
      onPressed: onPressed,
    );
  }
}
