import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/models/product.dart';
import 'package:fuodz/models/search.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/services/search.request.dart';
import 'package:fuodz/services/search.service.dart';
import 'package:fuodz/services/vendor_type.request.dart';

final _searchRequestProvider = Provider<SearchRequest>((_) => SearchRequest());
final _vendorTypeRequestProvider = Provider<VendorTypeRequest>(
  (_) => VendorTypeRequest(),
);

class MainSearchState {
  const MainSearchState({
    this.search,
    this.keyword = '',
    this.showVendors = false,
    this.showProducts = false,
    this.showServices = false,
    this.vendors = const [],
    this.products = const [],
    this.services = const [],
    this.vendorsPage = 1,
    this.productsPage = 1,
    this.servicesPage = 1,
    this.searchHistory = const [],
  });
  final Search? search;
  final String keyword;
  final bool showVendors;
  final bool showProducts;
  final bool showServices;
  final List<Vendor> vendors;
  final List<Product> products;
  final List<Service> services;
  final int vendorsPage;
  final int productsPage;
  final int servicesPage;
  final List<String> searchHistory;

  MainSearchState copyWith({
    Search? search,
    String? keyword,
    bool? showVendors,
    bool? showProducts,
    bool? showServices,
    List<Vendor>? vendors,
    List<Product>? products,
    List<Service>? services,
    int? vendorsPage,
    int? productsPage,
    int? servicesPage,
    List<String>? searchHistory,
  }) => MainSearchState(
    search: search ?? this.search,
    keyword: keyword ?? this.keyword,
    showVendors: showVendors ?? this.showVendors,
    showProducts: showProducts ?? this.showProducts,
    showServices: showServices ?? this.showServices,
    vendors: vendors ?? this.vendors,
    products: products ?? this.products,
    services: services ?? this.services,
    vendorsPage: vendorsPage ?? this.vendorsPage,
    productsPage: productsPage ?? this.productsPage,
    servicesPage: servicesPage ?? this.servicesPage,
    searchHistory: searchHistory ?? this.searchHistory,
  );
}

class MainSearchController extends AsyncNotifier<MainSearchState> {
  @override
  Future<MainSearchState> build() async {
    final history = await SearchService.getSearchHistory();
    final vendorTypes = await ref.read(_vendorTypeRequestProvider).index();
    bool showServices = false;
    bool showProducts = false;
    for (final vt in vendorTypes) {
      if (vt.isService || vt.isBooking) {
        showServices = true;
      } else if (vt.isProduct) {
        showProducts = true;
      }
    }
    final initial = MainSearchState(
      search: Search(),
      searchHistory: history,
      showServices: showServices,
      showProducts: showProducts,
      showVendors: showServices || showProducts,
    );
    state = AsyncData(initial);
    await startSearch();
    return state.valueOrNull ?? initial;
  }

  void setKeyword(String value) {
    final cur = state.valueOrNull;
    if (cur == null) return;
    state = AsyncData(cur.copyWith(keyword: value));
  }

  Future<void> startSearch({bool initialLoading = true}) async {
    final cur = state.valueOrNull;
    if (cur == null) return;
    final futures = <Future>[];
    if (cur.showProducts) {
      futures.add(_searchProducts(initial: initialLoading));
    }
    if (cur.showVendors) {
      futures.add(_searchVendors(initial: initialLoading));
    }
    if (cur.showServices) {
      futures.add(_searchServices(initial: initialLoading));
    }
    await Future.wait(futures);
  }

  Future<void> _searchVendors({required bool initial}) async {
    final cur = state.valueOrNull;
    if (cur == null || cur.search == null) return;
    final page = initial ? 1 : (cur.vendorsPage + 1);
    try {
      final results =
          (await ref
              .read(_searchRequestProvider)
              .searchRequest(
                keyword: cur.keyword,
                search: cur.search!,
                type: 'vendor',
                page: page,
              )).cast<Vendor>();
      final cur2 = state.valueOrNull;
      if (cur2 == null) return;
      state = AsyncData(
        cur2.copyWith(
          vendors: initial ? results : [...cur2.vendors, ...results],
          vendorsPage: page,
        ),
      );
    } catch (_) {}
  }

  Future<void> _searchProducts({required bool initial}) async {
    final cur = state.valueOrNull;
    if (cur == null || cur.search == null) return;
    final page = initial ? 1 : (cur.productsPage + 1);
    try {
      final results =
          (await ref
              .read(_searchRequestProvider)
              .searchRequest(
                keyword: cur.keyword,
                search: cur.search!,
                type: 'product',
                page: page,
              )).cast<Product>();
      final cur2 = state.valueOrNull;
      if (cur2 == null) return;
      state = AsyncData(
        cur2.copyWith(
          products: initial ? results : [...cur2.products, ...results],
          productsPage: page,
        ),
      );
    } catch (_) {}
  }

  Future<void> _searchServices({required bool initial}) async {
    final cur = state.valueOrNull;
    if (cur == null || cur.search == null) return;
    final page = initial ? 1 : (cur.servicesPage + 1);
    try {
      final results =
          (await ref
              .read(_searchRequestProvider)
              .searchRequest(
                keyword: cur.keyword,
                search: cur.search!,
                type: 'service',
                page: page,
              )).cast<Service>();
      final cur2 = state.valueOrNull;
      if (cur2 == null) return;
      state = AsyncData(
        cur2.copyWith(
          services: initial ? results : [...cur2.services, ...results],
          servicesPage: page,
        ),
      );
    } catch (_) {}
  }

  Future<void> loadMoreVendors() => _searchVendors(initial: false);
  Future<void> loadMoreProducts() => _searchProducts(initial: false);
  Future<void> loadMoreServices() => _searchServices(initial: false);

  Future<void> refreshAll() => startSearch();

  void updateSearch(Search newSearch) {
    final cur = state.valueOrNull;
    if (cur == null) return;
    state = AsyncData(cur.copyWith(search: newSearch));
    startSearch();
  }
}

final mainSearchControllerProvider =
    AsyncNotifierProvider<MainSearchController, MainSearchState>(
      MainSearchController.new,
    );
