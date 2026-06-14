import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/services/splash.service.dart';
import 'package:fuodz/utils/app_images.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SplashService.bootstrap(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body:
          VStack(
            [
              Image.asset(AppImages.appLogo)
                  .wh(context.percentWidth * 45, context.percentWidth * 45)
                  .box
                  .clip(Clip.antiAlias)
                  .roundedSM
                  .makeCentered()
                  .py12(),
              LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  context.theme.primaryColor,
                ),
              ).wOneThird(context).centered(),
            ],
            crossAlignment: CrossAxisAlignment.center,
            alignment: MainAxisAlignment.center,
          ).centered(),
    );
  }
}
