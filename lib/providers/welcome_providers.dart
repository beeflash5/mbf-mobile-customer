import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

import 'package:fuodz/models/blog.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/models/user.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/models/wallet.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/category.request.dart';
import 'package:fuodz/services/location.service.dart';
import 'package:fuodz/services/order.request.dart';
import 'package:fuodz/services/vendor_type.request.dart';
import 'package:fuodz/services/wallet.request.dart';

import 'package:fuodz/services/payment_method.request.dart';

final _vendorTypeRequestProvider =
    Provider<VendorTypeRequest>((_) => VendorTypeRequest());
final _orderRequestProvider =
    Provider<OrderRequest>((_) => OrderRequest());
final _walletRequestProvider =
    Provider<WalletRequest>((_) => WalletRequest());
final _categoryRequestProvider =
    Provider<CategoryRequest>((_) => CategoryRequest());
final _paymentMethodRequestProvider =
    Provider<PaymentMethodRequest>((_) => PaymentMethodRequest());

class WelcomeState {
  const WelcomeState({
    this.vendorTypes = const [],
    this.flashSales = const [],
    this.bestSelling = const [],
    this.topRated = const [],
    this.orders = const [],
    this.blogs = const [],
    this.wallet,
    this.currentUser,
  });
  final List<VendorType> vendorTypes;
  final List<Product> flashSales;
  final List<Service> bestSelling;
  final List<Service> topRated;
  final List<Order> orders;
  final List<Blog> blogs;
  final Wallet? wallet;
  final User? currentUser;

  WelcomeState copyWith({
    List<VendorType>? vendorTypes,
    List<Product>? flashSales,
    List<Service>? bestSelling,
    List<Service>? topRated,
    List<Order>? orders,
    List<Blog>? blogs,
    Wallet? wallet,
    User? currentUser,
  }) =>
      WelcomeState(
        vendorTypes: vendorTypes ?? this.vendorTypes,
        flashSales: flashSales ?? this.flashSales,
        bestSelling: bestSelling ?? this.bestSelling,
        topRated: topRated ?? this.topRated,
        orders: orders ?? this.orders,
        blogs: blogs ?? this.blogs,
        wallet: wallet ?? this.wallet,
        currentUser: currentUser ?? this.currentUser,
      );
}

sealed class WalletTopupResult {
  const WalletTopupResult();
}

class WalletTopupSuccess extends WalletTopupResult {
  const WalletTopupSuccess(this.link);
  final String link;
}

class WalletTopupFailure extends WalletTopupResult {
  const WalletTopupFailure(this.message);
  final String message;
}

class WelcomeController extends AsyncNotifier<WelcomeState> {
  StreamSubscription? _locSub;
  StreamSubscription? _authSub;
  int _blogPage = 1;
  bool _blogHasMore = true;

  @override
  Future<WelcomeState> build() async {
    ref.onDispose(() {
      _locSub?.cancel();
      _authSub?.cancel();
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('campaign_data');

    _locSub?.cancel();
    _locSub = LocationService.currenctDeliveryAddressSubject
        .skipWhile((_) => true)
        .listen((_) => refresh());

    _authSub?.cancel();
    _authSub = AuthServices.listenToAuthState().listen((_) => refresh());

    return _load();
  }

  Future<WelcomeState> _load() async {
    User? currentUser;
    if (AuthServices.authenticated()) {
      currentUser = await AuthServices.getCurrentUser(force: true);
    }

    final vendorTypes =
        await ref.read(_vendorTypeRequestProvider).index();
    final topRated = await ref.read(_categoryRequestProvider).topService();
    final bestSelling =
        await ref.read(_categoryRequestProvider).bestService();
    _blogPage = 1;
    _blogHasMore = true;
    final blogs = await _loadBlogs(1, 2);
    final flashSales = await ref.read(_categoryRequestProvider).flashSales();
    final orders = await ref.read(_orderRequestProvider).getOrders(page: 1);
    Wallet? wallet;
    if (AuthServices.authenticated()) {
      try {
        wallet = await ref.read(_walletRequestProvider).walletBalance();
      } catch (_) {}
    }
    return WelcomeState(
      vendorTypes: vendorTypes,
      topRated: topRated,
      bestSelling: bestSelling,
      blogs: blogs,
      flashSales: flashSales,
      orders: orders,
      wallet: wallet,
      currentUser: currentUser,
    );
  }

  Future<List<Blog>> _loadBlogs(int page, int perPage) async {
    try {
      return await ref
          .read(_categoryRequestProvider)
          .blogs(page: page, perPage: perPage);
    } catch (_) {
      return const [];
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> loadMoreBlogs() async {
    if (!_blogHasMore) return;
    final cur = state.valueOrNull;
    if (cur == null) return;
    _blogPage++;
    final more = await _loadBlogs(_blogPage, 2);
    if (more.isEmpty) {
      _blogHasMore = false;
      _blogPage--;
      return;
    }
    state = AsyncData(cur.copyWith(blogs: [...cur.blogs, ...more]));
  }

  Future<WalletTopupResult> initiateWalletTopUp(String amount) async {
    try {
      int? paymentMethodId;
      try {
        final paymentMethods = await ref.read(_paymentMethodRequestProvider).getPaymentOptions();
        final activeMethods = paymentMethods.where((m) => m.isActive == 1 && m.isCash == 0).toList();
        if (activeMethods.isNotEmpty) {
          final topupMethod = activeMethods.firstWhere(
            (m) => m.slug.toLowerCase().contains('xendit') || m.slug.toLowerCase().contains('midtrans'),
            orElse: () => activeMethods.first,
          );
          paymentMethodId = topupMethod.id;
        }
      } catch (e) {
        print("Error fetching payment methods for topup: $e");
      }

      final link =
          await ref.read(_walletRequestProvider).walletTopup(amount, paymentMethodId: paymentMethodId);
      return WalletTopupSuccess(link);
    } catch (e) {
      return WalletTopupFailure('$e');
    }
  }

  Future<void> refreshWallet() async {
    if (!AuthServices.authenticated()) return;
    try {
      final wallet = await ref.read(_walletRequestProvider).walletBalance();
      final cur = state.valueOrNull;
      if (cur != null) state = AsyncData(cur.copyWith(wallet: wallet));
    } catch (_) {}
  }
}

final welcomeControllerProvider =
    AsyncNotifierProvider<WelcomeController, WelcomeState>(
  WelcomeController.new,
);
