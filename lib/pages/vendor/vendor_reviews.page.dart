import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/busy_indicator.dart';
import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/list/review.list_item.dart';
import 'package:fuodz/component/states/empty.state.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/providers/vendor_reviews_providers.dart';
import 'package:fuodz/utils/app_images.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class VendorReviewsPage extends ConsumerStatefulWidget {
  const VendorReviewsPage(this.vendor, {super.key});

  final Vendor vendor;

  @override
  ConsumerState<VendorReviewsPage> createState() => _VendorReviewsPageState();
}

class _VendorReviewsPageState extends ConsumerState<VendorReviewsPage> {
  final _refreshController = RefreshController();

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vendorId = widget.vendor.id;
    final asyncState = ref.watch(vendorReviewsControllerProvider(vendorId));
    final notifier = ref.read(
      vendorReviewsControllerProvider(vendorId).notifier,
    );

    asyncState.whenData((s) {
      if (_refreshController.isRefresh) _refreshController.refreshCompleted();
      if (_refreshController.isLoading) _refreshController.loadComplete();
    });

    final reviews = asyncState.valueOrNull?.reviews ?? const [];
    final isBusy = asyncState.isLoading && reviews.isEmpty;

    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: '${widget.vendor.name} ${"Reviews".tr()}',
      body: CustomListView(
        canPullUp: true,
        canRefresh: true,
        refreshController: _refreshController,
        onRefresh: notifier.refresh,
        onLoading: notifier.loadMore,
        isLoading: isBusy,
        loadingWidget: BusyIndicator().centered(),
        dataSet: reviews,
        separatorBuilder: (_, __) => UiSpacer.divider(),
        padding: const EdgeInsets.all(20),
        itemBuilder: (context, index) {
          return ReviewListItem(reviews[index]);
        },
        emptyWidget:
            EmptyState(
              imageUrl: AppImages.noReview,
              title: 'No Review'.tr(),
              description:
                  'When customer drop review, you will see them here'.tr(),
            ).centered(),
      ),
    );
  }
}
