import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/busy_indicator.dart';
import 'package:fuodz/component/custom_listed.list_view.dart';
import 'package:fuodz/models/flash_sale.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/pages/flash_sale/widgets/flash_sale.item_view.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/providers/flash_sale_providers.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';

class FlashSaleView extends ConsumerWidget {
  const FlashSaleView(this.vendorType, {super.key});

  final VendorType vendorType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSales = ref.watch(homeFlashSalesProvider(vendorType.id));

    return asyncSales.when(
      loading: () => BusyIndicator().p20().centered(),
      error: (_, __) => UiSpacer.emptySpace(),
      data: (flashSales) {
        if (flashSales.isEmpty) return UiSpacer.emptySpace();
        return VStack([
          UiSpacer.verticalSpace(),
          ...flashSales.map((fs) => _flashSaleSection(context, ref, fs)),
          UiSpacer.vSpace(10),
        ]);
      },
    );
  }

  Widget _flashSaleSection(
    BuildContext context,
    WidgetRef ref,
    FlashSale flashsale,
  ) {
    if (flashsale.items == null ||
        flashsale.items!.isEmpty ||
        flashsale.isExpired) {
      return UiSpacer.emptySpace();
    }

    Widget title = HStack(
      [
        Icon(
          Icons.local_offer,
          color: Utils.textColorByColor(AppColor.closeColor),
        ),
        VStack([
          '${flashsale.name}'.text.semiBold.lg
              .color(Utils.textColorByTheme())
              .make(),
          UiSpacer.vSpace(1),
          HStack([
            'TIME LEFT:'
                .tr()
                .text
                .light
                .sm
                .color(Utils.textColorByTheme())
                .make(),
            UiSpacer.hSpace(6),
            SlideCountdown(
              textStyle: TextStyle(
                fontSize: 11,
                color: Utils.textColorByColor(AppColor.closeColor),
              ),
              duration: flashsale.countDownDuration,
              separatorType: SeparatorType.symbol,
              slideDirection: SlideDirection.up,
              onDone: () {
                // refresh saat countdown habis
                ref.invalidate(homeFlashSalesProvider(vendorType.id));
              },
            ),
          ]),
        ]).expand(),
        'SEE ALL'
            .tr()
            .text
            .color(Utils.textColorByColor(AppColor.closeColor))
            .make()
            .onTap(() => _openFlashSaleItems(context, flashsale)),
      ],
      spacing: 10,
    ).px12().py8().box.color(AppColor.closeColor).make().wFull(context);

    Widget items = CustomListedListView(
      noScrollPhysics: false,
      scrollDirection: Axis.horizontal,
      items:
          (flashsale.items ?? [])
              .map(
                (flashSaleItem) => FittedBox(
                  child: FlashSaleItemListItem(flashSaleItem),
                ).pOnly(right: 5),
              )
              .toList(),
    ).h(Platform.isAndroid ? 160 : 190);

    return VStack([title, items.py4(), UiSpacer.vSpace(10)]).py12();
  }

  void _openFlashSaleItems(BuildContext context, FlashSale flashsale) {
    context.pushRoute('/flash-sales/${flashsale.id}', extra: flashsale);
  }
}
