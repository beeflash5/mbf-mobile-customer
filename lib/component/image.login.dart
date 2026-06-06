import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/constants/api.dart';
import 'package:fuodz/utils/app_images.dart';
import 'package:fuodz/utils/sizes.dart';
import 'package:fuodz/pages/payment/custom_webview.page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class ImageLogin extends StatefulWidget {
  const ImageLogin({super.key});

  @override
  State<ImageLogin> createState() => _ImageLoginState();
}

class _ImageLoginState extends State<ImageLogin> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          AppImages.img_login,
          height: MediaQuery.of(context).size.height / 2,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),

        Positioned(
          top: 40,
          left: 20,
          right: 10,
          child: SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(AppImages.appLogo)
                        .h(36)
                        .w(36)
                        .box
                        .withRounded(value: Sizes.radiusSmall)
                        .clip(Clip.antiAlias)
                        .make(),
                    const SizedBox(width: 10),
                    "My Bali Friendz".text.bold.lg.make(),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  color: context.primaryColor,
                ),
              ],
            ),
          ),
        ),

        Positioned(
          bottom: 16,
          left: 20,
          right: 10,
          child: VStack([
            "Welcome Back!".tr().text.lg.color(Colors.white).bold.make(),

            SizedBox(height: 4),
            "Log in to your account to manage your bookings, preference, and more."
                .tr()
                .text
                .sm
                .color(Colors.white)
                .light
                .make(),
            SizedBox(height: 10),
            "My Bali Friendz All right reserved."
                .tr()
                .text
                .sm
                .color(Colors.white)
                .light
                .make(),

            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                "Terms of Services"
                    .tr()
                    .text
                    .sm
                    .color(Colors.white)
                    .textStyle(
                      const TextStyle(
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                      ),
                    )
                    .light
                    .make()
                    .onInkTap(() {
                      final url = Api.terms;
                      context.pushWidget(CustomWebviewPage(selectedUrl: url));
                    }),

                SizedBox(width: 20),
                "Privacy Police"
                    .tr()
                    .text
                    .sm
                    .color(Colors.white)
                    .textStyle(
                      const TextStyle(
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                      ),
                    )
                    .light
                    .make()
                    .onInkTap(() {
                      final url = Api.privacyPolicy;
                      context.pushWidget(CustomWebviewPage(selectedUrl: url));
                    }),
              ],
            ),
          ]),
        ),
      ],
    );
  }
}
