import 'package:flutter/material.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/models/payment_method.dart';
import 'package:fuodz/component/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class PaymentOptionListItem extends StatelessWidget {
  const PaymentOptionListItem(
    this.paymentMethod, {
    this.selected = false,
    Key? key,
    required this.onSelected,
  }) : super(key: key);

  final bool selected;
  final PaymentMethod paymentMethod;
  final Function(PaymentMethod) onSelected;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        HStack(
          [
            //
            CustomImage(
              imageUrl: paymentMethod.photo,
              width: Vx.dp48,
              height: Vx.dp48,
              boxFit: BoxFit.contain,
            ).px4().py8(),

            //
            paymentMethod.name.text.medium.lg.make().expand(),

            40.widthBox,
          ],
        )
            .box
            .roundedSM
            .border(
              color: selected
                  ? AppColor.primaryColor
                  : context.textTheme.bodyLarge!.color!.withOpacity(0.20),
              width: selected ? 2 : 1,
            )
            .make(),

        /// CHECK ICON
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: selected
                    ? AppColor.primaryColor
                    : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor.primaryColor,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ],
    ).onInkTap(
      () => onSelected(paymentMethod),
    );
  }
}