import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:jiffy/jiffy.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/busy_indicator.dart';
import 'package:fuodz/component/card/custom.visibility.dart';
import 'package:fuodz/component/card/order_details_summary.dart';
import 'package:fuodz/component/custom_image.view.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/pages/order/widgets/order.bottomsheet.dart';
import 'package:fuodz/pages/order/widgets/order_address.view.dart';
import 'package:fuodz/pages/order/widgets/order_attachment.view.dart';
import 'package:fuodz/pages/order/widgets/order_details_driver_info.view.dart';
import 'package:fuodz/pages/order/widgets/order_details_items.view.dart';
import 'package:fuodz/pages/order/widgets/order_details_vendor_info.view.dart';
import 'package:fuodz/pages/order/widgets/order_payment_info.view.dart';
import 'package:fuodz/pages/order/widgets/order_status.view.dart';
import 'package:fuodz/providers/order_details_providers.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/extensions/context.dart';
import 'package:fuodz/utils/ui_spacer.dart';

class OrderDetailsPage extends ConsumerStatefulWidget {
  const OrderDetailsPage({
    super.key,
    required this.order,
    this.isOrderTracking = false,
  });

  final Order order;
  final bool isOrderTracking;

  @override
  ConsumerState<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends ConsumerState<OrderDetailsPage> {
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(orderDetailsControllerProvider(widget.order).notifier)
          .initialise();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderDetailsControllerProvider(widget.order));
    final controller = ref.read(
      orderDetailsControllerProvider(widget.order).notifier,
    );
    final order = state.order;

