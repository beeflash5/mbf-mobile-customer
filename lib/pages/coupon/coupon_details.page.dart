import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/list/dynamic_product.list_item.dart';
import 'package:fuodz/component/list/vendor.list_item.dart';
import 'package:fuodz/models/coupon.dart';
import 'package:fuodz/providers/coupons_providers.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/services/toast.service.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';

class CouponDetailsPage extends ConsumerWidget {
  const CouponDetailsPage(this.coupon, {super.key});

  final Coupon coupon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bgColor =
        coupon.color != null
            ? Vx.hexToColor(coupon.color!)
            : AppColor.primaryColor;
    final textColor = Utils.textColorByColor(bgColor);

    // Fetch detail terbaru via Riverpod; fallback ke coupon yang dilempar
    // sebagai argumen kalau masih loading/error.
    final detailAsync = ref.watch(couponDetailsControllerProvider(coupon.id));
    final current = detailAsync.valueOrNull ?? coupon;
    final isBusy = detailAsync.isLoading;

    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      extendBodyBehindAppBar: true,
      elevation: 0,
      appBarColor: bgColor,
      actions: [
        IconButton(
          onPressed: () async {
            try {
              await Clipboard.setData(ClipboardData(text: current.code));
              ToastService.toastSuccessful('Copied to clipboard'.tr());
            } catch (error) {
              ToastService.toastError('$error');
            }
          },
          icon: const Icon(Icons.content_copy),
        ),
      ],
      body: VStack([
        // header
        VStack([
          '${current.code}'.text.xl3.extraBlack.color(textColor).makeCentered(),
          '${current.description}'.text.sm.medium
              .color(textColor)
              .makeCentered(),
          UiSpacer.vSpace(),
        ]).wFull(context).px(10).safeArea().box.color(bgColor).make(),

        VStack(
          [
            Visibility(
              visible: current.products.isNotEmpty,
              child: 'Products'.tr().text.semiBold.xl.make().py(10),
            ),
            CustomListView(
              noScrollPhysics: true,
              padding: EdgeInsets.zero,
              isLoading: isBusy,
              dataSet: current.products,
              separatorBuilder: ((_, __) => UiSpacer.vSpace(0)),
              itemBuilder: (context, index) {
                final product = current.products[index];
                return DynamicProductListItem(
                  product,
                  onPressed: (p) {
                    context.pushRoute('/products/${p.id}', extra: p);
                  },
                );
              },
              emptyWidget:
                  'Coupon can be use with most products without restrictions'
                      .tr()
                      .text
                      .lg
                      .thin
                      .center
                      .makeCentered(),
            ),
            UiSpacer.vSpace(),
            Visibility(
              visible: current.vendors.isNotEmpty,
              child: 'Vendors'.tr().text.semiBold.xl.make().py(10),
            ),
            CustomListView(
              noScrollPhysics: true,
              padding: EdgeInsets.zero,
              isLoading: isBusy,
              dataSet: current.vendors,
              separatorBuilder: ((_, __) => UiSpacer.vSpace(0)),
              itemBuilder: (context, index) {
                final vendor = current.vendors[index];
                return VendorListItem(
                  vendor: vendor,
                  onPressed: (v) {
                    context.pushRoute('/vendors/${v.id}', extra: v);
                  },
                );
              },
              emptyWidget:
                  'Coupon can be use with most vendors without restrictions'
                      .tr()
                      .text
                      .lg
                      .thin
                      .center
                      .makeCentered(),
            ),
          ],
          crossAlignment: CrossAxisAlignment.start,
          alignment: MainAxisAlignment.start,
        ).p16().scrollVertical().expand(),
      ]),
    );
  }
}
