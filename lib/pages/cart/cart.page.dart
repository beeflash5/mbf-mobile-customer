import 'package:dotted_line/dotted_line.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/list/cart.list_item.dart';
import 'package:fuodz/component/states/cart.empty.dart';
import 'package:fuodz/pages/auth/login.page.dart';
import 'package:fuodz/pages/cart/widgets/amount_tile.dart';
import 'package:fuodz/pages/cart/widgets/apply_coupon.dart';
import 'package:fuodz/pages/checkout/checkout.page.dart';
import 'package:fuodz/pages/checkout/multiple_order_checkout.page.dart';
import 'package:fuodz/pages/product/product_details.page.dart';
import 'package:fuodz/providers/cart_providers.dart';
import 'package:fuodz/services/app_currency_system.service.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/cart.service.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/extensions/string.dart';
import 'package:fuodz/utils/sizes.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  Future<void> _checkout(BuildContext context, WidgetRef ref) async {
    bool canOpenCheckout = true;
    if (!AuthServices.authenticated()) {
      final result = await context.pushWidget(LoginPage());
      if (result == null || result == false) canOpenCheckout = false;
    }
    if (!canOpenCheckout || !context.mounted) return;
    final state = ref.read(cartControllerProvider);
    final checkOut = state.toCheckout();
    dynamic result;
    if (AppStrings.enableMultipleVendorOrder &&
        CartServices.isMultipleOrder()) {
      result = await context.pushWidget(
        MultipleOrderCheckoutPage(checkout: checkOut),
      );
    } else {
      result = await context.pushWidget(CheckoutPage(checkout: checkOut));
    }
    if (result == true) {
      await ref.read(cartControllerProvider.notifier).clearCart();
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cartControllerProvider);
    final notifier = ref.read(cartControllerProvider.notifier);
    final currencySymbol = AppStrings.currentCurrencySymbol;
    final totalStyle = context.textTheme.bodyLarge!.copyWith(
      fontSize: Sizes.fontSizeExtraLarge,
      fontWeight: FontWeight.w600,
    );
    final summaryStyle = context.textTheme.bodyLarge!.copyWith(
      fontSize: Sizes.fontSizeLarge,
    );

    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: "My Cart".tr(),
      body: SafeArea(
        child: VStack([
          if (state.cartItems.isEmpty)
            EmptyCart().centered().expand()
          else
            VStack([
                  CustomListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                    noScrollPhysics: true,
                    dataSet: state.cartItems,
                    separatorBuilder: (_, __) => 12.heightBox,
                    itemBuilder: (context, index) {
                      final cart = state.cartItems[index];
                      final product = cart.product;
                      return InkWell(
                        child: CartListItem(
                          key: Key("${cart.product?.id}:$index"),
                          cart,
                          onQuantityChange:
                              (qty) => notifier.updateCartItemQuantity(
                                context,
                                index,
                                qty,
                              ),
                          deleteCartItem: () => notifier.deleteCartItem(index),
                        ),
                        onTap:
                            () => context.pushWidget(
                              ProductDetailsPage(product: product!),
                            ),
                      );
                    },
                  ).box.color(AppColor.faintBgColor).make(),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: context.backgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 4,
                          spreadRadius: 1,
                          offset: const Offset(4, -4),
                        ),
                      ],
                    ),
                    child: VStack([
                      const ApplyCoupon(),
                      10.heightBox,
                      AmountTile(
                        "Total Item".tr(),
                        state.totalCartItems.toString(),
                        amountStyle: summaryStyle,
                      ),
                      AmountTile(
                        "Sub-Total".tr(),
                        "$currencySymbol ${state.subTotalPrice.convertCurrency}"
                            .currencyFormat(),
                        amountStyle: summaryStyle,
                      ),
                      Visibility(
                        visible:
                            state.coupon != null && !state.coupon!.for_delivery,
                        child: AmountTile(
                          "Discount".tr(),
                          "$currencySymbol ${state.discountCartPrice.convertCurrency}"
                              .currencyFormat(),
                          amountStyle: summaryStyle,
                        ),
                      ),
                      Visibility(
                        visible:
                            state.coupon != null && state.coupon!.for_delivery,
                        child: VStack([
                          DottedLine(
                            dashColor: context.textTheme.bodyLarge!.color!,
                          ).py12(),
                          "Discount will be applied to delivery fee on checkout"
                              .tr()
                              .text
                              .medium
                              .make(),
                        ]).py(4),
                      ),
                      DottedLine(
                        dashColor: context.textTheme.bodyLarge!.color!,
                      ).py(10),
                      AmountTile(
                        "Total".tr(),
                        "$currencySymbol ${state.totalCartPrice.convertCurrency}"
                            .currencyFormat(),
                        amountStyle: totalStyle,
                      ),
                      CustomButton(
                        title: "CHECKOUT".tr(),
                        onPressed: () => _checkout(context, ref),
                      ).h(Vx.dp48).py32(),
                    ]),
                  ),
                ])
                .pOnly(bottom: context.mq.viewPadding.bottom)
                .scrollVertical()
                .expand(),
        ]),
      ),
    );
  }
}