    return Scaffold(
      extendBody: true,
      body: BasePage(
        title: "Order Details".tr(),
        showAppBar: true,
        showLeadingAction: true,
        isLoading: state.isBusy,
        onBackPressed: () => context.pop(order),
        actions:
            order.isPackageDelivery
                ? [
                  const Icon(
                    Icons.share,
                    color: Colors.white,
                  ).p8().onInkTap(controller.shareOrderDetails).p8(),
                ]
                : [],
        body:
            state.isBusy
                ? const BusyIndicator().centered()
                : SmartRefresher(
                  controller: _refreshController,
                  onRefresh: () async {
                    await controller.fetchOrderDetails();
                    _refreshController.refreshCompleted();
                  },
                  child: Stack(
                    children: [
                      Positioned(
                        child: Stack(
                          children: [
                            CustomImage(
                              imageUrl: order.vendor!.featureImage,
                              width: double.infinity,
                              height: 200,
                              boxFit: BoxFit.contain,
                            ),
                            Positioned(
                              top: 0,
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: GlassContainer(
                                height: 200,
                                width: context.screenWidth,
                                color: Colors.black54,
                                borderGradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.60),
                                    Colors.white.withOpacity(0.10),
                                    AppColor.primaryColor.withOpacity(0.05),
                                    AppColor.primaryColor.withOpacity(0.6),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops: const [0.0, 0.39, 0.40, 1.0],
                                ),
                                blur: 2.0,
                                borderWidth: 0,
                                elevation: 0,
                                isFrostedGlass: true,
                                shadowColor: Colors.black.withOpacity(0.20),
                                alignment: Alignment.center,
                                frostedOpacity: 0.30,
                                padding: const EdgeInsets.all(8.0),
                                child: VStack([
                                  order
                                      .vendor!
                                      .name
                                      .text
                                      .center
                                      .white
                                      .xl3
                                      .semiBold
                                      .makeCentered(),
                                  UiSpacer.verticalSpace(space: 40),
                                ], alignment: MainAxisAlignment.center),
                              ),
                            ),
                          ],
                        ),
                      ),
                      VStack([
                        UiSpacer.verticalSpace(space: 160),
                        VStack([
                              HStack([
                                CustomImage(
                                  imageUrl: order.vendor!.logo,
                                  width: 50,
                                  height: 50,
                                ).box.roundedSM.clip(Clip.antiAlias).make(),
                                UiSpacer.horizontalSpace(),
                                VStack([
                                  "${order.status.tr().capitalized}"
                                      .text
                                      .semiBold
                                      .xl
                                      .color(
                                        AppColor.getStausColor(order.status),
                                      )
                                      .make(),
                                  "${Jiffy.parseFromDateTime(order.updatedAt).format(pattern: 'MMM dd, yyyy | HH:mm')}"
                                      .text
                                      .light
                                      .lg
                                      .make(),
                                  "#${order.code}".text.xs.gray400.light.make(),
                                ]).expand(),
                                Visibility(
                                  visible: !order.isTaxi && !order.isSerice,
                                  child: const Icon(
                                    Icons.qr_code,
                                    size: 28,
                                  ).onInkTap(
                                    () => controller.showVerificationQRCode(
                                      context,
                                    ),
                                  ),
                                ),
                              ]).p20().wFull(context),
                              UiSpacer.divider(),
                              OrderPaymentInfoView(
                                order: order,
                                onOpenPaymentMethodSelection:
                                    () => controller.openPaymentMethodSelection(
                                      context,
                                    ),
                                paymentStatusBusy: state.paymentStatusBusy,
                              ),
                              VStack([
                                OrderStatusView(
                                  order: order,
                                  vendorTypeId: state.vendorTypeId,
                                  onCheckIn: controller.checkIn,
                                  onReschedule:
                                      () => controller.rescedule(context),
                                  onOpenOrderPayment:
                                      () =>
                                          controller.openOrderPayment(context),
                                  onTrackOrder:
                                      () => controller.trackOrder(context),
                                  checkInBusy: state.checkInBusy,
                                  orderBusy: state.orderBusy,
                                ).p20(),
                                UiSpacer.divider(),
                              ]),
                              if (order.confirmation_note != null)
                                _actionRequired(
                                  context: context,
                                  order: order,
                                  orderId: order.id.toString(),
                                  message: order.confirmation_note ?? "",
                                  onCancel:
                                      () => controller.cancelConfirmOrder(
                                        context,
                                      ),
                                  onContinue:
                                      () => controller.confirmOrder(context),
                                ),
                              OrderDetailsItemsView(order: order).p20(),
                              Visibility(
                                visible: order.deliveryAddress != null,
                                child: OrderAddressesView(order: order).p20(),
                              ),
                              OrderAttachmentView(order: order),
                              CustomVisibilty(
                                visible:
                                    !order.isPackageDelivery &&
                                    order.deliveryAddress == null,
                                child:
                                    "".tr().text.italic.light.xl.medium.make(),
                              ),
                              Visibility(
                                visible:
                                    order.note != null &&
                                    order.note!.isNotEmpty &&
                                    order.note != '--' &&
                                    order.note != 'null',
                                child: VStack([
                                  "Note".tr().text.semiBold.xl.make().px20(),
                                  "${order.note}".text.light.sm.make().px20(),
                                ]),
                              ),
                              UiSpacer.vSpace(5),
                              UiSpacer.divider(),
                              UiSpacer.vSpace(),
                              OrderDetailsVendorInfoView(
                                order: order,
                                vendorTypeId: state.vendorTypeId,
                                onCallVendor: controller.callVendor,
                                onChatVendor:
                                    () => controller.chatVendor(context),
                                onRateVendor:
                                    () => controller.rateVendor(context),
                              ),
                              OrderDetailsDriverInfoView(
                                order: order,
                                onCallDriver: controller.callDriver,
                                onChatDriver:
                                    () => controller.chatDriver(context),
                                onRateDriver:
                                    () => controller.rateDriver(context),
                              ),
                              UiSpacer.divider(),
                              OrderDetailsSummary(order)
                                  .wFull(context)
                                  .p20()
                                  .pOnly(bottom: context.percentHeight * 10)
                                  .box
                                  .make(),
                            ]).box
                            .topRounded(value: 15)
                            .clip(Clip.antiAlias)
                            .color(context.theme.colorScheme.surface)
                            .make(),
                        UiSpacer.vSpace(50),
                      ]).scrollVertical(),
                    ],
                  ),
                ),
        bottomNavigationBar:
            widget.isOrderTracking
                ? null
                : SafeArea(
                  child: OrderBottomSheet(
                    order: order,
                    onCancel: () => controller.cancelOrder(context),
                    isBusy: state.isBusy,
                    orderBusy: state.orderBusy,
                  ),
                ),
      ),
    );
  }

  Widget _actionRequired({
    required BuildContext context,
    required Order order,
    required String orderId,
    required String message,
    required VoidCallback onCancel,
    required VoidCallback onContinue,
  }) {
    final status = order.confirmation_customer;
    if (status == null || status == 0) return const SizedBox();

    Color bgColor = const Color(0xFFFFF8E1);
    Color headerColor = const Color(0xFFFFECB3);
    Color textColor = Colors.orange.shade800;
    String title = 'Action Required';
    String description =
        'Please review the partner message and confirm your action.';

    if (status == 2) {
      bgColor = const Color(0xFFE8F5E9);
      headerColor = const Color(0xFFC8E6C9);
      textColor = Colors.green.shade800;
      title = 'Confirmed';
      description = 'You have confirmed to proceed with the order.';
    }
    if (status == 3) {
      bgColor = const Color(0xFFFFEBEE);
      headerColor = const Color(0xFFFFCDD2);
      textColor = Colors.red.shade800;
      title = 'Cancelled';
      description = 'You have cancelled this order.';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Order #$orderId',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: TextStyle(
                    color:
                        status == 2
                            ? Colors.green
                            : status == 3
                            ? Colors.red
                            : Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.black
                            : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(message.isNotEmpty ? message : '-'),
                ),
                const SizedBox(height: 16),
                if (status == 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: onCancel,
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: onContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Continue'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
