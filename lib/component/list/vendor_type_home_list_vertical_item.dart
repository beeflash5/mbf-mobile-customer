import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/component/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class VendorTypeHomeListItemVertical extends StatelessWidget {
  const VendorTypeHomeListItemVertical(
    this.vendorType, {
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final VendorType vendorType;
  final void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.staggeredList(
      position: vendorType.id,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: InkWell(
            onTap: onPressed,
            child: VStack(
              alignment: MainAxisAlignment.center,
              crossAlignment: CrossAxisAlignment.center,
              [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF1F6E8C).withOpacity(0.1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: CustomImage(
                        imageUrl: vendorType.logo,
                        height: 22,
                        width: 22,
                        boxFit: BoxFit.cover,
                        // width: Vx.dp40,
                        // height: Vx.dp40,
                      ),
                    ),
                    // child: Image.asset(AppImages.ring, width: 28, height: 28),
                    // child: Icon(icon, color: color, size: 28),
                  ),
                  // CustomImage(
                  //   imageUrl: vendorType.logo,
                  //   height: 50,
                  //   width: 50,
                  //   boxFit: BoxFit.cover,
                  //   // width: Vx.dp40,
                  //   // height: Vx.dp40,
                  // ).box.clip(Clip.antiAlias).withRounded(value: 10).make(),
                ),

                SizedBox(height: 8),

                Center(
                  child:
                      vendorType.name.text
                          .overflow(TextOverflow.ellipsis)
                          .sm
                          .bold
                          .color(Color(0xff868686))
                          .make(),
                ),
              ],
            ).centered().w(MediaQuery.of(context).size.width / 5.3),
          ),
        ),
      ),
    );
  }
}
