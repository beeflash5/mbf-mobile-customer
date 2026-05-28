import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/app_images.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/login.view_model.dart';
import 'package:fuodz/views/pages/auth/login/compain_login_type.view.dart';
import 'package:fuodz/views/pages/auth/login/email_login.view.dart';
import 'package:fuodz/views/pages/auth/login/otp_login.view.dart';
import 'package:fuodz/views/pages/auth/login/social_media.view.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/buttons/arrow_indicator.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:fuodz/widgets/dynamic_status_bar.dart';
import 'package:fuodz/widgets/image.login.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

import 'login/scan_login.view.dart';

class LoginPage extends StatefulWidget {
  LoginPage({this.required = false, Key? key}) : super(key: key);

  final bool required;
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return DynamicStatusBar(
      baseColor: Colors.white,
      child: ViewModelBuilder<LoginViewModel>.reactive(
        viewModelBuilder: () => LoginViewModel(context),
        onViewModelReady: (model) => model.initialise(),
        builder: (context, model, child) {
          return PopScope(
            canPop: !widget.required,
            onPopInvoked: (didPop) async {
              if (!didPop && widget.required) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "You are required to login/register to continue process"
                          .tr(),
                    ),
                  ),
                );
              }
            },
            child: BasePage(
              // showLeadingAction: !widget.required,
              // showAppBar: !widget.required,
              // appBarColor: AppColor.faintBgColor,
              // leading: IconButton(
              //   icon: ArrowIndicator(leading: true),
              //   onPressed: () => Navigator.pop(context),
              // ),
              // elevation: 0,
              // isLoading: model.isBusy,
              body: Padding(
                padding: EdgeInsets.only(bottom: context.mq.viewInsets.bottom),
                child:
                    VStack([
                      ImageLogin(),
                      VStack([
                        "Login Now!".tr().text.lg.semiBold.make().centered(),
                        "Welcome back. Please enter your details."
                            .tr()
                            .text
                            .make()
                            .centered(),
                        //
                        // HStack([
                        //   VStack([
                        //     "Welcome Back".tr().text.xl2.semiBold.make(),
                        //     "Login to continue".tr().text.light.make(),
                        //   ]).expand(),
                        //   Image.asset(AppImages.appLogo)
                        //       .h(60)
                        //       .w(60)
                        //       .box
                        //       .withRounded(value: Sizes.radiusSmall)
                        //       .clip(Clip.antiAlias)
                        //       .make(),
                        // ]),

                        //LOGIN Section
                        //both login type
                        // if (AppStrings.enableOTPLogin &&
                        //     AppStrings.enableEmailLogin)
                        //   CombinedLoginTypeView(
                        //     model,
                        //     radius: Sizes.radiusLarge,
                        //   ),
                        // //only email login
                        // if (AppStrings.enableEmailLogin &&
                        //     !AppStrings.enableOTPLogin)
                        //   EmailLoginView(model),
                        //only otp login
                        // if (AppStrings.enableOTPLogin &&
                        //     !AppStrings.enableEmailLogin)
                        OTPLoginView(model),
                      ]).wFull(context).px20().pOnly(top: Vx.dp20),

                      "Don’t have an account?".richText
                          .color(Color(0xff808080))
                          .withTextSpanChildren([
                            " ".textSpan.make(),
                            "Sign Up"
                                .tr()
                                .textSpan
                                .semiBold
                                .color(Colors.black)
                                .underline
                                .make(),
                          ])
                          .makeCentered()
                          // .py12()
                          .onInkTap(model.openRegister),

                      SizedBox(height: 20),
                      Row(
                        children: [
                          Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Color(0xff808080)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      AppImages.google2,
                                      width: 24,
                                      height: 24,
                                    ),
                                    SizedBox(width: 10),
                                    "Google".text.make(),
                                  ],
                                ),
                              )
                              .onInkTap(
                                () => model.socialMediaLoginService.googleLogin(
                                  model,
                                ),
                              )
                              .expand(),

                          SizedBox(width: 10),

                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Color(0xff808080)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  AppImages.apple2,
                                  width: 24,
                                  height: 24,
                                ),
                                SizedBox(width: 10),
                                "Apple".text.make(),
                              ],
                            ),
                          ).onInkTap(() {
                            if (Platform.isAndroid) {
                              model.socialMediaLoginService.appleLoginAndroid(
                                model,
                              );
                            } else {
                              model.socialMediaLoginService.appleLogin(model);
                            }
                          }).expand(),

                          // Container(
                          //       padding: EdgeInsets.all(10),
                          //       decoration: BoxDecoration(
                          //         border: Border.all(color: Color(0xff808080)),
                          //         borderRadius: BorderRadius.circular(10),
                          //       ),
                          //       child: Row(
                          //         crossAxisAlignment: CrossAxisAlignment.center,
                          //         mainAxisAlignment: MainAxisAlignment.center,
                          //         children: [
                          //           !model.useOtp
                          //               ? Image.asset(
                          //                 AppImages.wa,
                          //                 width: 24,
                          //                 height: 24,
                          //               )
                          //               : Icon(Icons.email),
                          //         ],
                          //       ),
                          //     )
                          //     .pOnly(left: 10)
                          //     .onInkTap(() => model.setUseOtp(!model.useOtp)),
                        ],
                      ).px20(),

                      SizedBox(height: 30),
                      // Row(
                      //   crossAxisAlignment: CrossAxisAlignment.center,
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     "Don’t have an account?".text
                      //         .color(Color(0xff808080))
                      //         .make(),

                      //          "Create An Account".text
                      //           .tr()
                      //           .color(AppColor.primaryColor)
                      //           .make(),
                      //   ],
                      // ),
                      //
                      //register
                      // HStack([
                      //   UiSpacer.divider().expand(),
                      //   "OR".tr().text.light.make().px8(),
                      //   UiSpacer.divider().expand(),
                      // ]).py8().px20(),
                      // SocialMediaView(model, bottomPadding: 10),
                      // "Don’t have an account?".richText
                      //     .color(Color(0xff808080))
                      //     .withTextSpanChildren([
                      //       " ".textSpan.make(),
                      //       "Sign Up".tr().textSpan.semiBold.make(),
                      //     ])
                      //     .makeCentered()
                      //     .py12()
                      //     .onInkTap(model.openRegister),

                      // ScanLoginView(model),
                    ]).scrollVertical(),
              ),
            ),
          );
        },
      ),
    );
  }
}
