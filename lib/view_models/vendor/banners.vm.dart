import 'dart:convert';

import 'package:flutter/material.dart' hide Banner;
import 'package:fuodz/models/banner.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/requests/banner.request.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:fuodz/constants/app_routes.dart';
import 'package:fuodz/models/search.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';

class BannersViewModel extends MyBaseViewModel {
  BannersViewModel(
    BuildContext context,
    this.vendorType, {
    this.featured = false,
  }) {
    this.viewContext = context;
  }
  //
  BannerRequest _bannerRequest = BannerRequest();
  bool featured;
  VendorType? vendorType;
  //
  List<Banner> banners = [];
  List<Banner> banneBotoms = [];
  int currentIndex = 0;
  List<Banner> ads1 = [];
  List<Banner> ads2 = [];

  initialiseAds1() async {
    setBusy(true);
    try {
      ads1 = await _bannerRequest.ads(
        vendorTypeId: vendorType?.id,
        params: {"ads1": 1},
      );
      clearErrors();
    } catch (error) {
      setError("testing error ${error}");
    }
    setBusy(false);
  }

  initialiseAds2() async {
    setBusy(true);
    try {
      ads2 = await _bannerRequest.ads(
        vendorTypeId: vendorType?.id,
        params: {"ads2": 1},
      );
      clearErrors();
    } catch (error) {
      setError(error);
    }
    setBusy(false);
  }

  //
  initialise() async {
    setBusy(true);
    try {
      banners = await _bannerRequest.banners(
        vendorTypeId: vendorType?.id,
        params: {"featured": featured ? "1" : "0"},
      );
      clearErrors();
    } catch (error) {
      setError(error);
    }
    setBusy(false);
  }

  initialiseBannerBottom() async {
    setBusy(true);
    try {
      banneBotoms = await _bannerRequest.banners(
        vendorTypeId: vendorType?.id,
        params: {"featured": featured ? "1" : "0"},
      );
      clearErrors();
    } catch (error) {
      setError(error);
    }
    setBusy(false);
    notifyListeners();
  }

  //
  bannerSelected(Banner banner) async {
    if (banner.link != null && banner.link.isNotEmptyAndNotNull) {
      openWebpageLink(banner.link!);
    } else if (banner.vendor != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('campaign_data', jsonEncode(banner.toJson()));

      Navigator.of(
        viewContext,
      ).pushNamed(AppRoutes.vendorDetails, arguments: banner.vendor);
    } else {
      Navigator.of(viewContext).pushNamed(
        AppRoutes.search,
        arguments: Search(category: banner.category, byLocation: false),
      );
    }
  }
}
