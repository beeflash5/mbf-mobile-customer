import 'package:firestore_chat/firestore_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/bottom_sheet/driver_rating.bottomsheet.dart';
import 'package:fuodz/component/bottom_sheet/order_cancellation.bottomsheet.dart';
import 'package:fuodz/component/bottom_sheet/reschedule.bottomsheet.dart';
import 'package:fuodz/component/bottom_sheet/vendor_rating.bottomsheet.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/models/payment_method.dart';
import 'package:fuodz/pages/checkout/widgets/payment_methods.view.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/services/chat.service.dart';
import 'package:fuodz/services/checkout_shared.helper.dart';
import 'package:fuodz/services/order.request.dart';
import 'package:fuodz/services/order_details_websocket.service.dart';
import 'package:fuodz/services/payment.helper.dart';
import 'package:fuodz/services/toast.service.dart';
import 'package:fuodz/utils/app_routes.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/app_ui_settings.dart';
import 'package:fuodz/utils/extensions/context.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/utils/extensions/dynamic.dart';

class OrderDetailsState {
  const OrderDetailsState({
    required this.order,
    this.vendorTypeId,
    this.paymentMethods = const [],
    this.selectedPaymentMethod,
    this.isBusy = false,
    this.orderBusy = false,
    this.checkInBusy = false,
    this.paymentStatusBusy = false,
  });

  final Order order;
  final int? vendorTypeId;
  final List<PaymentMethod> paymentMethods;
  final PaymentMethod? selectedPaymentMethod;
  final bool isBusy;
  final bool orderBusy;
  final bool checkInBusy;
  final bool paymentStatusBusy;

  OrderDetailsState copyWith({
    Order? order,
    Object? vendorTypeId = _sentinel,
    List<PaymentMethod>? paymentMethods,
    Object? selectedPaymentMethod = _sentinel,
    bool? isBusy,
    bool? orderBusy,
    bool? checkInBusy,
    bool? paymentStatusBusy,
  }) {
    return OrderDetailsState(
      order: order ?? this.order,
      vendorTypeId: identical(vendorTypeId, _sentinel)
          ? this.vendorTypeId
          : vendorTypeId as int?,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      selectedPaymentMethod: identical(selectedPaymentMethod, _sentinel)
          ? this.selectedPaymentMethod
          : selectedPaymentMethod as PaymentMethod?,
      isBusy: isBusy ?? this.isBusy,
      orderBusy: orderBusy ?? this.orderBusy,
      checkInBusy: checkInBusy ?? this.checkInBusy,
      paymentStatusBusy: paymentStatusBusy ?? this.paymentStatusBusy,
    );
  }

  static const _sentinel = Object();
}

