import 'dart:io';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:upgrader/upgrader.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/pages/profile/profile.page.dart';
import 'package:fuodz/utils/app_routes.dart';
import 'package:fuodz/utils/extensions/router.dart';
import 'package:fuodz/pages/welcome/welcome.page.dart';
import 'package:fuodz/providers/home_providers.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/location.service.dart';
import 'package:fuodz/services/navigation.service.dart';
import 'package:fuodz/utils/app_colors.dart';
import 'package:fuodz/utils/app_strings.dart';
import 'package:fuodz/utils/app_ui_settings.dart';
import 'package:fuodz/utils/app_upgrade_settings.dart';

import 'order/orders.page.dart';
import 'search/main_search.page.dart';
import 'welcome/widgets/cart.fab.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  @override
  bool get wantKeepAlive => true;

  Widget? _homeView;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (LocationService.currenctAddress == null) {
        LocationService.prepareLocationListener(true);
      }
      _computeHomeView();
      await ref.read(homeControllerProvider.notifier).initialise();
      AppService().handlePendingDeepLink();
    });
  }

  Future<void> _computeHomeView() async {
    Widget view = WelcomePage();
    if (AppStrings.isSingleVendorMode) {
      final vendorType = VendorType.fromJson(AppStrings.enabledVendorType);
      view = NavigationService.vendorTypePage(vendorType, context: context);
      if (vendorType.authRequired && !AuthServices.authenticated()) {
        if (!mounted) return;
        await context.pushRoute(AppRoutes.loginRoute, extra: true);
      }
    }
    if (!mounted) return;
    setState(() => _homeView = view);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(homeControllerProvider);
    final notifier = ref.read(homeControllerProvider.notifier);
    return DoubleBack(
      message: "Press back again to close".tr(),
      child: BasePage(
        backgroundColor: AppColor.faintBgColor,
        body: SafeArea(
          child: UpgradeAlert(
            showIgnore: !AppUpgradeSettings.forceUpgrade(),
            shouldPopScope: () => !AppUpgradeSettings.forceUpgrade(),
            dialogStyle:
                Platform.isIOS
                    ? UpgradeDialogStyle.cupertino
                    : UpgradeDialogStyle.material,
            upgrader: Upgrader(),
            child: PageView(
              controller: notifier.pageController,
              onPageChanged: notifier.onPageChanged,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _homeView ?? WelcomePage(),
                MainSearchPage(),
                const OrdersPage(),
                ProfilePage(),
              ],
            ),
          ),
        ),
        fab: AppUISettings.showCart ? const CartHomeFab() : null,
        fabLocation:
            AppUISettings.showCart
                ? FloatingActionButtonLocation.centerDocked
                : null,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: context.backgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, -2),
                blurRadius: 8,
              ),
            ],
          ),
          child: SafeArea(
            child: AnimatedBottomNavigationBar.builder(
              itemCount: 4,
              backgroundColor: Theme.of(context).colorScheme.surface,
              blurEffect: false,
              elevation: 0,
              activeIndex: state.currentIndex,
              onTap: notifier.onTabChange,
              gapLocation:
                  AppUISettings.showCart
                      ? GapLocation.center
                      : GapLocation.none,
              notchSmoothness: NotchSmoothness.defaultEdge,
              leftCornerRadius: 0,
              rightCornerRadius: 0,
              splashSpeedInMilliseconds: 10,
              tabBuilder: (int index, bool isActive) {
                final color =
                    isActive ? AppColor.primaryColor : const Color(0xff879092);
                const titles = ["Home", "Explore", "Booking", "Profile"];
                const icons = [
                  HugeIcons.strokeRoundedHome03,
                  HugeIcons.strokeRoundedSearch01,
                  HugeIcons.strokeRoundedInboxUnread,
                  HugeIcons.strokeRoundedUser,
                ];
                const filledIcons = [
                  HugeIcons.strokeRoundedHome02,
                  HugeIcons.strokeRoundedSearch01,
                  HugeIcons.strokeRoundedInbox,
                  HugeIcons.strokeRoundedUser,
                ];
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isActive ? filledIcons[index] : icons[index],
                      size: 22,
                      color: color,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(0.5),
                      child:
                          titles[index]
                              .tr()
                              .text
                              .scale(0.89)
                              .fontWeight(
                                isActive ? FontWeight.bold : FontWeight.normal,
                              )
                              .color(color)
                              .make(),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
