import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/custom_grid_view.dart';
import 'package:fuodz/component/custom_image.view.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class OrderAttachmentView extends StatelessWidget {
  const OrderAttachmentView({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final attachments = order.attachments;
    if (attachments == null || attachments.isEmpty) return 0.heightBox;
    return VStack(
      [
        "Attachments".tr().text.xl.semiBold.make(),
        UiSpacer.vSpace(10),
        CustomGridView(
          dataSet: attachments,
          noScrollPhysics: true,
          itemBuilder: (ctx, index) {
            final attachment = attachments[index];
            return Column(
              children: [
                CustomImage(
                  imageUrl: attachment.link!,
                  canZoom: true,
                  width: double.infinity,
                  height: ctx.percentHeight * 14,
                  boxFit: BoxFit.contain,
                ),
                "${index + 1}".text.make().py2(),
              ],
            );
          },
        ),
      ],
    ).p8().p12();
  }
}
