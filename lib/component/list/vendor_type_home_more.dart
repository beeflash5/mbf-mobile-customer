import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fuodz/utils/app_images.dart';
import 'package:velocity_x/velocity_x.dart';

class VendorMore extends StatelessWidget {
  const VendorMore({required this.onPressed, Key? key}) : super(key: key);

  final void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    //

    //
    return AnimationConfiguration.staggeredList(
      position: 8,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: InkWell(
            onTap: onPressed,
            child: VStack([
              //image + details
              // Visibility(
              //   visible: !AppStrings.showVendorTypeImageOnly,
              //   child: HStack(
              //     [
              //       //
              //       CustomImage(
              //               imageUrl: vendorType.logo,
              //               height: 80,
              //               width: 180,
              //               boxFit: BoxFit.cover
              //               // width: Vx.dp40,
              //               // height: Vx.dp40,
              //               )
              //           .expand(),
              //       //

              //     ],
              //   ),
              // )
              //     .box
              //     .clip(Clip.antiAlias)
              //     .withRounded(value: 10)
              //     .outerShadow
              //     .color(Vx.hexToColor(vendorType.color))
              //     .make()
              //     .pOnly(bottom: Vx.dp8),

              //image only
              // Visibility(
              //   visible: AppStrings.showVendorTypeImageOnly,
              //   child: CustomImage(
              //     imageUrl: vendorType.logo,
              //     width: context.percentWidth * 100,
              //     height: 140,
              //     boxFit: BoxFit.contain,
              //   ),
              // ),

              // CustomImage(
              //         imageUrl: Appi,
              //         height: 70,
              //         width: 80,
              //         boxFit: BoxFit.cover
              //         // width: Vx.dp40,
              //         // height: Vx.dp40,
              //         )
              Image.asset(
                AppImages.icon_lainnya,
              ).box.clip(Clip.antiAlias).withRounded(value: 10).make(),

              SizedBox(height: 8),

              Center(
                child:
                    "Lainnya".text
                        .overflow(TextOverflow.ellipsis)
                        .sm
                        .bold
                        .color(Color(0xff868686))
                        .make(),
              ),
            ]).centered().pOnly(bottom: Vx.dp8),
          ),
        ),
      ),
    );
  }
}
