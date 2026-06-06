import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/button/qty_stepper.dart';
import 'package:fuodz/component/button/share.btn.dart';
import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/component/card/custom_image_slider.dart';
import 'package:fuodz/component/cart_page_action.dart';
import 'package:fuodz/component/html_text_view.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/pages/cart/cart.page.dart';
import 'package:fuodz/pages/product/widgets/add_to_cart.btn.dart';
import 'package:fuodz/pages/product/widgets/amazon/frequently_bought_together.view.dart';
import 'package:fuodz/pages/product/widgets/buy_now.btn.dart';
import 'package:fuodz/pages/product/widgets/commerce_product_options.dart';
import 'package:fuodz/pages/vendor_details/vendor_details.page.dart';
import 'package:fuodz/providers/product_details_providers.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/app_currency_system.service.dart';
import 'package:fuodz/services/cart.helper.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/extensions/dynamic.dart';
import 'package:fuodz/utils/extensions/string.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';

import 'widgets/amazon/amazon_customer_product_reviews.dart';

class AmazonStyledCommerceProductDetailsPage extends ConsumerStatefulWidget {
  const AmazonStyledCommerceProductDetailsPage({super.key, required this.product});

  final Product product;

  @override
  ConsumerState<AmazonStyledCommerceProductDetailsPage> createState() =>
      _AmazonStyledCommerceProductDetailsPageState();
}

class _AmazonStyledCommerceProductDetailsPageState
    extends ConsumerState<AmazonStyledCommerceProductDetailsPage> {
  final RefreshController _refreshController = RefreshController();
  final GlobalKey _productReviewsKey = GlobalKey();
  bool _busy = false;

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<bool> _addToCart({bool skip = false}) async {
    final notifier = ref.read(
      productDetailsControllerProvider(widget.product).notifier,
    );
    final reqErr = notifier.optionGroupRequirementCheck();
    if (reqErr != null) {
      AlertService.error(title: "Option required".tr(), text: reqErr);
      return false;
    }
    setState(() => _busy = true);
    final s = ref
        .read(productDetailsControllerProvider(widget.product))
        .valueOrNull;
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
    final ok = await _addToCart(skip: true);
    if (!ok || !mounted) return;
    context.pushWidget(CartPage());
  }

  void _scrollTo(GlobalKey viewKey) {
    if (viewKey.currentContext != null) {
      Scrollable.ensureVisible(
        viewKey.currentContext!,
        duration: const Duration(milliseconds: 500),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState =
        ref.watch(productDetailsControllerProvider(widget.product));
    final notifier = ref.read(
      productDetailsControllerProvider(widget.product).notifier,
    );
    final state = asyncState.valueOrNull;
    final detail = state?.product ?? widget.product;
    asyncState.whenData((_) {
      if (_refreshController.isRefresh) _refreshController.refreshCompleted();
    });
    return BasePage(
      showAppBar: true,
      title: "Product details".tr(),
      showLeadingAction: true,
      isLoading: asyncState.isLoading,
      showCart: true,
      actions: [
        ShareButton(
          product: detail,
          child: Icon(Icons.share, color: Utils.textColorByTheme()).px(14),
        ),
        PageCartAction(),
      ],
      body: SmartRefresher(
        enablePullDown: true,
        controller: _refreshController,
        onRefresh: () {
          ref.invalidate(productDetailsControllerProvider(widget.product));
        },
        child: SingleChildScrollView(
          child: VStack([
            VStack([
              "Visit the %s Store"
                  .tr()
                  .fill([detail.vendor.name])
                  .text
                  .color(AppColor.primaryColor)
                  .size(13)
                  .medium
                  .make()
                  .onInkTap(() => context.pushWidget(VendorDetailsPage(vendor: detail.vendor))),
              UiSpacer.vSpace(5),
              detail.name.text.size(18).semiBold.make(),
              UiSpacer.vSpace(5),
              HStack([
                VxRating(
                  size: 20,
                  maxRating: 5.0,
                  value: detail.rating ?? 0,
                  isSelectable: false,
                  onRatingUpdate: (_) {},
                  selectionColor: AppColor.ratingColor,
                ),
                UiSpacer.hSpace(10),
                "(${detail.reviewsCount})"
                    .text
                    .color(AppColor.primaryColor)
                    .make(),
              ]).onTap(() => _scrollTo(_productReviewsKey)),
            ]).p20(),
            CustomImageSlider(
              detail.photos,
              height: context.percentHeight * 32,
              viewportFraction: 1.0,
              autoplay: detail.photos.length > 1,
              boxFit: BoxFit.scaleDown,
            ),
            HStack([
              "Price:".tr().text.lg.make(),
              UiSpacer.hSpace(detail.showDiscount ? 6 : 4),
              if (detail.showDiscount)
                "${AppStrings.currentCurrencySymbol} ${detail.price.convertCurrency}"
                    .currencyFormat()
                    .text
                    .color(AppColor.primaryColor)
                    .lineThrough
                    .semiBold
                    .make(),
              if (detail.showDiscount) UiSpacer.hSpace(8),
              "${AppStrings.currentCurrencySymbol} ${detail.sellPrice.convertCurrency}"
                  .currencyFormat()
                  .text
                  .color(AppColor.primaryColor)
                  .xl2
                  .bold
                  .make()
                  .expand(),
            ], spacing: 5).py4().px20(),
            UiSpacer.divider(height: 2, thickness: 2.5).py12(),
            CustomVisibilty(
              visible: detail.hasStock,
              child: VStack([
                CommerceProductOptions(detail),
                UiSpacer.vSpace(15),
                HStack([
                  "Quantity".tr().text.semiBold.lg.make().expand(),
                  QtyStepper(
                    defaultValue: detail.selectedQty,
                    min: 1,
                    max: (detail.availableQty != null &&
                            detail.availableQty! > 0)
                        ? detail.availableQty!
                        : 20,
                    disableInput: true,
                    onChange: notifier.updateSelectedQty,
                    actionIconColor: AppColor.primaryColor,
                    valueSize: 20,
                  )
                      .box
                      .border(color: AppColor.primaryColor)
                      .roundedSM
                      .make()
                      .fittedBox()
                      .w(context.percentWidth * 25),
                ], spacing: 10, crossAlignment: CrossAxisAlignment.center)
                    .px20(),
                UiSpacer.vSpace(12),
                AddToCartButton(
                  loading: _busy,
                  onPressed: () => _addToCart(),
                ).wFull(context).px20(),
                10.heightBox,
                BuyNowButton(loading: _busy, onPressed: _buyNow)
                    .wFull(context)
                    .px20(),
              ]),
            ),
            CustomVisibilty(
              visible: !detail.hasStock,
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
                  .p8(),
            ).px20(),
            UiSpacer.divider(height: 2, thickness: 1).py12(),
            FrequentlyBoughtTogetherView(detail),
            HtmlTextView(detail.description),
            UiSpacer.divider(height: 2, thickness: 1).py12(),
            VStack([
              UiSpacer.vSpace(20),
              AmazonCustomerProductReview(
                product: detail,
                key: _productReviewsKey,
              ),
            ]).px20(),
          ]),
        ),
      ),
    );
  }
}
