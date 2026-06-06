import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/component/custom_image.view.dart';
import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/list/frequent_bought_product.list_item.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/providers/product_bought_together_providers.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/services/toast.service.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/extensions/string.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class FrequentlyBoughtTogetherView extends ConsumerWidget {
  const FrequentlyBoughtTogetherView(this.product, {super.key});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState =
        ref.watch(productBoughtTogetherControllerProvider(product.id));
    final state = asyncState.valueOrNull;
    final notifier =
        ref.read(productBoughtTogetherControllerProvider(product.id).notifier);

    if (state == null) return UiSpacer.emptySpace();
    return CustomVisibilty(
      visible: state.products.isNotEmpty,
      child: VStack([
        'Frequently bought together'.tr().text.extraBlack.xl2.make().px20(),
        UiSpacer.vSpace(10),
        VStack([
          Wrap(
            direction: Axis.horizontal,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: _itemsListView(state.products, context),
          ).p12(),
          UiSpacer.divider(),
          CustomVisibilty(
            visible: !state.expanded,
            child: HStack([
              HStack([
                'Buy Together:'.tr().text.make(),
                UiSpacer.hSpace(6),
                '${AppStrings.currencySymbol} ${state.totalSellPrice}'
                    .currencyFormat()
                    .text
                    .scale(1.3)
                    .color(AppColor.primaryColor)
                    .semiBold
                    .make(),
              ],
                  crossAlignment: CrossAxisAlignment.center,
                  alignment: MainAxisAlignment.center).expand(),
              const Icon(Icons.keyboard_arrow_down, size: 20),
            ]).onTap(notifier.toggleExpanded).p12(),
          ),
          CustomVisibilty(
            visible: state.expanded,
            child: VStack([
              CustomListView(
                noScrollPhysics: true,
                dataSet: state.products,
                itemBuilder: (ctx, index) {
                  final p = state.products[index];
                  return FrequentBoughtProductListItem(
                    product: p,
                    selected: state.selectedIds.contains(p.id),
                    oncheckChange: (value) =>
                        notifier.toggleProduct(p.id, value),
                  );
                },
                separatorBuilder: (ctx, index) => UiSpacer.divider(),
              ),
              UiSpacer.divider().py8(),
              VStack([
                HStack([
                  'Total price:'.tr().text.make(),
                  UiSpacer.hSpace(6),
                  '${AppStrings.currencySymbol} ${state.totalSellPrice}'
                      .currencyFormat()
                      .text
                      .scale(1.3)
                      .color(AppColor.primaryColor)
                      .semiBold
                      .make(),
                ],
                    crossAlignment: CrossAxisAlignment.center,
                    alignment: MainAxisAlignment.center).wFull(context),
                UiSpacer.vSpace(15),
                CustomButton(
                  loading: state.isAddingToCart,
                  title: 'Add all to Cart'.tr(),
                  onPressed: state.isAddingToCart
                      ? null
                      : () async {
                          final ok = await notifier.addSelectedToCart();
                          if (ok) {
                            ToastService.toastSuccessful(
                              'Product(s) added to cart'.tr(),
                            );
                          } else {
                            ToastService.toastError(
                              'Failed to add to cart'.tr(),
                            );
                          }
                        },
                ).wFull(context),
              ]).p20(),
            ]),
          ),
        ]).box.border(color: Vx.gray400).roundedSM.make().px20(),
        UiSpacer.divider(height: 4, thickness: 5).py12(),
      ]),
    );
  }

  List<Widget> _itemsListView(List<Product> products, BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < products.length; i++) {
      items.add(
        CustomImage(
          imageUrl: products[i].photo,
          width: 70,
          height: 70,
        ).onTap(() {
          context.pushRoute('/products/${products[i].id}', extra: products[i]);
        }).pOnly(bottom: Vx.dp16),
      );
      if (i != products.length - 1) {
        items.add(
          const Icon(
            Icons.add,
            size: 15,
            color: Vx.gray500,
          ).p8(),
        );
      }
    }
    return items;
  }
}
