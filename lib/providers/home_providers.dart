import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/services/cart.service.dart';
import 'package:fuodz/services/local_storage.service.dart';
import 'package:fuodz/services/setup.service.dart';

class HomeState {
  const HomeState({
    this.currentIndex = 0,
    this.totalCartItems = 0,
  });
  final int currentIndex;
  final int totalCartItems;

  HomeState copyWith({
    int? currentIndex,
    int? totalCartItems,
  }) =>
      HomeState(
        currentIndex: currentIndex ?? this.currentIndex,
        totalCartItems: totalCartItems ?? this.totalCartItems,
      );
}

class HomeController extends Notifier<HomeState> {
  StreamSubscription? _cartCountSub;
  StreamSubscription? _pageIndexSub;
  PageController? _pageController;

  PageController get pageController =>
      _pageController ??= PageController(initialPage: 0);

  @override
  HomeState build() {
    ref.onDispose(() {
      _cartCountSub?.cancel();
      _pageIndexSub?.cancel();
      _pageController?.dispose();
    });
    return const HomeState();
  }

  Future<void> initialise() async {
    _cartCountSub?.cancel();
    _cartCountSub = LocalStorageService.rxPrefs
        ?.getIntStream(CartServices.totalItemKey)
        .listen((total) {
      if (total != null) {
        state = state.copyWith(totalCartItems: total);
      }
    });

    _pageIndexSub?.cancel();
    _pageIndexSub = AppService().homePageIndex.stream.listen(onTabChange);

    await SetupService.init();
  }

  void onPageChanged(int index) {
    state = state.copyWith(currentIndex: index);
  }

  void onTabChange(int index) {
    state = state.copyWith(currentIndex: index);
    try {
      pageController.animateToPage(
        index,
        duration: const Duration(microseconds: 5),
        curve: Curves.bounceInOut,
      );
    } catch (_) {}
  }
}

final homeControllerProvider =
    NotifierProvider<HomeController, HomeState>(HomeController.new);
