import 'package:fuodz/pages/profile/faq.page.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:fuodz/models/category.dart';
import 'package:fuodz/models/checkout.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/models/coupon.dart';
import 'package:fuodz/models/flash_sale.dart';
import 'package:fuodz/models/order_product.dart';
import 'package:fuodz/pages/auth/forgot_password.page.dart';
import 'package:fuodz/pages/auth/login.page.dart';
import 'package:fuodz/pages/auth/register.page.dart';
import 'package:fuodz/pages/cart/cart.page.dart';
import 'package:fuodz/pages/category/categories.page.dart';
import 'package:fuodz/pages/category/subcategories.page.dart';
import 'package:fuodz/pages/checkout/checkout.page.dart';
import 'package:fuodz/pages/checkout/multiple_order_checkout.page.dart';
import 'package:fuodz/pages/coupon/coupon_details.page.dart';
import 'package:fuodz/pages/delivery_address/delivery_addresses.page.dart';
import 'package:fuodz/pages/delivery_address/new_delivery_addresses.page.dart';
import 'package:fuodz/pages/favourite/favourites.page.dart';
import 'package:fuodz/pages/flash_sale/flash_sale.page.dart';
import 'package:fuodz/pages/home.page.dart';
import 'package:fuodz/pages/loyalty/loyalty_point.page.dart';
import 'package:fuodz/pages/notification/notifications.page.dart';
import 'package:fuodz/pages/order/orders.page.dart';
import 'package:fuodz/pages/chat/order_chat.page.dart';
import 'package:fuodz/pages/review/post_product_review.page.dart';
import 'package:fuodz/pages/review/product_reviews.page.dart';
import 'package:fuodz/pages/vendor/vendor_reviews.page.dart';
import 'package:fuodz/pages/order/orders_details.page.dart';
import 'package:fuodz/pages/order/orders_tracking.page.dart';
import 'package:fuodz/pages/order/taxi_order_details.page.dart';
import 'package:fuodz/pages/parcel/new_parcel.page.dart';
import 'package:fuodz/pages/pharmacy/pharmacy_upload_prescription.page.dart';
import 'package:fuodz/pages/product/product_details.page.dart';
import 'package:fuodz/models/currency.dart';
import 'package:fuodz/pages/profile/account_delete.page.dart';
import 'package:fuodz/pages/profile/change_password.page.dart';
import 'package:fuodz/pages/profile/currency_selection.page.dart';
import 'package:fuodz/pages/profile/edit_profile.page.dart';
import 'package:fuodz/pages/profile/profile.page.dart';
import 'package:fuodz/models/search.dart';
import 'package:fuodz/pages/search/product_search.page.dart';
import 'package:fuodz/pages/search/search.page.dart';
import 'package:fuodz/pages/search/service_search.page.dart';
import 'package:fuodz/pages/service/service_booking_summary.page.dart';
import 'package:fuodz/pages/service/service_details.page.dart';
import 'package:fuodz/pages/splash.page.dart';
import 'package:fuodz/pages/taxi/taxi.page.dart';
import 'package:fuodz/pages/vendor_details/vendor_category_products.page.dart';
import 'package:fuodz/pages/vendor_details/vendor_details.page.dart';
import 'package:fuodz/pages/wallet/wallet.page.dart';
import 'package:fuodz/pages/welcome/welcome.page.dart';
import 'package:fuodz/services/app.service.dart';

