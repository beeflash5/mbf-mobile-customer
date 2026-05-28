import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:fuodz/constants/app_images.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/view_models/login.view_model.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:velocity_x/velocity_x.dart';

class SocialMediaView extends StatelessWidget {
  const SocialMediaView(this.model, {this.bottomPadding = Vx.dp48, Key? key})
    : super(key: key);

  final LoginViewModel model;
  final double bottomPadding;

  @override
  Widget _socialButton({
    required String icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.white,
        ),
        child: Image.asset(icon, width: 28, height: 28),
        // child: Icon(icon, color: color, size: 28),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // _socialButton(
          //   icon: AppImages.fb,
          //   color: Colors.blue,
          //   onTap: () {
          //     model.socialMediaLoginService.facebookLogin(model);
          //   },
          // ),
          _socialButton(
            icon: AppImages.google,
            color: Colors.red,
            onTap: () {
              model.socialMediaLoginService.googleLogin(model);
            },
          ),

          Platform.isIOS
              ? _socialButton(
                icon: AppImages.apple,
                color: Colors.black,
                onTap: () {
                  model.socialMediaLoginService.appleLogin(model);
                },
              )
              : SizedBox.shrink(),
        ],
      ),
    );
    // return Visibility(
    //   visible: !Platform.isIOS || (Platform.isIOS && AppStrings.appleLogin),
    //   child: VStack([
    //     //facebook
    //     Visibility(
    //       visible: AppStrings.facebbokLogin,
    //       child: SignInButton(
    //         Buttons.FacebookNew,
    //         onPressed: () {
    //           model.socialMediaLoginService.facebookLogin(model);
    //         },
    //       ).wFull(context).pOnly(bottom: Vx.dp4),
    //     ),
    //     //google
    //     Visibility(
    //       visible: AppStrings.googleLogin,
    //       child: SignInButton(
    //         Buttons.Google,
    //         onPressed: () {
    //           model.socialMediaLoginService.googleLogin(model);
    //         },
    //       ).wFull(context).pOnly(bottom: Vx.dp10),
    //     ),

    //     //apple
    //     Visibility(
    //       visible: Platform.isIOS && AppStrings.appleLogin,
    //       child: SignInWithAppleButton(
    //         onPressed: () => model.socialMediaLoginService.appleLogin(model),
    //       ),
    //     ),
    //   ]).px24().pOnly(bottom: bottomPadding),
    // );
  }
}
