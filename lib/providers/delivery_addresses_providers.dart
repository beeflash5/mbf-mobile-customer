import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/models/delivery_address.dart';
import 'package:fuodz/services/delivery_address.request.dart';

final _deliveryAddressRequestProvider = Provider<DeliveryAddressRequest>(
  (_) => DeliveryAddressRequest(),
);

sealed class DeliveryAddressDeleteResult {
  const DeliveryAddressDeleteResult();
}

class DeliveryAddressDeleteSuccess extends DeliveryAddressDeleteResult {
  const DeliveryAddressDeleteSuccess(this.message);
  final String message;
}

class DeliveryAddressDeleteFailure extends DeliveryAddressDeleteResult {
  const DeliveryAddressDeleteFailure(this.message);
  final String message;
}

class DeliveryAddressesController extends AsyncNotifier<List<DeliveryAddress>> {
  @override
  Future<List<DeliveryAddress>> build() async {
    return ref.read(_deliveryAddressRequestProvider).getDeliveryAddresses();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(_deliveryAddressRequestProvider).getDeliveryAddresses(),
    );
  }

  Future<DeliveryAddressDeleteResult> deleteAddress(
    DeliveryAddress address,
  ) async {
    try {
      final res = await ref
          .read(_deliveryAddressRequestProvider)
          .deleteDeliveryAddress(address);
      if (res.allGood) {
        final cur = state.valueOrNull ?? const <DeliveryAddress>[];
        state = AsyncData(cur.where((e) => e.id != address.id).toList());
        return DeliveryAddressDeleteSuccess(res.message ?? '');
      }
      return DeliveryAddressDeleteFailure(res.message ?? '');
    } catch (e) {
      return DeliveryAddressDeleteFailure('$e');
    }
  }
}

final deliveryAddressesControllerProvider =
    AsyncNotifierProvider<DeliveryAddressesController, List<DeliveryAddress>>(
      DeliveryAddressesController.new,
    );
