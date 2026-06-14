import 'package:flutter/material.dart';
import 'package:flutter_overboard/flutter_overboard.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/busy_indicator.dart';
import 'package:fuodz/providers/onboarding_providers.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_routes.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/utils/utils.dart';

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPages = ref.watch(onboardingControllerProvider(context));
    final pages = asyncPages.valueOrNull ?? const <PageModel>[];

    Future<void> onDone() async {
      await AuthServices.firstTimeCompleted();
      if (!context.mounted) return;
      context.goRoute(AppRoutes.homeRoute);
    }

    return BasePage(
      extendBodyBehindAppBar: true,
      body: VStack([
        Visibility(
          visible: asyncPages.isLoading || pages.isEmpty,
          child: BusyIndicator().centered().expand(),
        ),
        Visibility(
          visible: !asyncPages.isLoading && pages.isNotEmpty,
          child: Directionality(
            textDirection: Utils.textDirection,
            child:
                OverBoard(
                  pages: pages,
                  showBullets: true,
                  skipText: 'Skip'.tr(),
                  nextText: 'Next'.tr(),
                  finishText: 'Done'.tr(),
                  skipCallback: onDone,
                  finishCallback: onDone,
                  buttonColor: AppColor.primaryColor,
                  inactiveBulletColor: AppColor.accentColor,
                  activeBulletColor: AppColor.primaryColorDark,
                ).expand(),
          ),
        ),
      ]),
    );
  }
}
