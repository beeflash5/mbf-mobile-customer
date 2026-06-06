import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/utils/app_images.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/busy_indicator.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:fuodz/utils/extensions/context.dart';

class FullImagePreviewPage extends StatelessWidget {
  const FullImagePreviewPage(
    this.imageUrl, {
    this.boxFit,
    Key? key,
  }) : super(key: key);

  final String imageUrl;
  final BoxFit? boxFit;

  @override
  Widget build(BuildContext context) {
    return BasePage(
      // backgroundColor: Colors.black.withOpacity(0.2),
      body: SafeArea(
        child: Column(
          children: [
            //header
            HStack(
              [
                //
                Icon(
                  Icons.close,
                  color: Colors.white,
                ).box.p4.roundedFull.red500.make().onInkTap(() {
                  context.pop();
                }),
                UiSpacer.expandedSpace(),
              ],
            ).p20(),
            //
            PinchZoom(
              maxScale: 5,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                errorWidget: (context, imageUrl, _) => Image.asset(
                  AppImages.appLogo,
                  fit: BoxFit.contain,
                ),
                fit: BoxFit.contain,
                progressIndicatorBuilder: (context, imageURL, progress) {
                  return BusyIndicator().centered();
                },
              ),
            ).expand(),
          ],
        ),
      ),
    );
  }
}
