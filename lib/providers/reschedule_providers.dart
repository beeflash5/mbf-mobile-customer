import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/models/order.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/services/vendor.request.dart';

final _vendorRequestProvider = Provider<VendorRequest>((_) => VendorRequest());

sealed class RescheduleResult {
  const RescheduleResult();
}

class RescheduleSuccess extends RescheduleResult {
  const RescheduleSuccess(this.message);
  final String message;
}

class RescheduleFailure extends RescheduleResult {
  const RescheduleFailure(this.message);
  final String message;
}

class RescheduleState {
  const RescheduleState({
    this.vendor,
    this.tables = const [],
    this.availableTimeSlots = const [],
    this.deliverySlotDate,
    this.deliverySlotTime,
    this.tableSelected,
    this.loadingTables = false,
  });

  final Vendor? vendor;
  final List<Map<String, dynamic>> tables;
  final List<String> availableTimeSlots;
  final String? deliverySlotDate;
  final String? deliverySlotTime;
  final String? tableSelected;
  final bool loadingTables;

  RescheduleState copyWith({
    Vendor? vendor,
    List<Map<String, dynamic>>? tables,
    List<String>? availableTimeSlots,
    String? deliverySlotDate,
    String? deliverySlotTime,
    String? tableSelected,
    bool? loadingTables,
  }) => RescheduleState(
    vendor: vendor ?? this.vendor,
    tables: tables ?? this.tables,
    availableTimeSlots: availableTimeSlots ?? this.availableTimeSlots,
    deliverySlotDate: deliverySlotDate ?? this.deliverySlotDate,
    deliverySlotTime: deliverySlotTime ?? this.deliverySlotTime,
    tableSelected: tableSelected ?? this.tableSelected,
    loadingTables: loadingTables ?? this.loadingTables,
  );
}

/// Family arg = Order being rescheduled.
class RescheduleController extends FamilyAsyncNotifier<RescheduleState, Order> {
  late Order _order;

  @override
  Future<RescheduleState> build(Order arg) async {
    _order = arg;
    final vendor = await ref
        .read(_vendorRequestProvider)
        .vendorDetails(arg.vendorId!, params: {'type': 'brief'});
    return RescheduleState(vendor: vendor);
  }

  Future<void> selectDeliveryDate(String date, int index) async {
    final cur = state.valueOrNull;
    if (cur == null || cur.vendor == null) return;
    final times = cur.vendor!.deliverySlots[index].times;
    state = AsyncData(
      cur.copyWith(
        deliverySlotDate: date,
        availableTimeSlots: times,
        loadingTables: true,
      ),
    );
    await _loadTables(date);
  }

  void selectDeliveryTime(String time) {
    final cur = state.valueOrNull;
    if (cur == null) return;
    state = AsyncData(cur.copyWith(deliverySlotTime: time));
  }

  void selectTable(String name) {
    final cur = state.valueOrNull;
    if (cur == null) return;
    state = AsyncData(cur.copyWith(tableSelected: name));
  }

  Future<void> _loadTables(String date) async {
    final cur = state.valueOrNull;
    if (cur == null || cur.vendor == null) return;
    try {
      final response = await ref
          .read(_vendorRequestProvider)
          .vendorGetTableUse(cur.vendor!.id, date, _order.id);
      final occupied = List<int>.from(response.body);
      final tables = <Map<String, dynamic>>[];
      for (int i = 1; i <= (cur.vendor!.qty_tables ?? 0); i++) {
        tables.add({'name': '$i', 'available': !occupied.contains(i)});
      }
      state = AsyncData(cur.copyWith(tables: tables, loadingTables: false));
    } catch (e) {
      state = AsyncData(cur.copyWith(loadingTables: false));
    }
  }

  Future<RescheduleResult> submit() async {
    final cur = state.valueOrNull;
    if (cur == null) return const RescheduleFailure('No state');
    state = const AsyncLoading();
    try {
      final res = await ref
          .read(_vendorRequestProvider)
          .vendorReschulde(
            schedule_date: cur.deliverySlotDate!,
            schedule_time: cur.deliverySlotTime!,
            selected_table_id: cur.tableSelected!,
            order_id: _order.id,
          );
      state = AsyncData(cur);
      return res.allGood
          ? RescheduleSuccess(res.message ?? '')
          : RescheduleFailure(res.message ?? '');
    } catch (e, st) {
      state = AsyncError(e, st);
      return RescheduleFailure('$e');
    }
  }
}

final rescheduleControllerProvider =
    AsyncNotifierProvider.family<RescheduleController, RescheduleState, Order>(
      RescheduleController.new,
    );
