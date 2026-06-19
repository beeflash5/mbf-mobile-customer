import 'package:banner_carousel/banner_carousel.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/button/share.btn.dart';
import 'package:fuodz/component/cart_page_action.dart';
import 'package:fuodz/component/custom_image.view.dart';
import 'package:fuodz/component/states/loading_indicator.dart';
import 'package:fuodz/component/webviewer.dart';
import 'package:fuodz/models/option_group.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/pages/product/widgets/product_details.header.dart';
import 'package:fuodz/pages/product/widgets/product_details_cart.bottom_sheet.dart';
import 'package:fuodz/pages/product/widgets/product_fav.btn.dart';
import 'package:fuodz/pages/product/widgets/product_option_group.dart';
import 'package:fuodz/pages/product/widgets/product_options.header.dart';
import 'package:fuodz/pages/vendor_details/vendor_details.page.dart';
import 'package:fuodz/providers/product_details_providers.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/sizes.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';

class ProductDetailsPage extends ConsumerWidget {
  const ProductDetailsPage({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(productDetailsControllerProvider(product));
    final state = asyncState.valueOrNull;
    final detail = state?.product ?? product;
    return BasePage(
      title: detail.name,
      showAppBar: true,
      showLeadingAction: true,
      elevation: 0,
      appBarColor: AppColor.faintBgColor,
      appBarItemColor: AppColor.primaryColor,
      showCart: true,
      actions: [
        ProductFavButton(product: detail),
        SizedBox(
          width: 50,
          height: 50,
          child: FittedBox(child: ShareButton(product: detail)),
        ),
        UiSpacer.hSpace(10),
        PageCartAction(),
      ],
      body:
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child:
                    BannerCarousel(
                      customizedBanners:
                          detail.photos
                              .map(
                                (photoPath) => CustomImage(
                                  imageUrl: photoPath,
                                  boxFit: BoxFit.contain,
                                  canZoom: true,
                                ),
                              )
                              .toList(),
                      customizedIndicators: IndicatorModel.animation(
                        width: 10,
                        height: 6,
                        spaceBetween: 2,
                        widthAnimation: 50,
                      ),
                      margin: EdgeInsets.zero,
                      height: context.percentHeight * 30,
                      width: context.percentWidth * 100,
                      activeColor: AppColor.primaryColor,
                      disableColor: Colors.grey.shade300,
                      animation: true,
                      borderRadius: 0,
                      indicatorBottom: true,
                    ).box.color(AppColor.faintBgColor).make(),
              ),
              SliverToBoxAdapter(
                child:
                    VStack([
                          ProductDetailsHeader(product: detail),
                          if (detail.description.trim().isNotEmpty) ...[
                            UiSpacer.divider(height: 1, thickness: 2).py12(),
                            WebViewer(
                              url: detail.description_url,
                              height: 50,
                              isScrollable: false,
                              showProgressBar: true,
                              enableJavaScript: true,
                            ),
                          ],
                          Visibility(
                            visible: detail.optionGroups.isNotEmpty,
                            child: VStack([
                              UiSpacer.divider(height: 1, thickness: 2).py12(),
                              LoadingIndicator(
                                loading: asyncState.isLoading,
                                child: VStack([
                                  ProductOptionsHeader(
                                    description:
                                        "Select options to add them to the product/service"
                                            .tr(),
                                  ),
                                  VStack(
                                    detail.optionGroups
                                        .map(
                                          (OptionGroup g) => ProductOptionGroup(
                                            optionGroup: g,
                                            product: detail,
                                          ).pOnly(bottom: Vx.dp12),
                                        )
                                        .toList(),
                                  ),
                                ]),
                              ),
                            ]),
                          ),
                          OutlinedButton(
                            onPressed:
                                () => context.pushWidget(
                                  VendorDetailsPage(vendor: detail.vendor),
                                ),
                            child:
                                "View more from"
                                    .tr()
                                    .richText
                                    .color(Utils.primaryOrTheme)
                                    .sm
                                    .withTextSpanChildren([
                                      " ${detail.vendor.name}".textSpan.semiBold
                                          .color(Utils.primaryOrTheme)
                                          .make(),
                                    ])
                                    .make()
                                    .py12(),
                          ).centered().py16(),
                        ])
                        .pOnly(bottom: context.percentHeight * 30)
                        .box
                        .outerShadow3Xl
                        .color(context.theme.colorScheme.surface)
                        .topRounded(value: Sizes.radiusExtraLarge)
                        .clip(Clip.antiAlias)
                        .make(),
              ),
            ],
          ).box.color(AppColor.faintBgColor).make(),
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.only(bottom: Vx.dp16),
        child: ProductDetailsCartBottomSheet(product: detail),
      ),
    );
  }
}
