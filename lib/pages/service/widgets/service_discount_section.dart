import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/custom_text_form_field.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class ServiceDiscountSection extends StatefulWidget {
  const ServiceDiscountSection({
    super.key,
    required this.couponController,
    required this.canApply,
    required this.applying,
    required this.onChanged,
    required this.onApply,
    this.errorText,
    this.toggle = false,
  });

  final TextEditingController couponController;
  final bool canApply;
  final bool applying;
  final ValueChanged<String> onChanged;
  final VoidCallback onApply;
  final String? errorText;
  final bool toggle;

  @override
  State<ServiceDiscountSection> createState() => _ServiceDiscountSectionState();
}

class _ServiceDiscountSectionState extends State<ServiceDiscountSection> {
  bool show = true;

  @override
  void initState() {
    super.initState();
    if (widget.toggle) show = false;
  }

  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        HStack(
          [
            "Add Coupon".tr().text.semiBold.xl.make().expand(),
            widget.toggle
                ? Icon(
                    show ? Icons.close : Icons.add,
                    color: AppColor.primaryColor,
                  ).onInkTap(() {
                    setState(() => show = !show);
                  })
                : UiSpacer.emptySpace(),
          ],
        ),
        UiSpacer.verticalSpace(space: 10),
        Visibility(
          visible: show,
          child: HStack(
            [
              CustomTextFormField(
                hintText: "Coupon Code".tr(),
                textEditingController: widget.couponController,
                errorText: widget.errorText,
                onChanged: widget.onChanged,
              ).expand(flex: 2),
              UiSpacer.horizontalSpace(),
              Column(
                children: [
                  CustomButton(
                    title: "Apply".tr(),
                    isFixedHeight: true,
                    loading: widget.applying,
                    onPressed: widget.canApply ? widget.onApply : null,
                  ).h(Vx.dp56),
                  widget.errorText != null
                      ? UiSpacer.verticalSpace(space: 12)
                      : UiSpacer.verticalSpace(space: 1),
                ],
              ).expand(),
            ],
          ),
        ),
      ],
    );
  }
}
