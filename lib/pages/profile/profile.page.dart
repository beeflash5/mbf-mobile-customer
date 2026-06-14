import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/card/language_selector.view.dart';
import 'package:fuodz/component/card/profile.card.dart';
import 'package:fuodz/component/menu_item.dart';
import 'package:fuodz/constants/api.dart';
import 'package:fuodz/providers/profile_providers.dart';
import 'package:fuodz/services/app_currency_system.service.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/payment.helper.dart';
import 'package:fuodz/utils/app_routes.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with AutomaticKeepAliveClientMixin<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileControllerProvider);
    });
  }

  void _openReviewApp() async {
    final inAppReview = InAppReview.instance;
    if (Platform.isAndroid) {
      inAppReview.openStoreListing(appStoreId: AppStrings.appStoreId);
    } else if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    } else {
      inAppReview.openStoreListing(appStoreId: AppStrings.appStoreId);
    }
  }

  Future<void> _openContactUs() async {
    if (AuthServices.authenticated()) {
      final id = AuthServices.currentUser?.id;
      await PaymentHelper.openWebpageLink(context, "${Api.contactUs}?id=$id");
    } else {
      await PaymentHelper.openExternalWebpageLink(Api.contactUsWeb);
    }
  }

  Future<void> _changeLanguage() async {
    final result = await context.pushWidget(AppLanguageSelector());
    if (result != null && mounted) {
      context.goRoute('/splash');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(profileControllerProvider).valueOrNull;
    return BasePage(
      body:
          VStack([
            "Settings".tr().text.xl2.semiBold.make(),
            "Profile & App Settings".tr().text.lg.light.make(),
            const ProfileCard().py12(),
            VStack([
              MenuItem(
                title: "Currency".tr(),
                divider: false,
                prefix: Icon(HugeIcons.strokeRoundedMoneyExchange01),
                suffix:
                    AppCurrencySystemService().currentCurrencySymbol.text
                        .make(),
                onPressed:
                    () => AppCurrencySystemService().initAppCurrencyChange(),
              ),
              MenuItem(
                title: "Language".tr(),
                divider: false,
                prefix: Icon(HugeIcons.strokeRoundedGlobal),
                onPressed: _changeLanguage,
              ),
              MenuItem(
                title: "Theme".tr(),
                suffix: Text(
                  AdaptiveTheme.of(context).mode.name.tr().capitalized,
                ),
                prefix: Icon(HugeIcons.strokeRoundedReload),
                onPressed: () => AdaptiveTheme.of(context).toggleThemeMode(),
              ),
              20.heightBox,
              MenuItem(
                title: "Wishlist".tr(),
                prefix: const Icon(Icons.favorite_outline),
                onPressed: () => context.pushRoute(AppRoutes.favouritesRoute),
              ),
              MenuItem(
                title: "Notifications".tr(),
                prefix: Icon(HugeIcons.strokeRoundedNotification01),
                onPressed:
                    () => context.pushRoute(AppRoutes.notificationsRoute),
              ),
              MenuItem(
                title: "Rate & Review".tr(),
                onPressed: _openReviewApp,
                prefix: Icon(HugeIcons.strokeRoundedStar),
              ),
              MenuItem(
                title: "FAQ".tr(),
                onPressed: () => context.pushRoute('/faq'),
                prefix: Icon(HugeIcons.strokeRoundedQuestion),
              ),
              MenuItem(
                title: "Privacy Policy".tr(),
                onPressed:
                    () => PaymentHelper.openWebpageLink(
                      context,
                      Api.privacyPolicy,
                    ),
                prefix: Icon(HugeIcons.strokeRoundedBook02),
              ),
              MenuItem(
                title: "Terms & Conditions".tr(),
                onPressed:
                    () => PaymentHelper.openWebpageLink(context, Api.terms),
                prefix: Icon(HugeIcons.strokeRoundedShield01),
              ),
              MenuItem(
                title: "Refund Policy".tr(),
                onPressed:
                    () =>
                        PaymentHelper.openWebpageLink(context, Api.refundTerms),
                prefix: Icon(HugeIcons.strokeRoundedReturnRequest),
              ),
              MenuItem(
                title: "Cancellation Policy".tr(),
                onPressed:
                    () =>
                        PaymentHelper.openWebpageLink(context, Api.cancelTerms),
                prefix: Icon(HugeIcons.strokeRoundedCancel01),
              ),
              MenuItem(
                title: "Delivery/Shipping Policy".tr(),
                onPressed:
                    () => PaymentHelper.openWebpageLink(
                      context,
                      Api.shippingTerms,
                    ),
                prefix: Icon(HugeIcons.strokeRoundedShoppingBag01),
              ),
              MenuItem(
                title: "Contact Us".tr(),
                onPressed: _openContactUs,
                prefix: Icon(HugeIcons.strokeRoundedMail01),
              ),
            ]),
            (state?.appVersionInfo ?? '').text.sm.medium.gray400
                .makeCentered()
                .py20(),
            UiSpacer.verticalSpace(space: context.percentHeight * 10),
          ]).p20().scrollVertical(),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
