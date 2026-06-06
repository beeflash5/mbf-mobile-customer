import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/models/category.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/services/category.request.dart';
import 'package:fuodz/services/location.service.dart';
import 'package:fuodz/services/service.request.dart';
import 'package:fuodz/services/vendor.request.dart';

final _vendorRequestProvider =
    Provider<VendorRequest>((_) => VendorRequest());
final _serviceRequestProvider =
    Provider<ServiceRequest>((_) => ServiceRequest());
final _categoryRequestProvider =
    Provider<CategoryRequest>((_) => CategoryRequest());

class ServiceHomeState {
  const ServiceHomeState({
    this.featuredProviders = const [],
    this.categories = const [],
    this.trendingServices = const [],
    this.serviceByCategories = const [],
  });
  final List<Vendor> featuredProviders;
  final List<Category> categories;
  final List<Service> trendingServices;
  final List<Category> serviceByCategories;

  ServiceHomeState copyWith({
    List<Vendor>? featuredProviders,
    List<Category>? categories,
    List<Service>? trendingServices,
    List<Category>? serviceByCategories,
  }) =>
      ServiceHomeState(
        featuredProviders: featuredProviders ?? this.featuredProviders,
        categories: categories ?? this.categories,
        trendingServices: trendingServices ?? this.trendingServices,
        serviceByCategories:
            serviceByCategories ?? this.serviceByCategories,
      );
}

/// Service hub data per vendorTypeId (0 = none).
class ServiceHomeController
    extends FamilyAsyncNotifier<ServiceHomeState, int> {
  StreamSubscription? _locSub;

  @override
  Future<ServiceHomeState> build(int arg) async {
    _locSub?.cancel();
    _locSub = LocationService.currenctDeliveryAddressSubject.listen((_) async {
      state = const AsyncLoading();
      state = await AsyncValue.guard(() => _load(arg));
    });
    ref.onDispose(() => _locSub?.cancel());
    return _load(arg);
  }

  Future<ServiceHomeState> _load(int vendorTypeId) async {
    final categories =
        await ref.read(_categoryRequestProvider).categories(
      vendorTypeId: vendorTypeId == 0 ? null : vendorTypeId,
      page: 1,
      perPage: 10,
      customParams: {'order_by': 'services'},
    );
    final trendingServices = await ref
        .read(_serviceRequestProvider)
        .getServices(
      page: 1,
      queryParams: {
        'type': 'best',
        if (vendorTypeId != 0) 'vendor_type_id': vendorTypeId,
        'direction': 'desc',
      },
    );
    final featured = await ref.read(_vendorRequestProvider).vendorsRequest(
      byLocation: false,
      params: {
        if (vendorTypeId != 0) 'vendor_type_id': vendorTypeId,
        'featured': 1,
      },
    );
    final serviceByCategories = categories.take(4).toList();
    await Future.wait(serviceByCategories.map((cat) async {
      try {
        var services =
            await ref.read(_serviceRequestProvider).getServices(
          queryParams: {'category_id': cat.id},
        );
        if (services.length > 5) services = services.sublist(0, 4);
        cat.services = services;
      } catch (_) {}
    }));
    return ServiceHomeState(
      featuredProviders: featured,
      categories: categories,
      trendingServices: trendingServices,
      serviceByCategories: serviceByCategories,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(arg));
  }
}

final serviceHomeControllerProvider = AsyncNotifierProvider.family<
    ServiceHomeController, ServiceHomeState, int>(
  ServiceHomeController.new,
);
