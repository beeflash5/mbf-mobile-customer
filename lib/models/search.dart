import 'package:fuodz/utils/product_fetch_data_type.enum.dart';
import 'package:fuodz/models/category.dart';
import 'package:fuodz/models/delivery_address.dart';
import 'package:fuodz/models/tag.dart';
import 'package:fuodz/models/vendor_type.dart';

class Search {
  String? type = "";
  Category? category;
  Category? subcategory;
  VendorType? vendorType;
  int? vendorId;
  // int? showType;
  // SearchType? viewType;
  bool? byLocation = false;
  bool showProductsTag = false;
  bool showVendorsTag = false;
  bool showServicesTag = false;
  bool showProvidesTag = false;
  String? sort;
  String? layoutType = "grid";
  String? minPrice;
  String? maxPrice;
  List<Tag>? tags = [];
  ProductFetchDataType? productDataFetchType;

  DeliveryAddress? deliveryAddress;
  int? ratting;

  Search({
    this.type = "",
    this.category,
    this.subcategory,
    this.vendorType,
    this.vendorId,
    this.byLocation = false,
    this.showProductsTag = false,
    this.showVendorsTag = false,
    this.showServicesTag = false,
    this.showProvidesTag = false,
    this.ratting,
    this.productDataFetchType,
    this.deliveryAddress,
    // this.viewType = SearchType.vendorProducts,
    // this.showType,
  });

  void genApiType(int selectTagId) {
    switch (selectTagId) {
      case 1:
        type = "vendor";
        break;
      case 2:
        type = "product";
        break;
      case 3:
        type = "service";
        break;
      default:
        type = "product";
    }
  }

  // bool showOnlyVendors() {
  //   // 1 = vendors
  //   // 2 = products
  //   // 3 = services
  //   // 4 = vendors & products
  //   // 5 = vendors & services
  //   return showType == 1;
  // }

  // bool showVendors() {
  //   List<int> showTypeCheckes = [1, 4, 5];
  //   List<SearchType> viewTypeCheckes = [
  //     SearchType.vendors,
  //     SearchType.vendorProducts,
  //     SearchType.vendorServices
  //   ];
  //   return viewTypeCheckes.contains(viewType) ||
  //       showTypeCheckes.contains(showType);
  // }

  // bool showProducts() {
  //   return ([SearchType.vendorProducts, SearchType.products]
  //           .contains(viewType)) ||
  //       [2, 4].contains(showType);
  // }

  // bool showServices() {
  //   return ([SearchType.vendorServices, SearchType.services]
  //           .contains(viewType)) ||
  //       [3, 5].contains(showType);
  // }

  //MIsc.s
  static bool showProductByShowType(int showtype) {
    return [2, 4].contains(showtype);
  }

  static bool showServiceByShowType(int showtype) {
    return [3, 5].contains(showtype);
  }

  static bool showVendorByShowType(int showtype) {
    return [1, 4].contains(showtype);
  }

  static bool showProvidersByShowType(int showtype) {
    return [1, 5].contains(showtype);
  }
}

// enum SearchType {
//   vendors,
//   products,
//   services,
//   vendorProducts,
//   vendorServices,
// }

enum SearchFilterType { best, sales, you, fresh, discount, featured }
