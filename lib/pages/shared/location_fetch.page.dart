import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/button/custom_text_button.dart';
import 'package:fuodz/providers/location_fetch_providers.dart';
import 'package:fuodz/utils/app_images.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class LocationFetchPage extends ConsumerStatefulWidget {
  const LocationFetchPage({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<LocationFetchPage> createState() =>
      _LocationFetchPageState();
}

class _LocationFetchPageState extends ConsumerState<LocationFetchPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ok = await ref
          .read(locationFetchControllerProvider.notifier)
          .initialise();
      if (ok && mounted) _loadNext();
    });
  }

  void _loadNext() {
    // child is a pre-composed widget — go through go_router's generic
    // /_w escape hatch using replace semantics (pushReplacement equivalent).
    context.replaceRoute('/_w', extra: widget.child);
  }

  Future<void> _tryAgain() async {
    final ok = await ref
        .read(locationFetchControllerProvider.notifier)
        .handleFetchCurrentLocation();
    if (ok && mounted) _loadNext();
  }

  Future<void> _pickFromMap() async {
    final ok = await ref
        .read(locationFetchControllerProvider.notifier)
        .pickFromMap(context);
    if (ok && mounted) _loadNext();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(locationFetchControllerProvider);
    return BasePage(
      body: VStack([
        HStack([
          UiSpacer.expandedSpace(),
          CustomTextButton(
            title: "Skip".tr(),
            onPressed: _loadNext,
          ),
        ]).safeArea(),
        Center(
          child: VStack([
            FittedBox(
              child: Image.asset(AppImages.locationGif)
                  .wh(
                    context.percentWidth * 30,
                    context.percentWidth * 30,
                  )
                  .box
                  .roundedFull
                  .clip(Clip.antiAlias)
                  .make(),
            ),
            UiSpacer.vSpace(),
            Visibility(
              visible: !state.showManuallySelection,
              child: VStack([
                "Trying to find your current location."
                    .tr()
                    .text
                    .lg
                    .medium
                    .center
                    .makeCentered(),
                "Please wait while we get it"
                    .tr()
                    .text
                    .lg
                    .medium
                    .center
                    .makeCentered(),
              ]),
            ),
            Visibility(
              visible: state.showManuallySelection,
              child: VStack(
                [
                  "We are unable to determine current location. Please try again or manually select location"
                      .tr()
                      .text
                      .lg
                      .medium
                      .center
                      .makeCentered()
                      .px(40),
                  UiSpacer.vSpace(),
                  CustomButton(
                    title: "Choose On Map".tr(),
                    onPressed: _pickFromMap,
                  ).w40(context),
                  UiSpacer.vSpace(10),
                  CustomTextButton(
                    title: "Try again".tr(),
                    onPressed: _tryAgain,
                  ).w24(context),
                ],
                crossAlignment: CrossAxisAlignment.center,
              ).p20(),
            ),
            UiSpacer.vSpace(),
          ], crossAlignment: CrossAxisAlignment.center),
        ).expand(),
      ]),
    );
  }
}
