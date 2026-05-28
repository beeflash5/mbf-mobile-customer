import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fuodz/extensions/context.dart';
import 'package:fuodz/models/blog.dart';
import 'package:fuodz/models/category.dart';
import 'package:fuodz/models/destination.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/models/search.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/models/user.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/models/wallet.dart';
import 'package:fuodz/requests/category.request.dart';
import 'package:fuodz/requests/order.request.dart';
import 'package:fuodz/requests/vendor_type.request.dart';
import 'package:fuodz/requests/wallet.request.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/location.service.dart';
import 'package:fuodz/services/navigation.service.dart';
import 'package:fuodz/services/toast.service.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:fuodz/views/pages/search/search.page.dart';
import 'package:fuodz/views/pages/vendor/featured_vendors.page.dart';
import 'package:fuodz/widgets/bottomsheets/wallet_amount_entry.bottomsheet.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

class WelcomeViewModel extends MyBaseViewModel {
  //
  WelcomeViewModel(BuildContext context) {
    this.viewContext = context;
  }

  Widget? selectedPage;
  List<VendorType> vendorTypes = [];
  List<Category> categories = [];
  List<Blog> blogs = [];
  VendorTypeRequest vendorTypeRequest = VendorTypeRequest();
  bool showGrid = true;
  StreamSubscription? authStateSub;
  final ScrollController scrollController = ScrollController();
  double opacity = 0.0;

  RefreshController homeRefreshController = RefreshController();
  WalletRequest walletRequest = WalletRequest();

  Wallet? wallet;
  List<Destination> destinations = [];

  List<Product> flashSales = [];
  List<Order> orders = [];
  List<Service> bestSelling = [];
  List<Service> topRated = [];
  OrderRequest orderRequest = OrderRequest();
  User? currentUser;

  //
  //
  initialise({bool initial = true}) async {
    final prefs = await SharedPreferences.getInstance();

    // hapus campaign
    await prefs.remove('campaign_data');

    if (AuthServices.authenticated()) {
      currentUser = await AuthServices.getCurrentUser(force: true);
      notifyListeners();
    }

    scrollController.addListener(() {
      // double offset = scrollController.offset;
      // double newOpacity = (offset / 100).clamp(0.0, 1.0); // 200px scroll penuh
      // // print("testing New Opacity ==> $newOpacity");
      // if (newOpacity != opacity) {
      //   opacity = newOpacity;
      //   notifyListeners();
      // }
    });
    //
    preloadDeliveryLocation();
    //
    if (refreshController.isRefresh) {
      refreshController.refreshCompleted();
    }

    if (!initial) {
      pageKey = GlobalKey();
      notifyListeners();
    }

    await getVendorTypes();
    await topServices();
    await getBestSelling();
    await getBlogs();
    await getFlashSale();
    await fetchMyOrders();

    // await getDestination();
    // await getServiceCategories();

    listenToAuth();
    //
    handleLocationStream();

    if (AuthServices.authenticated()) {
      await getWalletBalance();
    }
  }

  fetchMyOrders({bool initialLoading = true}) async {
    try {
      final mOrders = await orderRequest.getOrders(page: 1);
      if (!initialLoading) {
        orders.addAll(mOrders);
      } else {
        orders = mOrders;
      }
      clearErrors();
    } catch (error) {
      print("Order Error ==> $error");
      setError(error);
    }

    setBusy(false);
  }

  categorySelected(Category category) async {
    NavigationService.categorySelected(category);
  }

  getServiceCategories() async {
    //
    categories.clear();
    setBusyForObject(categories, true);
    try {
      categories = await CategoryRequest().categories(
        vendorTypeId: vendorType?.id,
        page: 1,
        perPage: 10,
        customParams: {"order_by": "services", "is_home": true},
      );
    } catch (error) {
      print("Error ==> $error");
    }
    setBusyForObject(categories, false);
  }

  getFlashSale() async {
    //
    flashSales.clear();
    setBusyForObject(flashSales, true);
    try {
      flashSales = await CategoryRequest().flashSales();
      notifyListeners();
    } catch (error) {
      print("Error flashsale ==> $error");
    }
    setBusyForObject(flashSales, false);
  }

