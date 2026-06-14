import 'package:flutter/material.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/custom_list_view.dart';
import 'package:fuodz/component/list/order.list_item.dart';
import 'package:fuodz/component/list/taxi_order.list_item.dart';
import 'package:fuodz/component/states/empty.state.dart';
import 'package:fuodz/component/states/order.empty.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/pages/auth/login.page.dart';
import 'package:fuodz/pages/order/orders_details.page.dart';
import 'package:fuodz/pages/order/taxi_order_details.page.dart';
import 'package:fuodz/providers/orders_providers.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/payment.helper.dart';
import 'package:fuodz/utils/sizes.dart';

class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage>
    with AutomaticKeepAliveClientMixin<OrdersPage>, WidgetsBindingObserver {
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(ordersControllerProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isAuth = AuthServices.authenticated();
    final asyncState = ref.watch(ordersControllerProvider);
    final notifier = ref.read(ordersControllerProvider.notifier);
    final s = asyncState.valueOrNull;
    final orders = s?.orders ?? const <Order>[];

    asyncState.whenData((_) {
      if (_refreshController.isRefresh) _refreshController.refreshCompleted();
      if (_refreshController.isLoading) _refreshController.loadComplete();
    });

    return BasePage(
      body: VStack([
        20.heightBox,
        "My Orders".tr().text.xl2.semiBold.make().px(20),
        10.heightBox,
        if (isAuth)
          CustomListView(
            canPullUp: true,
            canRefresh: true,
            refreshController: _refreshController,
            onRefresh: () => notifier.refresh(),
            onLoading: () => notifier.loadMore(),
            dataSet: orders,
            padding: EdgeInsets.all(Sizes.paddingSizeDefault),
            emptyWidget: EmptyOrder(),
            separatorBuilder: (_, __) => Sizes.paddingSizeSmall.heightBox,
            isLoading: asyncState.isLoading && orders.isEmpty,
            itemBuilder: (context, index) {
              final order = orders[index];
              if (order.taxiOrder != null) {
                return TaxiOrderListItem(
                  order: order,
                  orderPressed: () => _openOrderDetails(order),
                );
              }
              return OrderListItem(
                order: order,
                orderPressed: () => _openOrderDetails(order),
                onPayPressed:
                    () => PaymentHelper.openOrderPayment(
                      context,
                      order.paymentLink,
                      offline:
                          (order.paymentMethod?.slug ?? 'offline') == 'offline',
                    ),
              );
            },
          ).expand(),
        if (!isAuth)
          EmptyState(
            auth: true,
            showAction: true,
            actionPressed: () async {
              await context.pushWidget(LoginPage());
              if (mounted) notifier.refresh();
            },
          ).py12().centered().expand(),
      ]),
    );
  }

  Future<void> _openOrderDetails(Order order) async {
    if (order.taxiOrder != null) {
      await context.pushWidget(TaxiOrderDetailPage(order: order));
      return;
    }
    final result = await context.pushWidget(OrderDetailsPage(order: order));
    if (!mounted) return;
    if (result is Order) {
      ref.read(ordersControllerProvider.notifier).replaceOrder(result);
    } else if (result is bool && result) {
      ref.read(ordersControllerProvider.notifier).refresh();
    }
  }

  @override
  bool get wantKeepAlive => true;
}
