import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/models/cart.dart';
import 'package:fuodz/models/option.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/cart.service.dart';
import 'package:fuodz/services/cart_ui.service.dart';
import 'package:fuodz/utils/extensions/dynamic.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/utils/utils.dart';

/// Static equivalent of MyBaseViewModel.addToCartDirectly so any widget can
/// add to cart without an inherited VM.
class CartHelper {
  static Future<void> addToCartDirectly(
    BuildContext context,
    Product product,
    int qty, {
    bool force = false,
  }) async {
    if (qty <= 0) {
      final inCart = CartServices.productsInCart;
      final idx = inCart.indexWhere((e) => e.product?.id == product.id);
      if (idx >= 0) {
        inCart.removeAt(idx);
        await CartServices.saveCartItems(inCart);
      }
      return;
    }

    final cart =
        Cart()
          ..price = product.showDiscount ? product.discountPrice : product.price
          ..product = product
          ..selectedQty = qty
          ..options = product.selectedOptions ?? []
          ..optionsIds =
              (product.selectedOptions ?? []).map((e) => e.id).toList();
    product.selectedQty = qty;

    try {
      final canAdd = await CartUIServices.handleCartEntry(
        context,
        cart,
        product,
      );
      if (canAdd || force) {
        final inCart = CartServices.productsInCart;
        final idx = inCart.indexWhere((e) => e.product?.id == product.id);
        if (idx >= 0) {
          inCart.removeAt(idx);
          inCart.insert(idx, cart);
          await CartServices.saveCartItems(inCart);
        } else {
          await CartServices.addToCart(cart);
        }
      } else if (product.isDigital) {
        AlertService.confirm(
          title: "Digital Product".tr(),
          text:
              "You can only buy/purchase digital products together with other digital products. Do you want to clear cart and add this product?"
                  .tr(),
          onConfirm: () async {
            await CartServices.clearCart();
            if (!context.mounted) return;
            await addToCartDirectly(context, product, qty, force: true);
          },
        );
      } else {
        AlertService.confirm(
          title: "Different Vendor".tr(),
          text:
              "Are you sure you'd like to change vendors? Your current items in cart will be lost."
                  .tr(),
          onConfirm: () async {
            await CartServices.clearCart();
            if (!context.mounted) return;
            await addToCartDirectly(context, product, qty, force: true);
          },
        );
      }
    } catch (e) {
      // swallow - parent shows error if needed
    }
  }

  /// Add a product with selected options to the cart. Shows the same
  /// success/conflict dialogs as the legacy `ProductDetailsViewModel.addToCart`.
  static Future<bool> addProductWithOptions(
    BuildContext context, {
    required Product product,
    required double subTotal,
    required List<Option> selectedOptions,
    required List<int> selectedOptionsIDs,
    bool force = false,
    bool skip = false,
  }) async {
    final cart =
        Cart()
          ..price = subTotal
          ..product = product
          ..selectedQty = product.selectedQty
          ..options = selectedOptions
          ..optionsIds = selectedOptionsIDs;
    try {
      final canAdd = await CartUIServices.handleCartEntry(
        context,
        cart,
        product,
      );
      if (canAdd || force) {
        await CartServices.addToCart(cart);
        if (!skip && context.mounted) {
          await AlertService.custom(
            type: AlertType.success,
            title: "Add to cart".tr(),
            text: "%s Added to cart".tr().fill([product.name]),
            confirmBtnText: "GO TO CART".tr(),
            confirmBtnTextStyle: context.textTheme.bodyLarge?.copyWith(
              fontSize: Vx.dp12,
              color: Utils.textColorByPrimaryColor(),
            ),
            onConfirm: () {
              context.pushRoute('/cart');
            },
            cancelBtnText: "Keep Shopping".tr(),
            cancelBtnTextStyle: context.textTheme.bodyLarge?.copyWith(
              fontSize: Vx.dp12,
            ),
          );
        }
        return true;
      }
      if (product.isDigital && context.mounted) {
        AlertService.confirm(
          title: "Digital Product".tr(),
          text:
              "You can only buy/purchase digital products together with other digital products. Do you want to clear cart and add this product?"
                  .tr(),
          onConfirm: () async {
            await CartServices.clearCart();
            if (!context.mounted) return;
            await addProductWithOptions(
              context,
              product: product,
              subTotal: subTotal,
              selectedOptions: selectedOptions,
              selectedOptionsIDs: selectedOptionsIDs,
              force: true,
              skip: skip,
            );
          },
        );
      } else if (context.mounted) {
        await AlertService.confirm(
          title: "Different Vendor".tr(),
          text:
              "Are you sure you'd like to change vendors? Your current items in cart will be lost."
                  .tr(),
          onConfirm: () async {
            await CartServices.clearCart();
            if (!context.mounted) return;
            await addProductWithOptions(
              context,
              product: product,
              subTotal: subTotal,
              selectedOptions: selectedOptions,
              selectedOptionsIDs: selectedOptionsIDs,
              force: true,
              skip: skip,
            );
          },
        );
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
