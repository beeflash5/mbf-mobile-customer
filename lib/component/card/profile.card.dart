import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/bottom_sheet/referral.bottomsheet.dart';
import 'package:fuodz/component/busy_indicator.dart';
import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/component/menu_item.dart';
import 'package:fuodz/component/states/empty.state.dart';
import 'package:fuodz/providers/profile_providers.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/utils/app_finance_settings.dart';
import 'package:fuodz/utils/app_images.dart';
import 'package:fuodz/utils/app_routes.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/app_ui_settings.dart';
import 'package:fuodz/utils/extensions/dynamic.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class ProfileCard extends ConsumerWidget {
  const ProfileCard({super.key});

  void _shareReferralCode(String? name, String? code) {
    Share.share(
      "%s is inviting you to join %s via this referral code: %s".tr().fill([
            name ?? '',
            AppStrings.appName,
            code ?? '',
          ]) +
          "\n" +
          AppStrings.androidDownloadLink +
          "\n" +
          AppStrings.iOSDownloadLink +
          "\n",
    );
  }

  Future<void> _logoutPressed(BuildContext context, WidgetRef ref) async {
    AlertService.confirm(
      title: "Logout".tr(),
      text: "Are you sure you want to logout?".tr(),
      onConfirm: () async {
        AlertService.loading(
          title: "Logout".tr(),
          text: "Logging out Please wait...".tr(),
          barrierDismissible: false,
        );
        final result =
            await ref.read(profileControllerProvider.notifier).logout();
        if (!context.mounted) return;
        Navigator.of(context).pop();
        switch (result) {
          case LogoutSuccess():
            context.pushRoute('/splash');
            break;
          case LogoutFailure(:final message):
            AlertService.error(title: "Logout".tr(), text: message);
            break;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(profileControllerProvider);
    final state = asyncState.valueOrNull;
    final authed = state?.authenticated ?? false;
    final user = state?.currentUser;

    if (!authed) {
      return EmptyState(
        auth: true,
        showAction: true,
        actionPressed: () async {
          await context.pushRoute(AppRoutes.loginRoute);
          ref.read(profileControllerProvider.notifier).refresh();
        },
      ).py12();
    }

    return VStack([
      HStack([
            CachedNetworkImage(
              imageUrl: user?.photo ?? "",
              progressIndicatorBuilder:
                  (context, imageUrl, progress) => BusyIndicator(),
              errorWidget:
                  (context, imageUrl, progress) => Image.asset(AppImages.user),
            ).wh(Vx.dp64, Vx.dp64).box.roundedFull.clip(Clip.antiAlias).make(),
            VStack([
              (user?.name ?? '').text.xl.semiBold.make(),
              (user?.email ?? '').text.light.make(),
              AppStrings.enableReferSystem
                  ? "Share referral code"
                      .tr()
                      .text
                      .sm
                      .color(context.textTheme.bodyLarge!.color)
                      .make()
                      .box
                      .px4
                      .roundedSM
                      .border(color: Colors.grey)
                      .make()
                      .onInkTap(
                        () => _shareReferralCode(user?.name, user?.code),
                      )
                      .py4()
                  : UiSpacer.emptySpace(),
            ]).px20().expand(),
          ])
          .p12()
          .wFull(context)
          .box
          .border(color: Theme.of(context).cardColor)
          .color(Theme.of(context).cardColor)
          .shadowXs
          .roundedSM
          .make(),
      10.heightBox,
      VStack([
        MenuItem(
          title: "Edit Profile".tr(),
          onPressed: () async {
            final result = await context.pushRoute(AppRoutes.editProfileRoute);
            if (result == true) {
              ref.read(profileControllerProvider.notifier).refresh();
            }
          },
          prefix: Icon(HugeIcons.strokeRoundedUserEdit01),
        ),
        MenuItem(
          title: "Change Password".tr(),
          onPressed: () => context.pushRoute(AppRoutes.changePasswordRoute),
          prefix: Icon(HugeIcons.strokeRoundedResetPassword),
        ),
        CustomVisibilty(
          visible: AppStrings.enableReferSystem,
          child: MenuItem(
            title: "Refer & Earn".tr(),
            onPressed:
                () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => ReferralBottomsheet(user!),
                ),
            prefix: Icon(HugeIcons.strokeRoundedShare01),
          ),
        ),
        CustomVisibilty(
          visible: AppFinanceSettings.enableLoyalty,
          child: MenuItem(
            title: "Loyalty Points".tr(),
            onPressed: () => context.pushRoute('/loyalty'),
            prefix: Icon(HugeIcons.strokeRoundedGift),
          ),
        ),
        CustomVisibilty(
          visible: AppUISettings.allowWallet,
          child: MenuItem(
            title: "Wallet".tr(),
            onPressed: () => context.pushRoute(AppRoutes.walletRoute),
            prefix: Icon(HugeIcons.strokeRoundedWallet01),
          ),
        ),
        MenuItem(
          title: "Delivery Addresses".tr(),
          onPressed: () => context.pushRoute(AppRoutes.deliveryAddressesRoute),
          prefix: Icon(HugeIcons.strokeRoundedPinLocation01),
        ),
        MenuItem(
          title: "Logout".tr(),
          onPressed: () => _logoutPressed(context, ref),
          suffix: Icon(HugeIcons.strokeRoundedLogout01, size: 20),
        ),
        MenuItem(
          child: "Delete Account".tr().text.red500.make(),
          onPressed: () => context.pushRoute('/profile/account-delete'),
          suffix: Icon(
            HugeIcons.strokeRoundedDelete01,
            size: 20,
            color: Vx.red400,
          ),
        ),
        UiSpacer.vSpace(15),
      ]),
    ]);
  }
}
