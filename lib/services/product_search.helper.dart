import 'package:fuodz/models/category.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/pages/search/products.page.dart';
import 'package:fuodz/pages/search/service_search.page.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/utils/extensions/context.dart';
import 'package:fuodz/utils/product_fetch_data_type.enum.dart';

/// Helper replacement for `ProductSearchTrait` mixin so widgets can open the
/// "see all" pages without holding a ViewModel instance.
class ProductSearchHelper {
  static Future<void> openProductsSeeAllPage({
    required String title,
    ProductFetchDataType type = ProductFetchDataType.RANDOM,
    VendorType? vendorType,
    Category? category,
    bool showGrid = true,
  }) async {
    final context = AppService().navigatorKey.currentContext;
    context!.push(
      (context) => ProducsPage(
        title: title,
        vendorType: vendorType,
        type: type,
        category: category,
        showGrid: showGrid,
      ),
    );
  }

  static Future<void> openServicesSeeAllPage({
    required String title,
    ProductFetchDataType type = ProductFetchDataType.RANDOM,
    VendorType? vendorType,
    Category? category,
    bool showGrid = true,
  }) async {
    final context = AppService().navigatorKey.currentContext;
    context!.push(
      (context) => ServiceSearchPage(
        vendorType: vendorType,
        byLocation: false,
      ),
    );
  }
}
