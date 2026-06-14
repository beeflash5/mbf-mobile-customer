import 'package:flutter/material.dart';
import 'package:fuodz/utils/app_routes.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:go_router/go_router.dart';
import 'package:fuodz/models/category.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/models/search.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/pages/booking/booking.page.dart';
import 'package:fuodz/pages/commerce/commerce.page.dart';
import 'package:fuodz/pages/food/food.page.dart';
import 'package:fuodz/pages/grocery/grocery.page.dart';
import 'package:fuodz/pages/parcel/parcel.page.dart';
import 'package:fuodz/pages/pharmacy/pharmacy.page.dart';
import 'package:fuodz/pages/product/amazon_styled_commerce_product_details.page.dart';
import 'package:fuodz/pages/product/product_details.page.dart';
import 'package:fuodz/pages/search/product_search.page.dart';
import 'package:fuodz/pages/search/search.page.dart';
import 'package:fuodz/pages/search/service_search.page.dart';
import 'package:fuodz/pages/service/custom_service_booking_data.page.dart';
// import 'package:fuodz/pages/service/service.page.dart';
import 'package:fuodz/pages/taxi/taxi.page.dart';
import 'package:fuodz/pages/vendor/vendor.page.dart';

class NavigationService {
  static pageSelected(
    VendorType vendorType, {
    required BuildContext context,
    bool loadNext = true,
  }) async {
    Widget nextpage = vendorTypePage(vendorType, context: context);

    //
    if (vendorType.authRequired && !AuthServices.authenticated()) {
      final result = await context.pushRoute<bool>(
        AppRoutes.loginRoute,
        extra: true,
      );
      if (result == null || !result) {
        return;
      }
    }
    //
    if (loadNext) {
      // Use go_router with a custom page route for dynamic vendor-type pages.
      // The destination widget is computed locally by `vendorTypePage()`
      // because each vendor type maps to a different page implementation.
      GoRouter.of(context).push('/vendor-type', extra: nextpage);
    }
  }

  static Widget vendorTypePage(
    VendorType vendorType, {
    required BuildContext context,
  }) {
    Widget homeView = VendorPage(vendorType);
    switch (vendorType.slug) {
      case "parcel":
        homeView = ParcelPage(vendorType);
        break;
      case "grocery":
        homeView = GroceryPage(vendorType);
        break;
      case "food":
        homeView = FoodPage(vendorType);
        break;
      case "pharmacy":
        homeView = PharmacyPage(vendorType);
        break;
      case "service":
      case "accommodation":
      case "accommodations":
      case "tour":
      case "tours":
      case "tattoo":
        // if (vendorType.name == 'Booking') {
        homeView = ServicesBookingPage(vendorType);
        // } else {
        //   homeView = ServicesPage(vendorType);
        // }
        // homeView = ServicePage(vendorType);

        break;
      case "booking":
        homeView = BookingPage(vendorType);
        break;
      case "taxi":
        homeView = TaxiPage(vendorType);
        break;
      case "bike":
        homeView = TaxiPage(vendorType);
        break;
      case "commerce":
        homeView = CommercePage(vendorType);
        break;
      default:
        homeView = VendorPage(vendorType);
        break;
    }
    return homeView;
  }

  ///special for product page
  Widget productDetailsPageWidget(Product product) {
    if (!product.vendor.vendorType.isCommerce) {
      return ProductDetailsPage(product: product);
    } else {
      return AmazonStyledCommerceProductDetailsPage(product: product);
    }
  }

  //
  Widget searchPageWidget(Search search) {
    if (search.vendorType == null) {
      return SearchPage(search: search);
    }
    //
    if (search.vendorType!.isProduct) {
      return ProductSearchPage(search: search);
    } else if (search.vendorType!.isService) {
      return ServiceSearchPage(
        category: search.category,
        vendorType: search.vendorType,
        byLocation: search.byLocation ?? true,
        showVendors: search.showProvidesTag || search.showProvidesTag,
        showServices: search.showServicesTag,
        // showVendors: search.showVendors(),
        // showServices: search.showServices(),
      );
    } else {
      return SearchPage(search: search);
    }
  }

  //open service search — dispatched via /search route
  static openServiceSearch(
    BuildContext context, {
    Category? category,
    VendorType? vendorType,
    bool showVendors = true,
    bool showServices = true,
    bool byLocation = true,
  }) {
    final search = Search(
      vendorType: vendorType,
      category: category,
      byLocation: byLocation,
      showVendorsTag: showVendors,
      showServicesTag: showServices,
      showProvidesTag: showVendors,
    );
    GoRouter.of(context).push('/search', extra: search);
  }

  static openVendorDetailsPage(Vendor vendor, {required BuildContext context}) {
    GoRouter.of(context).push('/vendors/${vendor.id}', extra: vendor);
  }

  static void openCategoriesPage({VendorType? vendorType}) {
    final ctx = AppService().navigatorKey.currentContext;
    if (ctx == null) return;
    GoRouter.of(ctx).push('/categories', extra: vendorType);
  }

  static categorySelected(Category category) async {
    final ctx = AppService().navigatorKey.currentContext;
    if (ctx == null) return;
    if (category.hasSubcategories) {
      GoRouter.of(ctx).push('/categories/${category.id}/sub', extra: category);
    } else {
      final search = Search(
        vendorType: category.vendorType,
        category: category,
        showProductsTag: !(category.vendorType?.isService ?? false),
        showVendorsTag: !(category.vendorType?.isService ?? false),
        showServicesTag: (category.vendorType?.isService ?? false),
        showProvidesTag: (category.vendorType?.isService ?? false),
      );
      GoRouter.of(ctx).push('/search', extra: search);
    }
  }

  static void openServiceDetails(Service service) {
    final ctx = AppService().navigatorKey.currentContext;
    if (ctx == null) return;
    GoRouter.of(
      ctx,
    ).push('${AppRoutes.serviceDetails}/${service.id}', extra: service);
  }
}
