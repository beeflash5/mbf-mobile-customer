import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/app_routes.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/constants/home_screen.config.dart';
import 'package:fuodz/extensions/string.dart';
import 'package:fuodz/models/search.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/services/navigation.service.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/welcome.vm.dart';
import 'package:fuodz/views/pages/vendor/widgets/banners.view.dart';
import 'package:fuodz/views/pages/vendor/widgets/banners_top.view.dart';
import 'package:fuodz/views/pages/vendor/widgets/section_vendors.view.dart';
import 'package:fuodz/widgets/cards/custom.visibility.dart';
import 'package:fuodz/widgets/cards/welcome_intro.view.dart';
import 'package:fuodz/widgets/custom_dynamic_grid_view.dart';
import 'package:fuodz/widgets/custom_list_view.dart';
import 'package:fuodz/widgets/finance/wallet_management.view.dart';
import 'package:fuodz/widgets/list_items/vendor_type.list_item.dart';
import 'package:fuodz/widgets/list_items/vendor_type.vertical_list_item.dart';
import 'package:fuodz/widgets/list_items/vendor_type_home_list_item.dart';
import 'package:fuodz/widgets/states/loading.shimmer.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:masonry_grid/masonry_grid.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../../constants/app_images.dart';
import '../../../../widgets/base.page.dart';
import '../../../../widgets/list_items/vendor_type_home_more.dart';

class AllVendor extends StatelessWidget {
  const AllVendor({required this.vm, Key? key}) : super(key: key);

  final WelcomeViewModel vm;
  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      appBarItemColor: context.primaryColor,

      showLeadingAction: true,
      elevation: 0,
      title: "Semua Layanan",
      appBarColor: context.backgroundColor,
      showCart: false,
      // key: model.pageKey,
      body:
          VStack([
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: DynamicHeightGridView(
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 4,
                  itemCount: vm.vendorTypes.length,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  builder: (context, index) {
                    final vendorType = vm.vendorTypes[index];
                    return VendorTypeHomeListItem(
                      vendorType,
                      onPressed: () {
                        if (!vm.isAuthenticated() &&
                            (vendorType.slug == 'taxi' ||
                                vendorType.slug == 'bike')) {
                          vm.openLogin();
                        } else {
                          NavigationService.pageSelected(
                            vendorType,
                            context: context,
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ]).scrollVertical(),
    );
  }
}
