import 'package:fuodz/services/auth.service.dart';

class Api {
  // REST API → Spring backend (api.mybalifriendz.co). The endpoint paths below
  // are served by Spring, ported 1:1 from the old Laravel routes.
  static String get baseUrl {
    return "https://api.mybalifriendz.co/api";
    // return "https://mybalifriendz.co/api";
    // return "http://192.168.1.6:8000/api";
  }

  // Web pages (terms/privacy/support/share), the web→app auth redirect and
  // Laravel Echo/Reverb broadcasting are NOT served by Spring — they stay on
  // the Laravel web app. Derived from the API host by default; override here.
  static String get webBaseUrl {
    return "https://mybalifriendz.co";
  }

  static const appSettings = "/app/settings";
  static const appOnboardings = "/app/onboarding?type=customer";
  static const faqs = "/app/faqs?type=customer";

  static const accountDelete = "/account/delete";
  static const tokenSync = "/device/token/sync";
  static const login = "/login";
  static const login_handphone = "/login/phone";
  static const qrlogin = "/login/qrcode";
  static const register = "/register";
  static const logout = "/logout";
  static const forgotPassword = "/password/reset/init";
  static const verifyPhoneAccount = "/verify/phone";
  static const updateProfile = "/profile/update";
  static const updatePassword = "/profile/password/update";
  //
  static const sendOtp = "/otp/send";
  static const verifyOtp = "/otp/verify";
  static const verifyFirebaseOtp = "/otp/firebase/verify";
  static const socialLogin = "/social/login";
  static const socialLoginAppleAndroid = "/social/loginAppleAndroid";

  //
  static const banners = "/banners";
  static const ads1 = "/banners_ads";
  static const categories = "/categories";
  static const flashsales = "/flash/sales/home";
  static const bestService = "/bestService";
  static const topService = "/topService";
  static const blogs = "/blogs";
  static const products = "/products";
  static const services = "/services";
  static const bestProducts = "/products?type=best";
  static const forYouProducts = "/products?type=you";
  static const vendorTypes = "/vendor/types";
  static const destination = "/destination";
  static const vendors = "/vendors";
  static const vendor_table_use = "/vendor/table_use";
  static const vendor_date_use = "/vendor/date_use";
  static const vendor_time_use = "/vendor/time_use";
  static const vendorReviews = "/vendor/reviews";
  static const topVendors = "/vendors?type=top";
  static const bestVendors = "/vendors?type=best";

  static const search = "/search";
  static const tags = "/tags";
  static const searchData = "/search/data";
  static const favourites = "/favourites";
  static const favouriteVendors = "/favourite/vendors";

  //cart & checkout
  static const coupons = "/coupons";
  static const deliveryAddresses = "/delivery/addresses";
  static const paymentMethods = "/payment/methods";
  static const orders = "/orders";
  static const confirm = "/order/confirm";
  static const order_checkin = "/order/checkin";
  static const trackOrder = "/track/order";
  static const syncDriverLocation = "/orders/{order}/driver/location/sync";
  static const packageOrders = "/package/orders";
  static const packageOrderSummary = "/package/order/summary";
  static const generalOrderDeliveryFeeSummary =
      "/general/order/delivery/fee/summary";
  static const generalOrderSummary = "/general/order/summary";
  static const serviceOrderSummary = "/service/order/summary";
  static const chat = "/chat/notification";
  static const rating = "/rating";
  static const vendor_reshedule = "/vendor/reshedule";

  //packages
  static const packageTypes = "/package/types";
  static const packageVendors = "/package/order/vendors";
  static const packageVendorPricings = "/package/vendor/{id}/pricings";
  static const packageVendorAreaOfOperations =
      "/package/vendor/{id}/area/of/operations";

  //Taxi booking
  static const vehicleTypes = "/vehicle/types";
  static const vehicleTypePricing = "/vehicle/types/pricing";
  static const newTaxiBooking = "/taxi/book/order";
  static const currentTaxiBooking = "/taxi/current/order";
  static const lastRatebleTaxiBooking = "/taxi/rateable/order";
  static const cancelTaxiBooking = "/taxi/order/cancel";
  static const taxiDriverInfo = "/taxi/driver/info";
  static const taxiLocationAvailable = "/taxi/location/available";
  static const taxiTripLocationHistory = "/taxi/location/history";

  //wallet
  static const walletBalance = "/wallet/balance";
  static const walletTopUp = "/wallet/topup";
  static const walletTransactions = "/wallet/transactions";
  static const myWalletAddress = "/wallet/my/address";
  static const walletAddressesSearch = "/wallet/address/search";
  static const walletTransfer = "/wallet/address/transfer";

  //loyaltypoints
  static const myLoyaltyPoints = "/loyalty/point/my";
  static const loyaltyPointsWithdraw = "/loyalty/point/my/withdraw";
  static const loyaltyPointsReport = "/loyalty/point/my/report";

  //map
  static const geocoderForward = "/geocoder/forward";
  static const geocoderReserve = "/geocoder/2/reserve";
  static const geocoderPlaceDetails = "/geocoder/place/details";

  //reviews
  static const productReviewSummary = "/product/review/summary";
  static const productReviews = "/product/reviews";
  static const productBoughtFrequent = "/product/frequent";

  //flash sales
  static const flashSales = "/flash/sales";
  static const externalRedirect = "/external/redirect";

  //
  static const cancellationReasons = "/cancellation/reasons";

  // Other pages
  static String get privacyPolicy {
    final webUrl = webBaseUrl;
    return "$webUrl/privacy";
  }

  static String get terms {
    final webUrl = webBaseUrl;
    return "$webUrl/terms";
  }

  static String get paymentTerms {
    final webUrl = webBaseUrl;
    return "$webUrl/terms";
  }

  static String get refundTerms {
    final webUrl = webBaseUrl;
    return "$webUrl/terms";
  }

  static String get cancelTerms {
    final webUrl = webBaseUrl;
    return "$webUrl/terms";
  }

  static String get shippingTerms {
    final webUrl = webBaseUrl;
    return "$webUrl/terms";
  }

  static String get contactUs {
    final webUrl = webBaseUrl;
    return "$webUrl/contact";
  }

  static String get contactUsWeb {
    final webUrl = webBaseUrl;
    return "$webUrl/contact";
  }

  static String get inappSupport {
    final webUrl = webBaseUrl;
    return "$webUrl/support/chat";
  }

  static String get appShareLink {
    final webUrl = webBaseUrl;
    return "$webUrl/";
  }

  static Future<String> redirectAuth({String? url, String? route}) async {
    final userToken = await AuthServices.getAuthBearerToken();
    final webUrl = "$webBaseUrl/external/web/redirect";
    return "$webUrl?token=$userToken&route=$route&url=$url";
  }
}
