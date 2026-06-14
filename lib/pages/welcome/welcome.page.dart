import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/component/custom_easy_refresh_view.dart';
import 'package:fuodz/providers/welcome_providers.dart';
import 'package:fuodz/utils/home_screen.config.dart';

class WelcomePage extends ConsumerStatefulWidget {
  const WelcomePage({super.key});

  @override
  ConsumerState<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends ConsumerState<WelcomePage>
    with AutomaticKeepAliveClientMixin<WelcomePage> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BasePage(
      body: CustomEasyRefreshView(
        headerView: MaterialHeader(),
        onRefresh: () => ref.read(welcomeControllerProvider.notifier).refresh(),
        child: HomeScreenConfig.homeScreen(),
      ),
    );
  }
}
