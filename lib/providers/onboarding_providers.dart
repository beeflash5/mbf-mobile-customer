import 'package:flutter/material.dart';
import 'package:flutter_overboard/flutter_overboard.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/custom_image.view.dart';
import 'package:fuodz/services/settings.request.dart';
import 'package:fuodz/services/toast.service.dart';
import 'package:fuodz/utils/app_images.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';

final _settingsRequestProvider =
    Provider<SettingsRequest>((_) => SettingsRequest());

class OnboardingController
    extends FamilyAsyncNotifier<List<PageModel>, BuildContext> {
  late BuildContext _ctx;

  @override
  Future<List<PageModel>> build(BuildContext arg) async {
    _ctx = arg;
    final fallback = _fallback();
    try {
      final apiResponse =
          await ref.read(_settingsRequestProvider).appOnboardings();
      if (apiResponse.allGood) {
        final list = (apiResponse.body as List).map((e) {
          return PageModel.withChild(
            child: VStack([
              CustomImage(
                imageUrl: "${e['photo']}",
                width: double.infinity,
                height: null,
                boxFit: BoxFit.fill,
                hideDefaultImg: true,
              ),
              20.heightBox,
              "${e['title']}".tr().text.xl3.bold.make(),
              UiSpacer.vSpace(5),
              "${e['description']}".tr().text.lg.hairLine.make(),
            ]).p20(),
            color: _ctx.theme.colorScheme.surface,
            doAnimateChild: true,
          );
        }).toList();
        if (list.isNotEmpty) return list;
      } else {
        ToastService.toastError('${apiResponse.message}');
      }
    } catch (error) {
      ToastService.toastError('$error');
    }
    return fallback;
  }

  List<PageModel> _fallback() {
    final bgColor = _ctx.backgroundColor;
    final textColor = Utils.textColorByColorReversed(bgColor);
    return [
      PageModel(
        color: bgColor,
        titleColor: textColor,
        bodyColor: textColor,
        imageAssetPath: AppImages.onboarding1,
        title: 'Browse through different vendors'.tr(),
        body: 'Get your favourite meal/food/items from varities of vendor'.tr(),
        doAnimateImage: true,
      ),
      PageModel(
        color: bgColor,
        titleColor: textColor,
        bodyColor: textColor,
        imageAssetPath: AppImages.onboarding2,
        title: 'Chat with vendor/delivery boy'.tr(),
        body:
            'Call/Chat with vendor/delivery boy for update about your order and more'
                .tr(),
        doAnimateImage: true,
      ),
      PageModel(
        color: bgColor,
        titleColor: textColor,
        bodyColor: textColor,
        imageAssetPath: AppImages.onboarding3,
        title: 'Delivery made easy'.tr(),
        body:
            'Get your ordered food/item or parcel delivered at a very fast, cheap and reliable way'
                .tr(),
        doAnimateImage: true,
      ),
    ];
  }
}

final onboardingControllerProvider = AsyncNotifierProvider.family<
    OnboardingController, List<PageModel>, BuildContext>(
  OnboardingController.new,
);
