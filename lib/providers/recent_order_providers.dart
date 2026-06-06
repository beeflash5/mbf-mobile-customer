import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/models/order.dart';
import 'package:fuodz/services/order.request.dart';

final _orderRequestProvider =
    Provider<OrderRequest>((_) => OrderRequest());

/// List recent orders, family by vendorTypeId (0 = no filter).
class RecentOrdersController extends FamilyAsyncNotifier<List<Order>, int> {
  late int _vendorTypeId;

  @override
  Future<List<Order>> build(int arg) async {
    _vendorTypeId = arg;
    return ref.read(_orderRequestProvider).getOrders(
      params: {
        if (arg != 0) 'vendor_type_id': arg,
      },
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(_orderRequestProvider).getOrders(
        params: {
          if (_vendorTypeId != 0) 'vendor_type_id': _vendorTypeId,
        },
      ),
    );
  }
}

final recentOrdersControllerProvider = AsyncNotifierProvider.family<
    RecentOrdersController, List<Order>, int>(RecentOrdersController.new);
