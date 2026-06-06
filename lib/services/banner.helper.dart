import 'dart:convert';
import 'package:fuodz/utils/extensions/router.dart';

import 'package:flutter/material.dart' hide Banner;
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:fuodz/models/banner.dart';
import 'package:fuodz/models/search.dart';
import 'package:fuodz/pages/vendor_details/vendor_details.page.dart';
import 'package:fuodz/services/payment.helper.dart';
import 'package:fuodz/services/navigation.service.dart';

class BannerHelper {
  static Future<void> bannerSelected(
    BuildContext context,
    Banner banner,
  ) async {
    if (banner.link != null && banner.link.isNotEmptyAndNotNull) {
      await PaymentHelper.openWebpageLink(context, banner.link!);
    } else if (banner.vendor != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('campaign_data', jsonEncode(banner.toJson()));
      if (!context.mounted) return;
      context.pushWidget(VendorDetailsPage(vendor: banner.vendor!));
    } else {
      final search = Search(category: banner.category, byLocation: false);
      context.pushWidget(NavigationService().searchPageWidget(search));
    }
  }
}
