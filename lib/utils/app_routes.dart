/// go_router path constants. Use with `context.push(AppRoutes.X)` or
/// `context.go(AppRoutes.X)`. For routes that take payloads, pass via
/// `extra:` — see [AppRouter] for the schema.
class AppRoutes {
  static const welcomeRoute = "/welcome";
  static const loginRoute = "/login";
  static const editProfileRoute = "/profile/edit";
  static const changePasswordRoute = "/profile/change-password";
  static const registerRoute = "/register";
  static const forgotPasswordRoute = "/forgot-password";
  static const homeRoute = "/home";
  static const notificationsRoute = "/notifications";
  static const notificationDetailsRoute = "/notifications/details";

  static const vendorDetails = "/vendors";
  static const product = "/products";
  static const serviceDetails = "/services";
  static const search = "/search";

  static const checkoutRoute = "/checkout";
  static const orderDetailsRoute = "/orders";
  static const chatRoute = "/chat";

  static const deliveryAddressesRoute = "/delivery-addresses";
  static const newDeliveryAddressesRoute = "/delivery-addresses/new";
  static const editDeliveryAddressesRoute = "/delivery-addresses/edit";

  static const favouritesRoute = "/favourites";
  static const walletRoute = "/wallet";
  static const orderTrackingRoute = "/orders/tracking";
}
