import 'package:dartx/dartx.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/models/review.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/models/service_option.dart';
import 'package:fuodz/models/service_option_group.dart';
import 'package:fuodz/services/service.request.dart';
import 'package:fuodz/services/vendor.request.dart';

final _serviceRequestProvider =
    Provider<ServiceRequest>((_) => ServiceRequest());
final _vendorRequestProvider =
    Provider<VendorRequest>((_) => VendorRequest());

class ServiceDetailsState {
  const ServiceDetailsState({
    required this.service,
    this.reviews = const [],
    this.selectedOptions = const [],
    this.page = 1,
  });
  final Service service;
  final List<Review> reviews;
  final List<ServiceOption> selectedOptions;
  final int page;

  List<int> get selectedOptionIds =>
      selectedOptions.map((e) => e.id).toList();

  ServiceDetailsState copyWith({
    Service? service,
    List<Review>? reviews,
    List<ServiceOption>? selectedOptions,
    int? page,
  }) =>
      ServiceDetailsState(
        service: service ?? this.service,
        reviews: reviews ?? this.reviews,
        selectedOptions: selectedOptions ?? this.selectedOptions,
        page: page ?? this.page,
      );
}

class ServiceDetailsController
    extends FamilyAsyncNotifier<ServiceDetailsState, Service> {
  @override
  Future<ServiceDetailsState> build(Service arg) async {
    final oldHeroTag = arg.heroTag;
    final detail = await ref.read(_serviceRequestProvider).serviceDetails(arg.id);
    detail.heroTag = oldHeroTag;
    final reviews = await ref.read(_vendorRequestProvider).getReviews(
      page: 1,
      vendorId: detail.vendorId,
    );
    return ServiceDetailsState(service: detail, reviews: reviews, page: 1);
  }

  Future<void> loadMoreReviews() async {
    final cur = state.valueOrNull;
    if (cur == null) return;
    final nextPage = cur.page + 1;
    try {
      final more = await ref.read(_vendorRequestProvider).getReviews(
        page: nextPage,
        vendorId: cur.service.vendorId,
      );
      state = AsyncData(cur.copyWith(
        reviews: [...cur.reviews, ...more],
        page: more.isEmpty ? cur.page : nextPage,
      ));
    } catch (_) {}
  }

  bool isOptionSelected(ServiceOption option) {
    final cur = state.valueOrNull;
    return cur?.selectedOptionIds.contains(option.id) ?? false;
  }

  void toggleOption(ServiceOptionGroup group, ServiceOption option) {
    final cur = state.valueOrNull;
    if (cur == null) return;
    final selected = [...cur.selectedOptions];
    final ids = selected.map((e) => e.id).toList();
    if (ids.contains(option.id)) {
      selected.removeWhere((e) => e.id == option.id);
    } else {
      if (group.multiple == 0) {
        final found = selected.firstOrNullWhere(
          (o) => o.serviceOptionGroupId == group.id,
        );
        if (found != null) selected.remove(found);
      }
      selected.add(option);
    }
    state = AsyncData(cur.copyWith(selectedOptions: selected));
  }
}

final serviceDetailsControllerProvider = AsyncNotifierProvider.family<
    ServiceDetailsController, ServiceDetailsState, Service>(
  ServiceDetailsController.new,
);
