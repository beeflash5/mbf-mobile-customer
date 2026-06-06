import 'package:fuodz/utils/eva_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/jiffy.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/busy_indicator.dart';
import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/button/custom_text_button.dart';
import 'package:fuodz/component/custom_image.view.dart';
import 'package:fuodz/component/custom_text_form_field.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/providers/taxi_providers.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/extensions/string.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class TaxiRateDriverView extends ConsumerStatefulWidget {
  const TaxiRateDriverView({super.key, required this.vendorType});

  final VendorType vendorType;

  @override
  ConsumerState<TaxiRateDriverView> createState() => _TaxiRateDriverViewState();
}

class _TaxiRateDriverViewState extends ConsumerState<TaxiRateDriverView> {
  bool isBusy = true;
  Order? order;

  @override
  void initState() {
    super.initState();
    final taxiController =
        ref.read(taxiControllerProvider(widget.vendorType).notifier);
    taxiController.getLastTripForRating().then((value) {
      if (!mounted) return;
      setState(() {
        order = value;
        isBusy = false;
      });
      if (order == null || order?.driver == null) {
        taxiController.dismissTripRating();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final taxiState = ref.watch(taxiControllerProvider(widget.vendorType));
    final taxiController =
        ref.read(taxiControllerProvider(widget.vendorType).notifier);
    return Container(
      width: double.infinity,
      height: context.screenHeight,
      color: Colors.black.withOpacity(0.40),
      child: isBusy
          ? const BusyIndicator()
              .p(20)
              .box
              .roundedSM
              .color(context.theme.colorScheme.surface)
              .make()
              .centered()
          : order == null
              ? Container()
              : VStack([
                  HStack([
                    "Rate your trip".tr().text.xl2.make(),
                    const Spacer(),
                    const Icon(
                      EvaIcons.closeSquareOutline,
                      color: Colors.red,
                      size: 36,
                    ).onInkTap(taxiController.dismissTripRating),
                  ], alignment: MainAxisAlignment.center).px(20).py(10),
                  VStack([
                    10.heightBox,
                    VStack(
                      [
                        CustomImage(
                          imageUrl: order!.driver!.photo,
                          width: context.screenWidth * 0.18,
                          height: context.screenWidth * 0.18,
                        ).box.roundedSM.clip(Clip.antiAlias).makeCentered(),
                        10.heightBox,
                        order!.driver!.name.text.xl.medium.make(),
                        "${order!.driver!.vehicle!.vehicleInfo}".text.light
                            .make(),
                      ],
                      alignment: MainAxisAlignment.center,
                      crossAlignment: CrossAxisAlignment.center,
                    ),
                    VStack(
                      [
                        UiSpacer.divider(),
                        VStack([
                          "${order!.taxiOrder!.currency != null ? order?.taxiOrder?.currency?.symbol : AppStrings.currencySymbol} ${order?.total}"
                              .currencyFormat()
                              .text
                              .semiBold
                              .xl3
                              .makeCentered(),
                          Jiffy.parseFromDateTime(order!.createdAt)
                              .format(pattern: "dd MMM, yyyy hh:mm a")
                              .text
                              .sm
                              .semiBold
                              .makeCentered(),
                        ]),
                        UiSpacer.divider(),
                      ],
                      alignment: MainAxisAlignment.center,
                      crossAlignment: CrossAxisAlignment.center,
                      spacing: 6,
                    ),
                    VStack(
                      [
                        "Rate your trip".tr().text.make(),
                        RatingBar.builder(
                          initialRating: 3,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: false,
                          itemCount: 5,
                          itemSize: 32,
                          itemPadding:
                              const EdgeInsets.symmetric(horizontal: 4.0),
                          itemBuilder: (context, _) => Icon(
                            EvaIcons.star,
                            color: Colors.yellow[700],
                          ),
                          onRatingUpdate: (rating) {
                            taxiController.setNewTripRating(rating);
                          },
                        ).py8(),
                        UiSpacer.verticalSpace(),
                        CustomTextFormField(
                          hintText: "Review".tr(),
                          textEditingController: taxiController.tripReviewTEC,
                          minLines: 3,
                          maxLines: 5,
                        ),
                        UiSpacer.verticalSpace(),
                        CustomButton(
                          title: "Submit Rating".tr(),
                          loading: taxiState.tripBusy,
                          onPressed: () =>
                              taxiController.submitTripRating(order!),
                        ).wFull(context),
                      ],
                      alignment: MainAxisAlignment.center,
                      crossAlignment: CrossAxisAlignment.center,
                    ),
                    SafeArea(
                      child: CustomTextButton(
                        title: "Close".tr(),
                        titleColor: Colors.red,
                        onPressed: taxiController.dismissTripRating,
                      ).wFull(context),
                    ),
                  ], spacing: 10)
                      .p20()
                      .centered()
                      .scrollVertical()
                      .pOnly(bottom: context.mq.viewInsets.bottom)
                      .expand(),
                ]).safeArea().box.color(context.theme.colorScheme.surface).make(),
    );
  }
}
