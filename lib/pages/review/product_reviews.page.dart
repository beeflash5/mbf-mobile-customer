import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/busy_indicator.dart';
import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/list/product_review.list_item.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/models/product_review_stat.dart';
import 'package:fuodz/pages/product/widgets/amazon/product_review_sumup.view.dart';
import 'package:fuodz/providers/product_review_providers.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/extensions/dynamic.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';

class ProductReviewsPage extends ConsumerStatefulWidget {
  const ProductReviewsPage(this.product, {super.key});

  final Product product;

  @override
  ConsumerState<ProductReviewsPage> createState() =>
      _ProductReviewsPageState();
}

class _ProductReviewsPageState extends ConsumerState<ProductReviewsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent) {
      final args = (product: widget.product, summary: false);
      ref.read(productReviewControllerProvider(args).notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = (product: widget.product, summary: false);
    final asyncState = ref.watch(productReviewControllerProvider(args));
    final s = asyncState.valueOrNull;
    final reviews = s?.reviews ?? const [];
    final stats = s?.stats ?? const [];

    return BasePage(
      title: "%s reviews".tr().fill([widget.product.name]),
      showAppBar: true,
      showLeadingAction: true,
      body: VStack([
        ProductReviewSumupView(widget.product),
        UiSpacer.vSpace(),
        ..._ratingPercentageView(stats),
        UiSpacer.divider().py12(),
        CustomListView(
          noScrollPhysics: true,
          isLoading: asyncState.isLoading && reviews.isEmpty,
          dataSet: reviews,
          separatorBuilder: (_, __) =>
              UiSpacer.divider(thickness: 0.4).py(8),
          itemBuilder: (ctx, index) =>
              ProductReviewListItem(reviews[index]),
        ),
        CustomVisibilty(
          visible: s?.loadingMore ?? false,
          child: BusyIndicator().centered().p8(),
        ),
      ]).scrollVertical(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
      ),
    );
  }

  List<Widget> _ratingPercentageView(List<ProductReviewStat> stats) {
    final items = <Widget>[];
    for (final stat in stats) {
      final item = HStack([
        "%s star"
            .tr()
            .fill([stat.rate])
            .text
            .medium
            .color(Utils.primaryOrTheme)
            .make()
            .expand(flex: 2),
        UiSpacer.hSpace(8),
        HStack([
          Container(color: AppColor.ratingColor, height: 20)
              .expand(flex: (stat.percentage / 10).ceil()),
          Container(color: Utils.systemGreyColor(), height: 20)
              .expand(flex: ((100 - stat.percentage) / 10).ceil()),
        ])
            .box
            .withRounded(value: 5)
            .border(color: Utils.systemGreyColor())
            .clip(Clip.antiAliasWithSaveLayer)
            .make()
            .expand(flex: 8),
        UiSpacer.hSpace(8),
        "${NumberFormat("#.##").format(stat.percentage)}%"
            .text
            .medium
            .color(Utils.primaryOrTheme)
            .maxLines(1)
            .make()
            .expand(flex: 2),
      ]).pOnly(bottom: Vx.dp12);
      items.add(item);
    }
    return items;
  }
}
