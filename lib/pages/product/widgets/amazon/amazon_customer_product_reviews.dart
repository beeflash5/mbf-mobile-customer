import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/list/product_review.list_item.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/pages/product/widgets/amazon/product_review_sumup.view.dart';
import 'package:fuodz/pages/review/product_reviews.page.dart';
import 'package:fuodz/providers/product_review_providers.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';

class AmazonCustomerProductReview extends ConsumerWidget {
  const AmazonCustomerProductReview({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = (product: product, summary: true);
    final asyncState = ref.watch(productReviewControllerProvider(args));
    final reviews = asyncState.valueOrNull?.reviews ?? const [];

    void openAll() => context.pushWidget(ProductReviewsPage(product));

    return VStack([
      HStack([
        ProductReviewSumupView(product).expand(),
        Icon(
          Utils.isArabic
              ? Icons.keyboard_arrow_left
              : Icons.keyboard_arrow_right,
          size: 32,
        ),
      ], crossAlignment: CrossAxisAlignment.center).onTap(openAll),
      UiSpacer.divider().py12(),
      CustomListView(
        noScrollPhysics: true,
        isLoading: asyncState.isLoading && reviews.isEmpty,
        dataSet: reviews,
        itemBuilder: (ctx, index) => ProductReviewListItem(reviews[index]),
      ),
      CustomVisibilty(
        visible: reviews.isNotEmpty,
        child:
            CustomButton(
              child: HStack([
                "Sell all reviews".text.xl.semiBold.make().expand(),
                Icon(
                  Utils.isArabic
                      ? Icons.keyboard_arrow_left
                      : Icons.keyboard_arrow_right,
                ),
              ]),
              onPressed: openAll,
              height: 50,
            ).wFull(context).py12(),
      ),
    ]);
  }
}
