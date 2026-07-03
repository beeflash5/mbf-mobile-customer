import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/component/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class VendorTypeHomeListItemVerticalHome extends StatelessWidget {
  const VendorTypeHomeListItemVerticalHome(
    this.vendorType, {
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final VendorType vendorType;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    double size = Platform.isIOS ? 22 : 26;

    return AnimationConfiguration.staggeredList(
      position: vendorType.id,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: InkWell(
            onTap: onPressed,
            child:
                VStack(
                  alignment: MainAxisAlignment.center,
                  crossAlignment: CrossAxisAlignment.center,
                  [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xffE9F4F6),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: CustomImage(
                          imageUrl: vendorType.logo,
                          height: size, //22, //ios 26
                          width: size, //22, //ios 26
                          boxFit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    vendorType.name.text
                        .overflow(TextOverflow.ellipsis)
                        .sm
                        // .color(Colors.black)
                        .make(),
                  ],
                ).centered(), // ❗ HAPUS .w()
          ),
        ),
      ),
    );
  }
}
