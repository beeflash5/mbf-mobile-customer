import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/models/delivery_address.dart';
import 'package:fuodz/services/delivery_address.request.dart';

final _deliveryAddressRequestProvider = Provider<DeliveryAddressRequest>(
  (_) => DeliveryAddressRequest(),
);

sealed class DeliveryAddressSaveResult {
  const DeliveryAddressSaveResult();
}

class DeliveryAddressSaveSuccess extends DeliveryAddressSaveResult {
  const DeliveryAddressSaveSuccess(this.message);
  final String message;
}

class DeliveryAddressSaveFailure extends DeliveryAddressSaveResult {
  const DeliveryAddressSaveFailure(this.message);
  final String message;
}

class NewDeliveryAddressController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<DeliveryAddressSaveResult> save(DeliveryAddress address) async {
    state = const AsyncLoading();
    try {
      final res = await ref
          .read(_deliveryAddressRequestProvider)
          .saveDeliveryAddress(address);
      state = const AsyncData(null);
      return res.allGood
          ? DeliveryAddressSaveSuccess(res.message ?? '')
          : DeliveryAddressSaveFailure(res.message ?? '');
    } catch (e, st) {
      state = AsyncError(e, st);
      return DeliveryAddressSaveFailure('$e');
    }
  }
}

final newDeliveryAddressControllerProvider =
    AsyncNotifierProvider<NewDeliveryAddressController, void>(
      NewDeliveryAddressController.new,
    );

class EditDeliveryAddressController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<DeliveryAddressSaveResult> submit(DeliveryAddress address) async {
    state = const AsyncLoading();
    try {
      final res = await ref
          .read(_deliveryAddressRequestProvider)
          .updateDeliveryAddress(address);
      state = const AsyncData(null);
      return res.allGood
          ? DeliveryAddressSaveSuccess(res.message ?? '')
          : DeliveryAddressSaveFailure(res.message ?? '');
    } catch (e, st) {
      state = AsyncError(e, st);
      return DeliveryAddressSaveFailure('$e');
    }
  }
}

final editDeliveryAddressControllerProvider =
    AsyncNotifierProvider<EditDeliveryAddressController, void>(
      EditDeliveryAddressController.new,
    );
