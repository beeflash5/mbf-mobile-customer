import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/busy_indicator.dart';
import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/providers/wallet_providers.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/wallet.helper.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/extensions/string.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';

class PlainWalletManagementView extends ConsumerWidget {
  const PlainWalletManagementView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bgColor = Colors.grey.shade300;
    final textColor = Utils.textColorByColor(bgColor);
    final asyncState = ref.watch(walletControllerProvider);
    final isLoading = asyncState.isLoading;
    final wallet = asyncState.valueOrNull?.wallet;

    return StreamBuilder(
      stream: AuthServices.listenToAuthState(),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) return UiSpacer.emptySpace();
        return VStack([
              Visibility(visible: isLoading, child: BusyIndicator()),
              HStack([
                VStack([
                  "Wallet Balance".tr().text.sm.medium.color(textColor).make(),
                  UiSpacer.vSpace(3),
                  "${AppStrings.currencySymbol} ${wallet != null ? wallet.balance : 0.00}"
                      .currencyFormat()
                      .text
                      .color(textColor)
                      .xl2
                      .extraBold
                      .make(),
                ]).expand(),
                UiSpacer.hSpace(10),
                Visibility(
                  visible: !isLoading,
                  child: VStack([
                    CustomButton(
                      shapeRadius: 12,
                      onPressed:
                          () => WalletHelper.showAmountEntry(context, ref),
                      child: HStack(
                        [
                          Icon(
                            Icons.add,
                            size: 16,
                            color: Utils.textColorByPrimaryColor(),
                          ),
                          UiSpacer.hSpace(5),
                          "Top-Up"
                              .tr()
                              .text
                              .sm
                              .color(Utils.textColorByPrimaryColor())
                              .make(),
                        ],
                        crossAlignment: CrossAxisAlignment.center,
                        alignment: MainAxisAlignment.center,
                      ),
                    ),
                  ]),
                ),
              ]),
              "Tap for more info/action"
                  .tr()
                  .text
                  .sm
                  .color(
                    Utils.textColorByColor(context.theme.colorScheme.surface),
                  )
                  .makeCentered(),
            ])
            .p(10)
            .box
            .shadowXl
            .color(context.theme.colorScheme.surface)
            .withRounded(value: 5)
            .make()
            .wFull(context)
            .onInkTap(() => context.pushRoute('/wallet'));
      },
    );
  }
}
