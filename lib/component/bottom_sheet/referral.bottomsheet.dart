import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/models/user.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_images.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/extensions/dynamic.dart';
import 'package:fuodz/utils/extensions/string.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';

class ReferralBottomsheet extends StatelessWidget {
  const ReferralBottomsheet(this.user, {super.key});

  final User user;

  void _shareReferralCode() {
    Share.share(
      "%s is inviting you to join %s via this referral code: %s".tr().fill([
            user.name,
            AppStrings.appName,
            user.code,
          ]) +
          "\n" +
          AppStrings.androidDownloadLink +
          "\n" +
          AppStrings.iOSDownloadLink +
          "\n",
    );
  }

  @override
  Widget build(BuildContext context) {
    return VStack([
      Image.asset(
        AppImages.refer,
        width: context.percentWidth * 60,
      ),
      "Share this code with your family and friends and you could earn %s when they completed their first order"
          .tr()
          .fill([
            "${AppStrings.currencySymbol} ${AppStrings.referAmount}"
                .currencyFormat(),
          ])
          .text
          .center
          .makeCentered(),
      UiSpacer.verticalSpace(),
      UiSpacer.verticalSpace(),
      HStack([
        "${user.code}"
            .text
            .semiBold
            .make()
            .px32()
            .py12()
            .box
            .color(Vx.gray200)
            .make(),
        "Share"
            .tr()
            .text
            .color(Utils.isDark(AppColor.primaryColor)
                ? Colors.white
                : Colors.black)
            .make()
            .box
            .p12
            .color(AppColor.primaryColor)
            .make()
            .material()
            .onInkTap(_shareReferralCode),
      ]).box.roundedSM.clip(Clip.antiAlias).make().centered(),
    ])
        .p20()
        .scrollVertical()
        .hThreeForth(context)
        .box
        .color(context.theme.colorScheme.surface)
        .topRounded()
        .make();
  }
}
