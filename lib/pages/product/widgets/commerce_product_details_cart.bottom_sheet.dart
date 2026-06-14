import 'package:flutter/material.dart';
import 'package:fuodz/utils/app_routes.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/models/product.dart';
import 'package:fuodz/pages/cart/cart.page.dart';
import 'package:fuodz/pages/product/widgets/add_to_cart.btn.dart';
import 'package:fuodz/pages/product/widgets/buy_now.btn.dart';
import 'package:fuodz/providers/product_details_providers.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/cart.helper.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/providers/cart_providers.dart';
import 'package:fuodz/services/cart.service.dart';
import 'package:fuodz/services/auth.service.dart';

class CommerceProductDetailsCartBottomSheet extends ConsumerStatefulWidget {
  const CommerceProductDetailsCartBottomSheet({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  ConsumerState<CommerceProductDetailsCartBottomSheet> createState() =>
      _CommerceProductDetailsCartBottomSheetState();
}

class _CommerceProductDetailsCartBottomSheetState
    extends ConsumerState<CommerceProductDetailsCartBottomSheet> {
  bool _busy = false;

  Future<bool> _addToCartFlow({bool skip = false}) async {
    final notifier = ref.read(
      productDetailsControllerProvider(widget.product).notifier,
    );
    final reqErr = notifier.optionGroupRequirementCheck();
    if (reqErr != null) {
      AlertService.error(title: "Option required".tr(), text: reqErr);
      return false;
    }
    setState(() => _busy = true);
    final s =
        ref.read(productDetailsControllerProvider(widget.product)).valueOrNull;
    if (s == null) {
      setState(() => _busy = false);
      return false;
    }
    final added = await CartHelper.addProductWithOptions(
      context,
      product: s.product,
      subTotal: s.subTotal,
      selectedOptions: s.selectedOptions,
      selectedOptionsIDs: s.selectedOptionIds,
      skip: skip,
    );
    if (mounted) setState(() => _busy = false);
    return added;
  }

  Future<void> _buyNow() async {
    final added = await _addToCartFlow(skip: true);
    if (!added || !mounted) return;
    Navigator.of(context).pop();

    await ref.read(cartControllerProvider.notifier).reload();

    bool canOpenCheckout = true;
    if (!AuthServices.authenticated()) {
      final result = await context.pushRoute<bool>(AppRoutes.loginRoute);
      if (result == null || result == false) canOpenCheckout = false;
    }
    if (!canOpenCheckout || !context.mounted) return;

    final cartState = ref.read(cartControllerProvider);
    final checkOut = cartState.toCheckout();

    dynamic result;
    if (AppStrings.enableMultipleVendorOrder &&
        CartServices.isMultipleOrder()) {
      result = await context.pushRoute('/checkout/multiple', extra: checkOut);
    } else {
      result = await context.pushRoute('/checkout', extra: checkOut);
    }

    if (result == true) {
      await ref.read(cartControllerProvider.notifier).clearCart();
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(
      productDetailsControllerProvider(widget.product),
    );
    final liveProduct = asyncState.valueOrNull?.product ?? widget.product;
    return VStack([
          Visibility(
            visible: liveProduct.hasStock,
            child:
                HStack([
                  AddToCartButton(
                    loading: _busy,
                    onPressed: () => _addToCartFlow(),
                  ).expand(),
                  UiSpacer.smHorizontalSpace(),
                  BuyNowButton(loading: _busy, onPressed: _buyNow).expand(),
                ]).p12(),
          ),
          Visibility(
            visible: !liveProduct.hasStock,
            child: "No stock"
                .tr()
                .text
                .white
                .makeCentered()
                .p8()
                .box
                .red500
                .roundedSM
                .make()
                .p8()
                .wFull(context),
          ),
        ]).box
        .color(context.theme.colorScheme.surface)
        .shadowXl
        .make()
        .wFull(context)
        .safeArea();
  }
}