  getBestSelling() async {
    //
    bestSelling.clear();
    setBusyForObject(flashSales, true);
    try {
      bestSelling = await CategoryRequest().bestService();
      notifyListeners();
    } catch (error) {
      print("Error getBestSelling ==> $error");
    }
    setBusyForObject(bestSelling, false);
  }

  topServices() async {
    //
    topRated.clear();
    setBusyForObject(flashSales, true);
    try {
      topRated = await CategoryRequest().topService();
      notifyListeners();
    } catch (error) {
      print("Error topServices ==> $error");
    }
    setBusyForObject(topRated, false);
  }

  int blogPage = 1;
  int blogPerPage = 2;
  bool blogHasMore = true;
  getBlogs() async {
    if (!blogHasMore) return;

    setBusyForObject(blogs, true);

    try {
      final newBlogs = await CategoryRequest().blogs(
        page: blogPage,
        perPage: blogPerPage,
      );

      if (newBlogs.isEmpty) {
        blogHasMore = false;
      } else {
        blogs.addAll(newBlogs);
        blogPage++;
      }

      notifyListeners();
    } catch (error) {
      print("Error ==> $error");
    }

    setBusyForObject(blogs, false);
  }

  getWalletBalance() async {
    setBusy(true);
    try {
      wallet = await walletRequest.walletBalance();
      clearErrors();
    } catch (error) {
      setError(error);
    }
    setBusy(false);
  }

  showAmountEntry() {
    showModalBottomSheet(
      context: viewContext,
      isScrollControlled: true,
      builder: (context) {
        return WalletAmountEntryBottomSheet(
          onSubmit: (String amount) {
            context.pop();
            initiateWalletTopUp(amount);
          },
        );
      },
    );
  }

  initiateWalletTopUp(String amount) async {
    setBusy(true);

    try {
      final link = await walletRequest.walletTopup(amount);
      await openExternalWebpageLink(link);
      clearErrors();
    } catch (error) {
      setError(error);
    }
    setBusy(false);
  }

  Future<dynamic> openExternalWebpageLink(String url) async {
    try {
      final result = await launchUrlString(
        url,
        mode: LaunchMode.externalApplication,
      );
      return result;
    } catch (error) {
      ToastService.toastError("$error");
    }
    return null;
  }

  StreamSubscription? currentLocSub;
  StreamSubscription? currentLoc2Sub;
  handleLocationStream() async {
    await currentLocSub?.cancel();
    currentLocSub = LocationService.currenctDeliveryAddressSubject
        .skipWhile((_) => true)
        .listen((event) {
          initialise(initial: false);
        });

    await currentLoc2Sub?.cancel();
    currentLoc2Sub = LocationService.currenctDeliveryAddressSubject.stream
        .skipWhile((_) => true)
        .listen((event) {
          initialise(initial: false);
        });
  }

  listenToAuth() {
    authStateSub = AuthServices.listenToAuthState().listen((event) {
      genKey = GlobalKey();
      notifyListeners();
    });
  }

  getVendorTypes() async {
    setBusy(true);
    try {
      vendorTypes = await vendorTypeRequest.index();
      clearErrors();
    } catch (error) {
      setError(error);
    }
    setBusy(false);
  }

  getDestination() async {
    setBusy(true);
    try {
      destinations = await vendorTypeRequest.destination();
      clearErrors();
    } catch (error) {
      setError(error);
    }
    setBusy(false);
  }

  openSearchPage(BuildContext context, VendorType? vendorType) async {
    NavigationService.openServiceSearch(
      viewContext,
      byLocation: false, // AppStrings.enableFatchByLocation,
      vendorType: vendorType,
      showServices: true,
      showVendors: false,
    );
    //
    // final search = Search(
    //   // type: type.name,
    //   // category: category,
    //   vendorType: vendorType,
    //   showServicesTag: true,

    //   // showType: 2,
    // );
    // //open search
    // context.push((context) => SearchPage(search: search));
  }

  openFeaturedVendors() async {
    Navigator.of(
      viewContext,
    ).push(MaterialPageRoute(builder: (context) => FeaturedVendorsPage()));
  }
}
