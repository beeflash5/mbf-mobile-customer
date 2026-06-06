import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/models/delivery_address.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/services/cart.service.dart';
import 'package:fuodz/services/delivery_address.request.dart';
import 'package:fuodz/utils/app_strings.dart';

final _deliveryAddressRequestProvider =
    Provider<DeliveryAddressRequest>((_) => DeliveryAddressRequest());

class DeliveryAddressPickerState {
  const DeliveryAddressPickerState({
    this.all = const [],
    this.filtered = const [],
  });
  final List<DeliveryAddress> all;
  final List<DeliveryAddress> filtered;

  DeliveryAddressPickerState copyWith({
    List<DeliveryAddress>? all,
    List<DeliveryAddress>? filtered,
  }) =>
      DeliveryAddressPickerState(
        all: all ?? this.all,
        filtered: filtered ?? this.filtered,
      );
}

class DeliveryAddressPickerController
    extends FamilyAsyncNotifier<DeliveryAddressPickerState, bool> {
  late bool _vendorCheckRequired;

  @override
  Future<DeliveryAddressPickerState> build(bool arg) async {
    _vendorCheckRequired = arg;
    final list = await _fetch();
    return DeliveryAddressPickerState(all: list, filtered: list);
  }

  Future<List<DeliveryAddress>> _fetch() async {
    int? vendorId = CartServices.productsInCart.isNotEmpty
        ? CartServices.productsInCart.first.product?.vendor.id
        : AppService().vendorId;

    List<int>? vendorIds = (CartServices.productsInCart.isNotEmpty &&
            AppStrings.enableMultipleVendorOrder)
        ? CartServices.productsInCart
            .map((e) => e.product!.vendorId)
            .toSet()
            .toList()
        : null;

    if (!_vendorCheckRequired) {
      vendorIds = null;
      vendorId = null;
    }

    return ref.read(_deliveryAddressRequestProvider).getDeliveryAddresses(
      vendorId: vendorId,
      vendorIds: vendorIds,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final list = await _fetch();
      return DeliveryAddressPickerState(all: list, filtered: list);
    });
  }

  void filter(String keyword) {
    final cur = state.valueOrNull;
    if (cur == null) return;
    final lower = keyword.toLowerCase();
    final filtered = cur.all.where((e) {
      final name = e.name ?? '';
      final address = e.address ?? '';
      return name.toLowerCase().contains(lower) ||
          address.toLowerCase().contains(lower);
    }).toList();
    state = AsyncData(cur.copyWith(filtered: filtered));
  }
}

final deliveryAddressPickerControllerProvider = AsyncNotifierProvider.family<
    DeliveryAddressPickerController,
    DeliveryAddressPickerState,
    bool>(DeliveryAddressPickerController.new);