class OrderDetailsController
    extends AutoDisposeFamilyNotifier<OrderDetailsState, Order> {
  final OrderRequest _orderRequest = OrderRequest();

  @override
  OrderDetailsState build(Order arg) {
    ref.onDispose(() {
      if (AppStrings.useWebsocketAssignment) {
        OrderDetailsWebsocketService().disconnect();
      }
    });
    return OrderDetailsState(order: arg);
  }

  Future<void> initialise() async {
    int? vendorTypeId;
    final order = state.order;
    if (order.isSerice) {
      vendorTypeId = order.orderService?.service?.vendor_type_id ??
          order.vendor?.vendorTypeId;
    } else {
      vendorTypeId = order.orderProducts?.first.product?.vendor_type_id ??
          order.vendor?.vendorTypeId;
    }
    state = state.copyWith(vendorTypeId: vendorTypeId);
    await Future.wait([
      _fetchPaymentOptions(vendorId: order.vendorId),
      fetchOrderDetails(),
    ]);
    _handleWebsocketOrderEvent();
  }

  Future<void> _fetchPaymentOptions({int? vendorId}) async {
    try {
      final methods = await CheckoutSharedHelpers.getPaymentOptions(
        vendorId: vendorId ?? state.order.vendorId,
        isPickup: false,
      );
      state = state.copyWith(paymentMethods: methods);
    } catch (e) {
      // ignore: avoid_print
      print("OrderDetails fetchPaymentOptions error: $e");
    }
  }

  Future<void> fetchOrderDetails() async {
    state = state.copyWith(isBusy: true);
    try {
      final order = await _orderRequest.getOrderDetails(id: state.order.id);
      state = state.copyWith(order: order);
    } catch (error) {
      // ignore: avoid_print
      print("OrderDetails fetchOrderDetails error: $error");
    }
    state = state.copyWith(isBusy: false);
  }

  void callVendor() => launchUrlString("tel:${state.order.vendor?.phone}");
  void callDriver() => launchUrlString("tel:${state.order.driver?.phone}");
  void callRecipient() => launchUrlString("tel:${state.order.recipientPhone}");

  void chatVendor(BuildContext context) {
    final order = state.order;
    final peers = <String, PeerUser>{
      '${order.userId}': PeerUser(
        id: '${order.userId}',
        name: order.user.name,
        image: order.user.photo,
      ),
      'vendor_${order.vendor?.id}': PeerUser(
        id: "vendor_${order.vendor?.id}",
        name: order.vendor?.name ?? "",
        image: order.vendor?.logo,
      ),
    };
    final chatEntity = ChatEntity(
      onMessageSent: ChatService.sendChatMessage,
      mainUser: peers['${order.userId}']!,
      peers: peers,
      path: 'orders/' + order.code + "/customerVendor/chats",
      title: "Chat with vendor".tr(),
      supportMedia: AppUISettings.canCustomerChatSupportMedia,
    );
    context.pushRoute(AppRoutes.chatRoute, extra: chatEntity);
  }

  void chatDriver(BuildContext context) {
    final order = state.order;
    final peers = <String, PeerUser>{
      '${order.userId}': PeerUser(
        id: '${order.userId}',
        name: order.user.name,
        image: order.user.photo,
      ),
      '${order.driver?.id}': PeerUser(
        id: "${order.driver?.id}",
        name: order.driver?.name ?? "Driver".tr(),
        image: order.driver?.photo,
      ),
    };
    final chatEntity = ChatEntity(
      mainUser: peers['${order.userId}']!,
      peers: peers,
      path: 'orders/' + order.code + "/customerDriver/chats",
      title: "Chat with driver".tr(),
      onMessageSent: ChatService.sendChatMessage,
      supportMedia: AppUISettings.canCustomerChatSupportMedia,
    );
    context.pushRoute(AppRoutes.chatRoute, extra: chatEntity);
  }

  void confirmOrder(BuildContext context) {
    AlertService.dynamic(
      type: AlertType.confirm,
      title: "Confirm Action".tr(),
      text: "Are you sure you want to continue this order?".tr(),
      onConfirm: () async {
        state = state.copyWith(orderBusy: true);
        try {
          final responseMessage = await _orderRequest.confirmOrder(
            id: state.order.id,
            type: 2,
            reason: 'Customer declined partner request',
          );
          context.showToast(
            msg: responseMessage,
            bgColor: Colors.green,
            textColor: Colors.white,
          );
          await fetchOrderDetails();
        } catch (error) {
          context.showToast(
            msg: "$error",
            bgColor: Colors.red,
            textColor: Colors.white,
          );
        }
        state = state.copyWith(orderBusy: false);
      },
    );
  }

  void cancelConfirmOrder(BuildContext context) {
    AlertService.dynamic(
      type: AlertType.warning,
      title: "Cancel Order".tr(),
      text: "Are you sure you want to cancel this order?".tr(),
      onConfirm: () async {
        state = state.copyWith(orderBusy: true);
        try {
          final responseMessage = await _orderRequest.confirmOrder(
            id: state.order.id,
            type: 3,
            reason: 'Customer declined partner request',
          );
          state.order.status = "cancelled";
          context.showToast(
            msg: responseMessage,
            bgColor: Colors.green,
            textColor: Colors.white,
          );
          await fetchOrderDetails();
        } catch (error) {
          context.showToast(
            msg: "$error",
            bgColor: Colors.red,
            textColor: Colors.white,
          );
        }
        state = state.copyWith(orderBusy: false);
      },
    );
  }

  Future<void> checkIn() async {
    state = state.copyWith(checkInBusy: true);
    try {
      final ApiResponse apiResponse =
          await _orderRequest.checkIn(id: state.order.id);
      AlertService.dynamic(
        type: apiResponse.allGood ? AlertType.success : AlertType.error,
        title: "Check-in".tr(),
        text: apiResponse.message,
        onConfirm: apiResponse.allGood ? () => fetchOrderDetails() : null,
      );
    } catch (error) {
      // ignore: avoid_print
      print("OrderDetails checkIn error: $error");
    }
    state = state.copyWith(checkInBusy: false);
  }

  void _handleWebsocketOrderEvent() {
    if (AppStrings.useWebsocketAssignment) {
      OrderDetailsWebsocketService()
          .connectToOrderChannel("${state.order.id}", (data) {
        fetchOrderDetails();
      });
    }
  }

  void refreshDataSet() {
    if (!AppStrings.useWebsocketAssignment) {
      fetchOrderDetails();
    }
  }

  Future<void> rateVendor(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return VendorRatingBottomSheet(
          order: state.order,
          onSubmitted: () {
            sheetCtx.pop();
            fetchOrderDetails();
          },
        );
      },
    );
  }

  Future<void> rescedule(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return RescheduleBottomSheet(
          order: state.order,
          onSubmitted: () {
            sheetCtx.pop();
            fetchOrderDetails();
          },
        );
      },
    );
  }

  Future<dynamic> openOrderPayment(BuildContext context) async {
    final order = state.order;
    if ((order.paymentMethod?.slug ?? "offline") != "offline") {
      return PaymentHelper.openWebpageLink(context, order.paymentLink);
    }
    return PaymentHelper.openExternalWebpageLink(order.paymentLink);
  }

  Future<void> rateDriver(BuildContext context) async {
    await context.push(
      (ctx) => DriverRatingBottomSheet(
        order: state.order,
        onSubmitted: () {
          ctx.pop();
          fetchOrderDetails();
        },
      ),
    );
  }

  void trackOrder(BuildContext context) {
    context.pushRoute(AppRoutes.orderTrackingRoute, extra: state.order);
  }

  void cancelOrder(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return OrderCancellationBottomSheet(
          order: state.order,
          onSubmit: (reason) {
            sheetCtx.pop();
            _processOrderCancellation(context, reason);
          },
        );
      },
    );
  }

  Future<void> _processOrderCancellation(
    BuildContext context,
    String reason,
  ) async {
    state = state.copyWith(orderBusy: true);
    try {
      final responseMessage = await _orderRequest.updateOrder(
        id: state.order.id,
        status: "cancelled",
        reason: reason,
      );
      state.order.status = "cancelled";
      context.showToast(
        msg: responseMessage,
        bgColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (error) {
      context.showToast(
        msg: "$error",
        bgColor: Colors.red,
        textColor: Colors.white,
      );
    }
    state = state.copyWith(orderBusy: false);
  }

  void showVerificationQRCode(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: ctx.backgroundColor,
          child: VStack([
            QrImageView(
              data: state.order.verificationCode,
              version: QrVersions.auto,
              size: ctx.percentWidth * 40,
            ).box.makeCentered(),
            "${state.order.verificationCode}"
                .text
                .medium
                .xl2
                .makeCentered()
                .py4(),
            "Verification Code".tr().text.light.sm.makeCentered().py8(),
          ]).p20(),
        );
      },
    );
  }

  void shareOrderDetails() {
    Share.share(
      "%s is sharing an order code with you. Track order with this code: %s"
          .tr()
          .fill([state.order.user.name, state.order.code]),
    );
  }

  Future<void> openPaymentMethodSelection(BuildContext context) async {
    state = state.copyWith(paymentStatusBusy: true);
    await _fetchPaymentOptions(vendorId: state.order.vendorId);
    state = state.copyWith(paymentStatusBusy: false);
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return PaymentMethodsView(
          paymentMethods: state.paymentMethods,
          selectedPaymentMethod: state.selectedPaymentMethod,
          isLoading: state.paymentStatusBusy,
          onSelected: (pm) => _changeSelectedPaymentMethod(sheetCtx, pm),
        )
            .p20()
            .scrollVertical()
            .box
            .color(sheetCtx.theme.colorScheme.surface)
            .topRounded()
            .make();
      },
    );
  }

  Future<void> _changeSelectedPaymentMethod(
    BuildContext sheetCtx,
    PaymentMethod? paymentMethod,
  ) async {
    sheetCtx.pop();
    state = state.copyWith(paymentStatusBusy: true);
    try {
      final ApiResponse apiResponse =
          await _orderRequest.updateOrderPaymentMethod(
        id: state.order.id,
        paymentMethodId: paymentMethod?.id,
        status: "pending",
      );
      final newOrder = Order.fromJson(apiResponse.body["order"]);
      state =
          state.copyWith(order: newOrder, selectedPaymentMethod: paymentMethod);
      if (!["wallet", "cash"].contains(paymentMethod?.slug)) {
        if (paymentMethod?.slug == "offline") {
          await PaymentHelper.openExternalWebpageLink(newOrder.paymentLink);
        } else {
          await PaymentHelper.openWebpageLink(sheetCtx, newOrder.paymentLink);
        }
      } else {
        ToastService.toastSuccessful("${apiResponse.body['message']}");
      }
      AppService().refreshWalletBalance.add(true);
    } catch (error) {
      ToastService.toastError("$error");
    }
    state = state.copyWith(paymentStatusBusy: false);
  }
}

final orderDetailsControllerProvider = NotifierProvider.autoDispose
    .family<OrderDetailsController, OrderDetailsState, Order>(
  OrderDetailsController.new,
);
