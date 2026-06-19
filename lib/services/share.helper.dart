import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'package:fuodz/constants/api.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/models/vendor.dart';

class ShareHelper {
  static Future<void> shareProduct(Product product) async {
    String shareLink;
    if (product.shareable_link != null && product.shareable_link!.isNotEmpty) {
      shareLink = product.shareable_link!;
    } else if (product.deep_link != null && product.deep_link!.isNotEmpty) {
      shareLink = product.deep_link!;
    } else {
      shareLink =
          '${Api.appShareLink}/product/${product.id}/${slugify(product.name)}';
    }
    await Share.share(
      shareLink,
      sharePositionOrigin: const Rect.fromLTWH(0, 0, 100, 100),
    );
  }

  static Future<void> shareVendor(Vendor vendor) async {
    String shareLink;
    if (vendor.shareable_link != null && vendor.shareable_link!.isNotEmpty) {
      shareLink = vendor.shareable_link!;
    } else if (vendor.deep_link != null && vendor.deep_link!.isNotEmpty) {
      shareLink = vendor.deep_link!;
    } else {
      shareLink =
          "${Api.appShareLink}/partner/${vendor.id}/${slugify(vendor.name)}";
    }
    await Share.share(
      shareLink,
      sharePositionOrigin: const Rect.fromLTWH(0, 0, 100, 100),
    );
  }

  static Future<void> shareService(Service service) async {
    String shareLink;
    if (service.shareable_link != null && service.shareable_link!.isNotEmpty) {
      shareLink = service.shareable_link!;
    } else if (service.deep_link != null && service.deep_link!.isNotEmpty) {
      shareLink = service.deep_link!;
    } else {
      shareLink =
          "${Api.appShareLink}/service/${service.id}/${slugify(service.name)}";
    }
    await Share.share(
      shareLink,
      sharePositionOrigin: const Rect.fromLTWH(0, 0, 100, 100),
    );
  }

  static String slugify(String text) {
    return text
        .replaceAll("'", " ") 
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-');
  }
}
