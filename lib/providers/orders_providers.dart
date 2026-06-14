import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/models/order.dart';
import 'package:fuodz/services/order.request.dart';
import 'package:fuodz/services/app.service.dart';

final _orderRequestProvider = Provider<OrderRequest>((_) => OrderRequest());

class OrdersState {
  const OrdersState({
    this.orders = const [],
    this.page = 1,
    this.isLoadingMore = false,
  });

  final List<Order> orders;
  final int page;
  final bool isLoadingMore;

  OrdersState copyWith({List<Order>? orders, int? page, bool? isLoadingMore}) =>
      OrdersState(
        orders: orders ?? this.orders,
        page: page ?? this.page,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );
}

class OrdersController extends AsyncNotifier<OrdersState> {
  StreamSubscription? _homePageSub;
  StreamSubscription? _refreshSub;

  @override
  Future<OrdersState> build() async {
    _homePageSub?.cancel();
    _refreshSub?.cancel();

    _homePageSub = AppService().homePageIndex.stream.listen((_) {
      refresh();
    });
    _refreshSub = AppService().refreshAssignedOrders.listen((refresh) {
      if (refresh) this.refresh();
    });

    ref.onDispose(() {
      _homePageSub?.cancel();
      _refreshSub?.cancel();
    });

    final orders = await ref.read(_orderRequestProvider).getOrders(page: 1);
    return OrdersState(orders: orders, page: 1);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final orders = await ref.read(_orderRequestProvider).getOrders(page: 1);
      return OrdersState(orders: orders, page: 1);
    });
  }

  Future<void> loadMore() async {
    final cur = state.valueOrNull;
    if (cur == null || cur.isLoadingMore) return;
    state = AsyncData(cur.copyWith(isLoadingMore: true));
    try {
      final next = cur.page + 1;
      final more = await ref.read(_orderRequestProvider).getOrders(page: next);
      state = AsyncData(
        cur.copyWith(
          orders: [...cur.orders, ...more],
          page: next,
          isLoadingMore: false,
        ),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  void replaceOrder(Order updated) {
    final cur = state.valueOrNull;
    if (cur == null) return;
    final idx = cur.orders.indexWhere((o) => o.id == updated.id);
    if (idx == -1) return;
    final list = [...cur.orders];
    list[idx] = updated;
    state = AsyncData(cur.copyWith(orders: list));
  }
}

final ordersControllerProvider =
    AsyncNotifierProvider<OrdersController, OrdersState>(OrdersController.new);
