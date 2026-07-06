import 'package:fuodz/constants/api.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/services/api_service.dart';

class FavouriteRequest extends ApiService {
  //
  Future<List<Product>> favourites() async {
    final apiResult = await get(Api.favourites);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      List<Product> products = [];
      apiResponse.data.forEach((jsonObject) {
        try {
          if (jsonObject["product"] != null) {
            products.add(Product.fromJson(jsonObject["product"]));
          }
        } catch (error) {
          print("error: $error");
        }
      });
      return products;
    }

    throw apiResponse.message!;
  }

  //
  Future<List<Service>> favouriteServices() async {
    final apiResult = await get(Api.favourites);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      List<Service> services = [];
      apiResponse.data.forEach((jsonObject) {
        try {
          if (jsonObject["service"] != null) {
            services.add(Service.fromJson(jsonObject["service"]));
          }
        } catch (error) {
          print("error: $error");
        }
      });
      return services;
    }

    throw apiResponse.message!;
  }

  //
  Future<ApiResponse> makeFavourite(int id) async {
    final apiResult = await post(Api.favourites, {"product_id": id});

    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> makeFavouriteService(int id) async {
    final apiResult = await post(Api.favourites, {"service_id": id});

    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> removeFavourite(int productId) async {
    final apiResult = await delete(Api.favourites + "/$productId");
    return ApiResponse.fromResponse(apiResult);
  }

  //vendor
  Future<List<Vendor>> favouriteVendors() async {
    final apiResult = await get(Api.favouriteVendors);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      List<Vendor> dataset = [];
      apiResponse.data.forEach((jsonObject) {
        try {
          dataset.add(Vendor.fromJson(jsonObject["vendor"]));
        } catch (error) {
          print("error: $error");
        }
      });
      return dataset;
    }

    throw apiResponse.message!;
  }

  //
  Future<ApiResponse> makeFavouriteVendor(int id) async {
    final apiResult = await post(Api.favouriteVendors, {"vendor_id": id});

    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> removeFavouriteVendor(int vendorId) async {
    final apiResult = await delete("${Api.favouriteVendors}/$vendorId");
    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<Map<String, List<int>>> getFavouriteIds() async {
    final apiResult = await get("${Api.favourites}/ids");
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      try {
        final data = apiResponse.body as Map<String, dynamic>;
        final productIds = (data['product_ids'] as List).map((e) => e as int).toList();
        final serviceIds = (data['service_ids'] as List).map((e) => e as int).toList();
        return {
          'product_ids': productIds,
          'service_ids': serviceIds,
        };
      } catch (e) {
        return {'product_ids': [], 'service_ids': []};
      }
    }
    throw apiResponse.message!;
  }
}
