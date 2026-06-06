import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/busy_indicator.dart';
import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/providers/wallet_providers.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/wallet.helper.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/app_ui_settings.dart';
import 'package:fuodz/utils/extensions/string.dart';
import 'package:fuodz/utils/sizes.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';

class WalletManagementView extends ConsumerWidget {
  const WalletManagementView({
    super.key,
    this.padding,
    this.breif = true,
  });

  final EdgeInsetsGeometry? padding;
  final bool breif;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bgColor = context.cardColor;
    final textColor = Utils.textColorByColor(bgColor);
    final asyncState = ref.watch(walletControllerProvider);
    final wallet = asyncState.valueOrNull?.wallet;
    final isLoading = asyncState.isLoading;

    return Padding(
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: StreamBuilder(
        stream: AuthServices.listenToAuthState(),
        builder: (ctx, snapshot) {
          if (!snapshot.hasData) return UiSpacer.emptySpace();

          if (!breif) {
            return VStack([
              Visibility(visible: isLoading, child: BusyIndicator()),
              VStack([
                "${AppStrings.currencySymbol} ${wallet != null ? wallet.balance : 0.00}"
                    .currencyFormat()
                    .text
                    .color(textColor)
                    .xl3
                    .semiBold
                    .makeCentered(),
                UiSpacer.verticalSpace(space: 5),
                "Wallet Balance".tr().text.color(textColor).makeCentered(),
              ]),
              UiSpacer.vSpace(10),
              Visibility(
                visible: !isLoading,
                child: HStack([
                  if (AppUISettings.allowWalletTransfer)
                    CustomButton(
                      shapeRadius: Sizes.radiusSmall,
                      onPressed: () =>
                          WalletHelper.showWalletTransferEntry(context, ref),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: VStack([
                          Icon(
                            HugeIcons.strokeRoundedMoneySend01,
                            color: Utils.textColorByPrimaryColor(),
                            size: Sizes.fontSizeExtraLarge,
                          ),
                          "Send"
                              .tr()
                              .text
                              .size(Sizes.fontSizeExtraSmall)
                              .color(Utils.textColorByPrimaryColor())
                              .make(),
                        ],
                            crossAlignment: CrossAxisAlignment.center,
                            alignment: MainAxisAlignment.center,
                            spacing: 1).py(0),
                      ),
                    ).expand(flex: 2),
                  CustomButton(
                    shapeRadius: Sizes.radiusSmall,
                    onPressed: () => WalletHelper.showAmountEntry(context, ref),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: VStack([
                        Icon(
                          HugeIcons.strokeRoundedMoneyAdd01,
                          color: Utils.textColorByPrimaryColor(),
                          size: Sizes.fontSizeExtraLarge,
                        ),
                        "Top Up"
                            .tr()
                            .text
                            .size(Sizes.fontSizeExtraSmall)
                            .color(Utils.textColorByPrimaryColor())
                            .make(),
                      ],
                          crossAlignment: CrossAxisAlignment.center,
                          alignment: MainAxisAlignment.center,
                          spacing: 1).py(0),
                    ),
                  ).expand(flex: 3),
                  if (AppUISettings.allowWalletTransfer)
                    CustomButton(
                      shapeRadius: Sizes.radiusSmall,
                      onPressed: () =>
                          WalletHelper.showMyWalletAddress(context, ref),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: VStack([
                          Icon(
                            HugeIcons.strokeRoundedMoneyReceive01,
                            color: Utils.textColorByPrimaryColor(),
                            size: Sizes.fontSizeExtraLarge,
                          ),
                          "Receive"
                              .tr()
                              .text
                              .size(Sizes.fontSizeExtraSmall)
                              .color(Utils.textColorByPrimaryColor())
                              .make(),
                        ],
                            crossAlignment: CrossAxisAlignment.center,
                            alignment: MainAxisAlignment.center,
                            spacing: 1).py(0),
                      ),
                    ).expand(flex: 2),
                ],
                    spacing: 10,
                    alignment: MainAxisAlignment.center,
                    crossAlignment: CrossAxisAlignment.center),
              ),
            ],
                alignment: MainAxisAlignment.center,
                crossAlignment: CrossAxisAlignment.center)
                .p12()
                .box
                .shadowXs
                .color(bgColor)
                .withRounded(value: Sizes.radiusSmall)
                .make()
                .wFull(context);
          }

          return VStack([
            HStack([
              if (isLoading) BusyIndicator(),
              VStack([
                "${AppStrings.currencySymbol} ${wallet != null ? wallet.balance : 0.00}"
                    .currencyFormat()
                    .text
                    .color(textColor)
                    .xl3
                    .semiBold
                    .make(),
                2.heightBox,
                "Wallet Balance".tr().text.color(textColor).make(),
              ],
                  crossAlignment: CrossAxisAlignment.start,
                  alignment: MainAxisAlignment.start).expand(),
              CustomButton(
                shapeRadius: 12,
                onPressed: () => WalletHelper.showAmountEntry(context, ref),
                padding: const EdgeInsets.all(2),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: HStack([
                    Icon(
                      HugeIcons.strokeRoundedMoneyAdd01,
                      color: Utils.textColorByPrimaryColor(),
                    ),
                  ],
                      crossAlignment: CrossAxisAlignment.center,
                      alignment: MainAxisAlignment.center,
                      spacing: 6),
                ),
              ),
            ], spacing: 20),
            "Tap for more info/action"
                .tr()
                .text
                .color(textColor)
                .sm
                .makeCentered(),
          ], spacing: 3)
              .p12()
              .box
              .shadowXs
              .color(bgColor)
              .withRounded(value: Sizes.radiusSmall)
              .make()
              .wFull(context)
              .onInkTap(() => context.pushRoute('/wallet'));
        },
      ),
    );
  }
}
