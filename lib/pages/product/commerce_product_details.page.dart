import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/html_text_view.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/pages/commerce/widgets/similar_commerce_products.view.dart';
import 'package:fuodz/pages/product/widgets/commerce_product_details.header.dart';
import 'package:fuodz/pages/product/widgets/commerce_product_details_cart.bottom_sheet.dart';
import 'package:fuodz/pages/product/widgets/commerce_product_options.dart';
import 'package:fuodz/pages/product/widgets/commerce_product_price.dart';
import 'package:fuodz/pages/product/widgets/commerce_product_qty.dart';
import 'package:fuodz/pages/product/widgets/commerce_seller_tile.dart';
import 'package:fuodz/pages/product/widgets/product_image.gallery.dart';
import 'package:fuodz/providers/product_details_providers.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class CommerceProductDetailsPage extends ConsumerWidget {
  const CommerceProductDetailsPage({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(productDetailsControllerProvider(product));
    final detail = asyncState.valueOrNull?.product ?? product;
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      elevation: 0,
      appBarColor: Colors.transparent,
      appBarItemColor: AppColor.primaryColor,
      showCart: true,
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              top: false,
              child: Hero(
                tag: detail.heroTag ?? detail.id,
                child: ProductImagesGalleryView(detail),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: VStack([
              CommerceProductDetailsHeader(product: detail),
              UiSpacer.divider(),
              CommerceProductPrice(product: detail),
              UiSpacer.divider(),
              CommerceProductOptions(detail),
              UiSpacer.divider(),
              CommerceProductQtyEntry(product: detail),
              UiSpacer.divider(),
              CommerceSellerTile(product: detail),
              UiSpacer.divider().pOnly(bottom: Vx.dp12),
              HtmlTextView(detail.description),
              SimilarCommerceProducts(detail),
            ])
                .pOnly(bottom: context.percentHeight * 30)
                .box
                .outerShadow
                .color(context.theme.colorScheme.surface)
                .topRounded(value: 20)
                .clip(Clip.antiAlias)
                .make(),
          ),
        ],
      ).box.color(AppColor.faintBgColor).make(),
      bottomSheet: CommerceProductDetailsCartBottomSheet(product: detail),
    );
  }
}
