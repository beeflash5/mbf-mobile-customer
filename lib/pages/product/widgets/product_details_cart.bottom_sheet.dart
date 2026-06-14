import 'package:flutter/material.dart';
import 'package:fuodz/utils/app_routes.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/busy_indicator.dart';
import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/button/qty_stepper.dart';
import 'package:fuodz/component/currency_hstack.dart';
import 'package:fuodz/component/states/loading_indicator.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/pages/auth/login.page.dart';
import 'package:fuodz/providers/product_details_providers.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/app_currency_system.service.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/cart.helper.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/extensions/string.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/providers/cart_providers.dart';
import 'package:fuodz/services/cart.service.dart';

class ProductDetailsCartBottomSheet extends ConsumerStatefulWidget {
  const ProductDetailsCartBottomSheet({super.key, required this.product});

  final Product product;

  @override
  ConsumerState<ProductDetailsCartBottomSheet> createState() =>
      _ProductDetailsCartBottomSheetState();
}

class _ProductDetailsCartBottomSheetState
    extends ConsumerState<ProductDetailsCartBottomSheet> {
  bool _busy = false;

  Future<void> _addToCart({bool skip = false}) async {
    final state = ref.read(productDetailsControllerProvider(widget.product));
    final notifier = ref.read(
      productDetailsControllerProvider(widget.product).notifier,
    );
    final reqErr = notifier.optionGroupRequirementCheck();
    if (reqErr != null) {
      AlertService.error(title: "Option required".tr(), text: reqErr);
      return;
    }
    setState(() => _busy = true);
    final s = state.valueOrNull;
    if (s == null) {
      setState(() => _busy = false);
      return;
    }
    await CartHelper.addProductWithOptions(
      context,
      product: s.product,
      subTotal: s.subTotal,
      selectedOptions: s.selectedOptions,
      selectedOptionsIDs: s.selectedOptionIds,
      skip: skip,
    );
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _buyNow() async {
    final state = ref.read(productDetailsControllerProvider(widget.product));
    final notifier = ref.read(
      productDetailsControllerProvider(widget.product).notifier,
    );
    final reqErr = notifier.optionGroupRequirementCheck();
    if (reqErr != null) {
      AlertService.error(title: "Option required".tr(), text: reqErr);
      return;
    }
    setState(() => _busy = true);
    final s = state.valueOrNull;
    if (s == null) {
      setState(() => _busy = false);
      return;
    }

    // Add to cart silently
    await CartHelper.addProductWithOptions(
      context,
      product: s.product,
      subTotal: s.subTotal,
      selectedOptions: s.selectedOptions,
      selectedOptionsIDs: s.selectedOptionIds,
      skip: true,
    );

    // Navigate to checkout directly
    if (mounted) {
      setState(() => _busy = false);

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
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(
      productDetailsControllerProvider(widget.product),
    );
    final notifier = ref.read(
      productDetailsControllerProvider(widget.product).notifier,
    );
    final state = asyncState.valueOrNull;
    final liveProduct = state?.product ?? widget.product;
    final total = state?.total ?? 0;
    final currencySymbol = AppStrings.currentCurrencySymbol;

    return LoadingIndicator(
          loading: asyncState.isLoading,
          loadingWidget: BusyIndicator().centered().box.make().wh(40, 40),
          child: VStack([
            if (liveProduct.hasStock)
              HStack([
                "Quantity".tr().text.xl.medium.make().expand(),
                QtyStepper(
                  defaultValue: liveProduct.selectedQty,
                  min: 1,
                  max:
                      (liveProduct.availableQty != null &&
                              liveProduct.availableQty! > 0)
                          ? liveProduct.availableQty!
                          : 20,
                  disableInput: true,
                  onChange: notifier.updateSelectedQty,
                ),
              ]),
            if (liveProduct.hasStock)
              HStack([
                "Total".tr().text.xl.medium.make().expand(),
                CurrencyHStack([
                  currencySymbol.text.color(AppColor.primaryColor).lg.make(),
                  total.convertCurrency
                      .currencyValueFormat()
                      .text
                      .color(AppColor.primaryColor)
                      .letterSpacing(1.5)
                      .xl
                      .semiBold
                      .make(),
                ]),
              ]).py12(),
            if (liveProduct.hasStock)
              HStack([
                CustomButton(
                  loading: _busy,
                  color: AppColor.primaryColorDark,
                  child:
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: "Buy Now".tr().text.white.medium.make(),
                      ).centered().p12(),
                  onPressed: _buyNow,
                ).expand(),
                CustomButton(
                  loading: _busy,
                  child:
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: "Add to cart".tr().text.white.medium.make(),
                      ).centered().p12(),
                  onPressed: _addToCart,
                ).expand(),
              ], spacing: 20),
            if (!liveProduct.hasStock)
              "No stock"
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
          ]),
        )
        .px20()
        .py12()
        .box
        .color(context.theme.colorScheme.surface)
        .shadowSm
        .make()
        .wFull(context)
        .safeArea();
  }
}
