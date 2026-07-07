import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import 'package:fuodz/models/cart.dart';
import 'package:fuodz/models/checkout.dart';
import 'package:fuodz/models/coupon.dart';
import 'package:fuodz/services/cart.request.dart';
import 'package:fuodz/services/cart.service.dart';
import 'package:fuodz/services/cart_ui.service.dart';

final _cartRequestProvider = Provider<CartRequest>((_) => CartRequest());

sealed class CouponResult {
  const CouponResult();
}

class CouponSuccess extends CouponResult {
  const CouponSuccess(this.coupon);
  final Coupon coupon;
}

class CouponFailure extends CouponResult {
  const CouponFailure(this.message);
  final dynamic message;
}

class CartState {
  const CartState({
    this.cartItems = const [],
    this.totalCartItems = 0,
    this.subTotalPrice = 0,
    this.discountCartPrice = 0,
    this.totalCartPrice = 0,
    this.coupon,
    this.canApplyCoupon = false,
    this.couponError,
  });
  final List<Cart> cartItems;
  final int totalCartItems;
  final double subTotalPrice;
  final double discountCartPrice;
  final double totalCartPrice;
  final Coupon? coupon;
  final bool canApplyCoupon;
  final String? couponError;

  CartState copyWith({
    List<Cart>? cartItems,
    int? totalCartItems,
    double? subTotalPrice,
    double? discountCartPrice,
    double? totalCartPrice,
    Coupon? coupon,
    bool clearCoupon = false,
    bool? canApplyCoupon,
    String? couponError,
    bool clearCouponError = false,
  }) => CartState(
    cartItems: cartItems ?? this.cartItems,
    totalCartItems: totalCartItems ?? this.totalCartItems,
    subTotalPrice: subTotalPrice ?? this.subTotalPrice,
    discountCartPrice: discountCartPrice ?? this.discountCartPrice,
    totalCartPrice: totalCartPrice ?? this.totalCartPrice,
    coupon: clearCoupon ? null : (coupon ?? this.coupon),
    canApplyCoupon: canApplyCoupon ?? this.canApplyCoupon,
    couponError: clearCouponError ? null : (couponError ?? this.couponError),
  );

  /// Compose a CheckOut object representing this cart state.
  CheckOut toCheckout() {
    return CheckOut()
      ..coupon = coupon
      ..subTotal = subTotalPrice
      ..discount = discountCartPrice
      ..total = totalCartPrice
      ..totalWithTip = totalCartPrice
      ..cartItems = cartItems;
  }
}

class CartController extends Notifier<CartState> {
  @override
  CartState build() {
    final sub = CartServices.cartItemsCountStream.stream.listen((_) {
      state = _recalculate(CartState(cartItems: CartServices.productsInCart));
    });
    ref.onDispose(() => sub.cancel());

    final items = CartServices.productsInCart;
    return _recalculate(CartState(cartItems: items));
  }

  CartState _recalculate(CartState s) {
    int totalCartItems = 0;
    double subTotalPrice = 0;
    double discountCartPrice = 0;
    String? couponError;
    final coupon = s.coupon;

    for (final cartItem in s.cartItems) {
      totalCartItems += cartItem.selectedQty!;
      final totalProductPrice = cartItem.price! * cartItem.selectedQty!;
      subTotalPrice += totalProductPrice;

      final foundProduct = coupon?.products.firstOrNullWhere(
        (product) => cartItem.product?.id == product.id,
      );
      final foundVendor = coupon?.vendors.firstOrNullWhere(
        (vendor) => cartItem.product?.vendorId == vendor.id,
      );

      bool skipCalculation = false;
      if (foundProduct?.vendor.vendorType.id == coupon?.vendorTypeId) {
        skipCalculation = false;
      } else if (foundVendor?.vendorType.id == coupon?.vendorTypeId) {
        skipCalculation = false;
      } else if (cartItem.product?.vendor.vendorTypeId ==
          coupon?.vendorTypeId) {
        skipCalculation = false;
      } else {
        skipCalculation = true;
        couponError = "Coupon can't be used with vendor type".tr();
      }
      if (coupon?.for_delivery ?? false) skipCalculation = true;

      if (!skipCalculation && coupon != null) {
        if (foundProduct != null ||
            foundVendor != null ||
            (coupon.products.isEmpty && coupon.vendors.isEmpty)) {
          if (coupon.percentage == 1) {
            discountCartPrice += (coupon.discount / 100) * totalProductPrice;
          } else {
            discountCartPrice += coupon.discount;
          }
        }
      }
    }

    if (coupon != null) {
      try {
        discountCartPrice = coupon.validateDiscount(
          subTotalPrice,
          discountCartPrice,
        );
        couponError = null;
      } catch (e) {
        discountCartPrice = 0;
        couponError = '$e';
      }
    }

    return s.copyWith(
      totalCartItems: totalCartItems,
      subTotalPrice: subTotalPrice,
      discountCartPrice: discountCartPrice,
      totalCartPrice: subTotalPrice - discountCartPrice,
      couponError: couponError,
      clearCouponError: couponError == null,
    );
  }

  Future<void> reload() async {
    state = _recalculate(
      state.copyWith(cartItems: CartServices.productsInCart),
    );
  }

  Future<void> deleteCartItem(int index) async {
    final items = [...state.cartItems];
    items.removeAt(index);
    await CartServices.saveCartItems(items);
    await reload();
  }

  Future<void> updateCartItemQuantity(
    BuildContext context,
    int index,
    int qty,
  ) async {
    if (qty <= 0) {
      await deleteCartItem(index);
      return;
    }
    final cart = state.cartItems[index];
    final addedQty = qty > cart.selectedQty!;
    if (addedQty) {
      final qtyDiff = qty - cart.selectedQty!;
      final canAdd = await CartUIServices.cartItemQtyUpdated(
        context,
        qtyDiff,
        cart,
      );
      if (!canAdd) return;
    }
    state.cartItems[index].selectedQty = qty;
    await CartServices.saveCartItems(state.cartItems);
    await reload();
  }

  void couponCodeChange(String code) {
    state = state.copyWith(canApplyCoupon: code.isNotEmpty);
  }

  Future<CouponResult> applyCoupon(String code) async {
    try {
      final coupon = await ref.read(_cartRequestProvider).fetchCoupon(code);
      if (coupon.useLeft <= 0) {
        return const CouponFailure("Coupon use limit exceeded");
      } else if (coupon.expired) {
        return const CouponFailure("Coupon has expired");
      }
      state = _recalculate(state.copyWith(coupon: coupon));
      if (state.couponError != null) {
        return CouponFailure(state.couponError);
      }
      return CouponSuccess(coupon);
    } catch (e) {
      state = _recalculate(state.copyWith(clearCoupon: true));
      return CouponFailure(e);
    }
  }

  Future<void> clearCart() async {
    await CartServices.saveCartItems([]);
    await reload();
  }
}

final cartControllerProvider = NotifierProvider<CartController, CartState>(
  CartController.new,
);
