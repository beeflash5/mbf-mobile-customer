import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/button/custom_button.dart';
import 'package:fuodz/component/custom_text_form_field.dart';
import 'package:fuodz/component/recent_orders.view.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/pages/order/orders_details.page.dart';
import 'package:fuodz/providers/parcel_providers.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_images.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';

class ParcelPage extends ConsumerStatefulWidget {
  const ParcelPage(this.vendorType, {super.key});

  final VendorType vendorType;

  @override
  ConsumerState<ParcelPage> createState() => _ParcelPageState();
}

class _ParcelPageState extends ConsumerState<ParcelPage> {
  GlobalKey pageKey = GlobalKey<State>();
  final RefreshController _refreshController = RefreshController();

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _reload() {
    _refreshController.refreshCompleted();
    setState(() => pageKey = GlobalKey<State>());
  }

  Future<void> _track(String code) async {
    final result = await ref
        .read(parcelTrackingControllerProvider(widget.vendorType.id).notifier)
        .trackOrder(code);
    if (!mounted) return;
    switch (result) {
      case TrackOrderSuccess(:final order):
        context.pushWidget(
          OrderDetailsPage(order: order, isOrderTracking: true),
        );
        break;
      case TrackOrderFailure(:final message):
        AlertService.error(title: "Track your package".tr(), text: message);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncTracking = ref.watch(
      parcelTrackingControllerProvider(widget.vendorType.id),
    );
    final isBusy = asyncTracking.isLoading;
    return BasePage(
      showAppBar: true,
      showLeadingAction: !AppStrings.isSingleVendorMode,
      elevation: 0,
      showCart: true,
      title: widget.vendorType.name,
      appBarColor: AppColor.primaryColor,
      appBarItemColor: context.theme.colorScheme.surface,
      key: pageKey,
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        controller: _refreshController,
        onRefresh: _reload,
        child:
            VStack([
              VStack([
                "Track your package".tr().text.semiBold.white.xl4.make(),
                CustomTextFormField(
                  isReadOnly: isBusy,
                  hintText: "Search by order code".tr(),
                  onFieldSubmitted: _track,
                  fillColor:
                      context.brightness != Brightness.dark
                          ? Colors.white
                          : Colors.grey.shade600,
                ).py12(),
              ]).p20().box.color(AppColor.primaryColor).make(),
              UiSpacer.verticalSpace(),
              CustomButton(
                child:
                    HStack([
                      Icon(
                        Icons.add,
                        color: context.theme.colorScheme.onPrimary,
                      ),
                      5.widthBox,
                      "New Parcel Order"
                          .tr()
                          .text
                          .xl
                          .color(Utils.textColorByPrimaryColor())
                          .make(),
                    ]).p12(),
                onPressed:
                    () => context.pushRoute(
                      '/parcel/new',
                      extra: widget.vendorType,
                    ),
              ).wFull(context).px20(),
              UiSpacer.verticalSpace(),
              RecentOrdersView(
                vendorType: widget.vendorType,
                emptyView: VStack(
                  [
                    20.heightBox,
                    Image.asset(
                      AppImages.emptyParcelOrder,
                      height: context.percentHeight * 20,
                    ),
                    10.heightBox,
                    "No Recent Parcel Orders"
                        .tr()
                        .text
                        .semiBold
                        .xl
                        .center
                        .makeCentered(),
                    5.heightBox,
                    "There are no recent parcel orders to display at the moment."
                        .tr()
                        .text
                        .lg
                        .medium
                        .center
                        .makeCentered(),
                    20.heightBox,
                  ],
                  crossAlignment: CrossAxisAlignment.center,
                  alignment: MainAxisAlignment.center,
                ),
              ),
              UiSpacer.verticalSpace(),
            ]).scrollVertical(),
      ),
    );
  }
}
