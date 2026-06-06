import 'package:flutter/material.dart';

import 'package:fuodz/component/base.page.dart';
import 'package:fuodz/pages/search/main_search.page.dart';

class MainSearchHomePage extends StatelessWidget {
  const MainSearchHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      showCart: true,
      body: const MainSearchPage(),
    );
  }
}