/// Centralised go_router config. Routes are organized by section.
///
/// Pages that require object arguments (Product/Order/Vendor/etc.) receive
/// them via `extra` because Dart objects can't be serialised to query params.
/// This is the standard go_router pattern for typed payloads.
class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: AppService().navigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (_, __) => const WelcomePage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (_, __) => const HomePage(),
      ),

      // Auth
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (_, state) {
          final required = state.extra is bool ? state.extra as bool : false;
          return LoginPage(required: required);
        },
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (_, __) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (_, __) => const ForgotPasswordPage(),
      ),

      // Profile
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (_, __) => const ProfilePage(),
      ),
      GoRoute(
        path: '/profile/edit',
        name: 'edit-profile',
        builder: (_, __) => const EditProfilePage(),
      ),
      GoRoute(
        path: '/profile/change-password',
        name: 'change-password',
        builder: (_, __) => const ChangePasswordPage(),
      ),
      GoRoute(
        path: '/profile/account-delete',
        name: 'account-delete',
        builder: (_, __) => const AccountDeletePage(),
      ),
      GoRoute(
        path: '/profile/currency',
        name: 'currency-selection',
        builder: (_, state) {
          final cur = state.extra is Currency ? state.extra as Currency : null;
          return CurrencySelectionPage(currentCurrency: cur);
        },
      ),

      // Cart & checkout
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (_, __) => const CartPage(),
      ),
      GoRoute(
        path: '/checkout',
        name: 'checkout',
        builder: (_, state) {
          final checkout = state.extra as CheckOut;
          return CheckoutPage(checkout: checkout);
        },
      ),
      GoRoute(
        path: '/checkout/multiple',
        name: 'multiple-checkout',
        builder: (_, state) {
          final checkout = state.extra as CheckOut;
          return MultipleOrderCheckoutPage(checkout: checkout);
        },
      ),

      GoRoute(
        path: '/orders',
        name: 'orders',
        builder: (_, __) => const OrdersPage(),
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return OrderChatPage(
            orderCode: extra['orderCode'] ?? '',
            chatType: extra['chatType'] ?? 'customerVendor',
            receiverId: extra['receiverId'] ?? 0,
          );
        },
      ),
      GoRoute(
        path: '/orders/:id',
        name: 'order-details',
        builder: (_, state) {
          final order = state.extra as Order;
          return OrderDetailsPage(order: order);
        },
      ),
      GoRoute(
        path: '/orders/:id/tracking',
        name: 'order-tracking',
        builder: (_, state) {
          final order = state.extra as Order;
          return OrderTrackingPage(order: order);
        },
      ),
      GoRoute(
        path: '/orders/:id/taxi',
        name: 'taxi-order-details',
        builder: (_, state) {
          final order = state.extra as Order;
          return TaxiOrderDetailPage(order: order);
        },
      ),

      // Product / service / vendor
      GoRoute(
        path: '/products/:id',
        name: 'product-details',
        builder: (_, state) {
          final product = state.extra as Product;
          return ProductDetailsPage(product: product);
        },
      ),
      GoRoute(
        path: '/services/:id',
        name: 'service-details',
        builder: (_, state) {
          final service = state.extra as Service;
          return ServiceDetailsPage(service);
        },
      ),
      GoRoute(
        path: '/services/:id/booking',
        name: 'service-booking-summary',
        builder: (_, state) {
          final service = state.extra as Service;
          return ServiceBookingSummaryPage(service);
        },
      ),
      GoRoute(
        path: '/vendors/:id',
        name: 'vendor-details',
        builder: (_, state) {
          final vendor = state.extra as Vendor;
          return VendorDetailsPage(vendor: vendor);
        },
      ),
      GoRoute(
        path: '/vendors/:id/categories/:catId',
        name: 'vendor-category-products',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>;
          return VendorCategoryProductsPage(
            vendor: extra['vendor'] as Vendor,
            category: extra['category'] as Category,
          );
        },
      ),

      // Delivery addresses
      GoRoute(
        path: '/delivery-addresses',
        name: 'delivery-addresses',
        builder: (_, __) => const DeliveryAddressesPage(),
      ),
      GoRoute(
        path: '/delivery-addresses/new',
        name: 'new-delivery-address',
        builder: (_, __) => const NewDeliveryAddressesPage(),
      ),

      // Favourites
      GoRoute(
        path: '/favourites',
        name: 'favourites',
        builder: (_, __) => const FavouritesPage(),
      ),

      // Wallet & loyalty
      GoRoute(
        path: '/wallet',
        name: 'wallet',
        builder: (_, __) => const WalletPage(),
      ),
      GoRoute(
        path: '/loyalty',
        name: 'loyalty',
        builder: (_, __) => LoyaltyPointPage(),
      ),

      // Notifications
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (_, __) => const NotificationsPage(),
      ),

      GoRoute(
        path: '/search',
        name: 'search',
        builder: (_, state) {
          final search = state.extra as Search;
          // Mirror NavigationService.searchPageWidget dispatch so any caller
          // can use `/search` regardless of search type.
          if (search.vendorType == null) {
            return SearchPage(search: search);
          }
          if (search.vendorType!.isProduct) {
            return ProductSearchPage(search: search);
          }
          if (search.vendorType!.isService) {
            return ServiceSearchPage(
              category: search.category,
              vendorType: search.vendorType,
              byLocation: search.byLocation ?? true,
              showVendors: search.showProvidesTag || search.showProvidesTag,
              showServices: search.showServicesTag,
            );
          }
          return SearchPage(search: search);
        },
      ),

      // Parcel
      GoRoute(
        path: '/parcel/new',
        name: 'new-parcel',
        builder: (_, state) {
          final vendorType = state.extra as VendorType;
          return NewParcelPage(vendorType);
        },
      ),

      // Pharmacy
      GoRoute(
        path: '/pharmacy/upload-prescription',
        name: 'pharmacy-upload',
        builder: (_, state) {
          final vendor = state.extra as Vendor;
          return PharmacyUploadPrescription(vendor);
        },
      ),

      // Taxi
      GoRoute(
        path: '/taxi',
        name: 'taxi',
        builder: (_, state) {
          final vendorType = state.extra as VendorType;
          return TaxiPage(vendorType);
        },
      ),

      // Reviews
      GoRoute(
        path: '/products/:id/reviews',
        name: 'product-reviews',
        builder: (_, state) {
          final product = state.extra as Product;
          return ProductReviewsPage(product);
        },
      ),
      GoRoute(
        path: '/products/review/post',
        name: 'post-product-review',
        builder: (_, state) {
          final op = state.extra as OrderProduct;
          return PostProductReviewPage(op);
        },
      ),
      GoRoute(
        path: '/vendors/:id/reviews',
        name: 'vendor-reviews',
        builder: (_, state) {
          final vendor = state.extra as Vendor;
          return VendorReviewsPage(vendor);
        },
      ),

      // Coupons & flash sale
      GoRoute(
        path: '/coupons/:id',
        name: 'coupon-details',
        builder: (_, state) {
          final coupon = state.extra as Coupon;
          return CouponDetailsPage(coupon);
        },
      ),
      GoRoute(
        path: '/flash-sales/:id',
        name: 'flash-sale-items',
        builder: (_, state) {
          final fs = state.extra as FlashSale;
          return FlashSaleItemsPage(fs);
        },
      ),

      // Categories
      GoRoute(
        path: '/categories',
        name: 'categories',
        builder: (_, state) {
          final vt =
              state.extra is VendorType ? state.extra as VendorType : null;
          return CategoriesPage(vendorType: vt);
        },
      ),
      GoRoute(
        path: '/categories/:id/sub',
        name: 'subcategories',
        builder: (_, state) {
          final cat = state.extra as Category;
          return SubcategoriesPage(category: cat);
        },
      ),

      // Vendor-type dispatch — payload is the prebuilt Widget chosen by
      // NavigationService.vendorTypePage() based on slug. Lets imperative
      // callers use go_router uniformly without spinning up dozens of routes.
      GoRoute(
        path: '/vendor-type',
        name: 'vendor-type',
        builder: (_, state) => (state.extra as Widget?) ?? const SplashPage(),
      ),

      // Generic widget escape hatch for callers that compose pages locally
      // (e.g. wrappers passing extra config to a page constructor). Avoid
      // for new code — add a typed route instead. Existing migrated callers
      // use context.pushWidget(WidgetInstance) which routes through here.
      GoRoute(
        path: '/_w',
        name: 'widget-push',
        builder: (_, state) => (state.extra as Widget?) ?? const SplashPage(),
      ),

      // FAQ
      GoRoute(
        path: '/faq',
        name: 'faq',
        builder: (_, __) => const FaqPage(),
      ),
    ],
  );
}
