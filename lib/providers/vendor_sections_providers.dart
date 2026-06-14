import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/models/category.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/models/search.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/services/category.request.dart';
import 'package:fuodz/services/product.request.dart';
import 'package:fuodz/services/service.request.dart';
import 'package:fuodz/services/vendor.request.dart';
import 'package:fuodz/utils/app_strings.dart';

final _productRequestProvider = Provider<ProductRequest>(
  (_) => ProductRequest(),
);
final _serviceRequestProvider = Provider<ServiceRequest>(
  (_) => ServiceRequest(),
);
final _categoryRequestProvider = Provider<CategoryRequest>(
  (_) => CategoryRequest(),
);
final _vendorRequestProvider = Provider<VendorRequest>((_) => VendorRequest());

// Best-selling products by vendorTypeId (0 = no filter).
class BestSellingProductsController
    extends FamilyAsyncNotifier<List<Product>, int> {
  @override
  Future<List<Product>> build(int arg) async {
    return ref
        .read(_productRequestProvider)
        .bestProductsRequest(
          queryParams: {if (arg != 0) 'vendor_type_id': arg},
        );
  }
}

final bestSellingProductsControllerProvider = AsyncNotifierProvider.family<
  BestSellingProductsController,
  List<Product>,
  int
>(BestSellingProductsController.new);

// For-you products by vendorTypeId (0 = no filter).
class ForYouProductsController extends FamilyAsyncNotifier<List<Product>, int> {
  @override
  Future<List<Product>> build(int arg) async {
    return ref
        .read(_productRequestProvider)
        .forYouProductsRequest(
          queryParams: {if (arg != 0) 'vendor_type_id': arg},
        );
  }
}

final forYouProductsControllerProvider =
    AsyncNotifierProvider.family<ForYouProductsController, List<Product>, int>(
      ForYouProductsController.new,
    );

// Categories by vendorTypeId (0 = no filter).
typedef VendorCategoriesArgs = ({int vendorTypeId, int? page});

class VendorCategoriesController
    extends FamilyAsyncNotifier<List<Category>, VendorCategoriesArgs> {
  @override
  Future<List<Category>> build(VendorCategoriesArgs arg) async {
    return ref
        .read(_categoryRequestProvider)
        .categories(
          vendorTypeId: arg.vendorTypeId == 0 ? null : arg.vendorTypeId,
          page: arg.page,
        );
  }
}

final vendorCategoriesControllerProvider = AsyncNotifierProvider.family<
  VendorCategoriesController,
  List<Category>,
  VendorCategoriesArgs
>(VendorCategoriesController.new);

// Subcategories under a parent category.
class SubcategoriesController extends FamilyAsyncNotifier<List<Category>, int> {
  @override
  Future<List<Category>> build(int arg) async {
    return ref.read(_categoryRequestProvider).subcategories(categoryId: arg);
  }
}

final subcategoriesControllerProvider =
    AsyncNotifierProvider.family<SubcategoriesController, List<Category>, int>(
      SubcategoriesController.new,
    );

// Popular services by vendorTypeId (0 = no filter).
class PopularServicesController
    extends FamilyAsyncNotifier<List<Service>, int> {
  @override
  Future<List<Service>> build(int arg) async {
    return ref
        .read(_serviceRequestProvider)
        .getServices(
          byLocation: AppStrings.enableFatchByLocation,
          queryParams: {if (arg != 0) 'vendor_type_id': arg},
        );
  }
}

final popularServicesControllerProvider =
    AsyncNotifierProvider.family<PopularServicesController, List<Service>, int>(
      PopularServicesController.new,
    );

// Section vendors by (vendorTypeId, search-filter type, byLocation).
typedef SectionVendorsArgs =
    ({int vendorTypeId, SearchFilterType type, bool byLocation});

class SectionVendorsController
    extends FamilyAsyncNotifier<List<Vendor>, SectionVendorsArgs> {
  @override
  Future<List<Vendor>> build(SectionVendorsArgs arg) async {
    return ref
        .read(_vendorRequestProvider)
        .vendorsRequest(
          byLocation: arg.byLocation,
          params: {
            if (arg.vendorTypeId != 0) 'vendor_type_id': arg.vendorTypeId,
            'type': arg.type.name,
          },
        );
  }
}

final sectionVendorsControllerProvider = AsyncNotifierProvider.family<
  SectionVendorsController,
  List<Vendor>,
  SectionVendorsArgs
>(SectionVendorsController.new);

// Featured vendors paginated list.
class FeaturedVendorsState {
  const FeaturedVendorsState({
    this.vendors = const [],
    this.page = 1,
    this.isLoadingMore = false,
  });
  final List<Vendor> vendors;
  final int page;
  final bool isLoadingMore;

  FeaturedVendorsState copyWith({
    List<Vendor>? vendors,
    int? page,
    bool? isLoadingMore,
  }) => FeaturedVendorsState(
    vendors: vendors ?? this.vendors,
    page: page ?? this.page,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}

class FeaturedVendorsController extends AsyncNotifier<FeaturedVendorsState> {
  @override
  Future<FeaturedVendorsState> build() async {
    final vendors = await ref
        .read(_vendorRequestProvider)
        .vendorsRequest(page: 1, params: {'type': 'featured'});
    return FeaturedVendorsState(vendors: vendors, page: 1);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final vendors = await ref
          .read(_vendorRequestProvider)
          .vendorsRequest(page: 1, params: {'type': 'featured'});
      return FeaturedVendorsState(vendors: vendors, page: 1);
    });
  }

  Future<void> loadMore() async {
    final cur = state.valueOrNull;
    if (cur == null || cur.isLoadingMore) return;
    state = AsyncData(cur.copyWith(isLoadingMore: true));
    try {
      final next = cur.page + 1;
      final more = await ref
          .read(_vendorRequestProvider)
          .vendorsRequest(page: next, params: {'type': 'featured'});
      state = AsyncData(
        cur.copyWith(
          vendors: [...cur.vendors, ...more],
          page: next,
          isLoadingMore: false,
        ),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final featuredVendorsControllerProvider =
    AsyncNotifierProvider<FeaturedVendorsController, FeaturedVendorsState>(
      FeaturedVendorsController.new,
    );
