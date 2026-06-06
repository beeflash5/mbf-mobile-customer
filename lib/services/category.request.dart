import 'package:fuodz/constants/api.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/models/blog.dart';
import 'package:fuodz/models/category.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/services/api_service.dart';

class CategoryRequest extends ApiService {
  //
  Future<List<Category>> categories({
    int? vendorTypeId,
    int? page,
    int? perPage,
    Map<String, dynamic>? customParams,
  }) async {
    Map<String, dynamic> params = {
      "vendor_type_id": vendorTypeId,
      "page": page,
      "per_page": perPage,
      "full": page == null ? 1 : 0,
    };

    if (customParams != null) {
      params.addAll(customParams);
    }
    final apiResult = await get(Api.categories, queryParameters: params);

    final apiResponse = ApiResponse.fromResponse(apiResult);

    if (apiResponse.allGood) {
      return (apiResponse.data)
          .map((jsonObject) => Category.fromJson(jsonObject))
          .toList();
    } else {
      throw apiResponse.message!;
    }
  }

  Future<List<Product>> flashSales() async {
    final apiResult = await get(Api.flashsales);

    final apiResponse = ApiResponse.fromResponse(apiResult);

    if (apiResponse.allGood) {
      return (apiResponse.data)
          .map((jsonObject) => Product.fromJson(jsonObject))
          .toList();
    } else {
      throw apiResponse.message!;
    }
  }

  Future<List<Service>> bestService() async {
    final apiResult = await get(Api.bestService);

    final apiResponse = ApiResponse.fromResponse(apiResult);

    print("testing best service = ${apiResponse.body}");
    if (apiResponse.allGood) {
      return (apiResponse.data)
          .map((jsonObject) => Service.fromJson(jsonObject))
          .toList();
    } else {
      throw apiResponse.message!;
    }
  }

  Future<List<Service>> topService() async {
    final apiResult = await get(Api.topService);

    final apiResponse = ApiResponse.fromResponse(apiResult);

    if (apiResponse.allGood) {
      return (apiResponse.data)
          .map((jsonObject) => Service.fromJson(jsonObject))
          .toList();
    } else {
      throw apiResponse.message!;
    }
  }

  Future<List<Service>> bestSelling() async {
    final apiResult = await get(Api.flashsales);

    final apiResponse = ApiResponse.fromResponse(apiResult);

    if (apiResponse.allGood) {
      return (apiResponse.data)
          .map((jsonObject) => Service.fromJson(jsonObject))
          .toList();
    } else {
      throw apiResponse.message!;
    }
  }

  Future<List<Blog>> blogs({int page = 1, int perPage = 2}) async {
    final apiResult = await get(
      Api.blogs,
      queryParameters: {"page": page, "per_page": perPage},
    );

    final apiResponse = ApiResponse.fromResponse(apiResult);

    print("testing blog ==> ${apiResponse.data}");

    if (apiResponse.allGood) {
      return (apiResponse.data)
          .map((jsonObject) => Blog.fromJson(jsonObject))
          .toList();
    } else {
      throw apiResponse.message!;
    }
  }

  Future<List<Category>> subcategories({int? categoryId, int? page}) async {
    final apiResult = await get(
      //
      Api.categories,
      queryParameters: {"category_id": categoryId, "page": page, "type": "sub"},
    );

    final apiResponse = ApiResponse.fromResponse(apiResult);

    if (apiResponse.allGood) {
      return apiResponse.data
          .map((jsonObject) => Category.fromJson(jsonObject))
          .toList();
    } else {
      throw apiResponse.message!;
    }
  }
}
