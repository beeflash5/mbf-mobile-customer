import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/models/product.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/services/location.service.dart';
import 'package:fuodz/services/product.request.dart';
import 'package:fuodz/services/service.request.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/product_fetch_data_type.enum.dart';

final _productRequestProvider =
    Provider<ProductRequest>((_) => ProductRequest());
final _serviceRequestProvider =
    Provider<ServiceRequest>((_) => ServiceRequest());

/// Args for both `products` and `home_products`. `isHome=true` matches the
/// legacy HomeProductsViewModel behaviour (sets `is_home=1`).
typedef ProductsListingArgs = ({
  int vendorTypeId,
  ProductFetchDataType type,
  int categoryId,
  bool byLocation,
  bool isHome,
});

class ProductsListingController
    extends FamilyAsyncNotifier<List<Product>, ProductsListingArgs> {
  @override
  Future<List<Product>> build(ProductsListingArgs arg) async {
    final params = <String, dynamic>{
      if (arg.categoryId != 0) 'category_id': arg.categoryId,
      if (arg.vendorTypeId != 0) 'vendor_type_id': arg.vendorTypeId,
      'type': arg.type.name.toLowerCase(),
      if (arg.isHome) 'is_home': true,
    };
    final useLocation =
        arg.byLocation || AppStrings.enableFatchByLocation;
    final coords = LocationService.currenctAddress?.coordinates;
    if (useLocation && coords?.latitude != null) {
      params['latitude'] = coords!.latitude;
      params['longitude'] = coords.longitude;
    }
    return ref.read(_productRequestProvider).getProdcuts(queryParams: params);
  }
}

final productsListingControllerProvider = AsyncNotifierProvider.family<
    ProductsListingController, List<Product>, ProductsListingArgs>(
  ProductsListingController.new,
);

// =====================================================================
// HOME SERVICES (best services) — family by vendorTypeId (0 = all)
// =====================================================================
class HomeBestServicesController
    extends FamilyAsyncNotifier<List<Service>, int> {
  @override
  Future<List<Service>> build(int arg) async {
    return ref.read(_serviceRequestProvider).getServices(
      page: 1,
      queryParams: {
        'type': 'best',
        if (arg != 0) 'vendor_type_id': arg,
        'direction': 'desc',
      },
    );
  }
}

final homeBestServicesControllerProvider = AsyncNotifierProvider.family<
    HomeBestServicesController, List<Service>, int>(
  HomeBestServicesController.new,
);
