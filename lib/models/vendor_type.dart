// To parse this JSON data, do
//
//     final vendorType = vendorTypeFromJson(jsonString);

import 'dart:convert';

import 'package:fuodz/utils/local_storage.service.dart';
import 'package:fuodz/utils/extensions/string.dart';

VendorType vendorTypeFromJson(String str) =>
    VendorType.fromJson(json.decode(str));

String vendorTypeToJson(VendorType data) => json.encode(data.toJson());

class VendorType {
  VendorType({
    required this.id,
    required this.name,
    required this.description,
    required this.slug,
    required this.color,
    required this.isActive,
    required this.logo,
    required this.website_header,
    required this.hasBanners,
  });

  int id;
  String name;
  String description;
  String slug;
  String color;
  int isActive;
  String logo;
  String website_header;
  bool hasBanners;

  factory VendorType.fromJson(Map<String, dynamic> json) => VendorType(
    id: json["id"] ?? 0,
    name: (json["name"] ?? "").toString().parseLocalized(),
    description: (json["description"] ?? "").toString().parseLocalized(),
    slug: json["slug"] ?? "",
    color:
        json["color"] == null
            ? colorEnv("primaryColor")
            : (json["color"].toString().length == 7
                ? json["color"]
                : colorEnv("primaryColor")),
    isActive: json["is_active"] ?? 0,
    logo: json["logo"] ?? "",
    website_header: json["website_header"] ?? "",
    hasBanners:
        json["has_banners"] == null
            ? false
            : ((json["has_banners"] is bool)
                ? json["has_banners"]
                : int.parse(json["has_banners"].toString()) == 1),
  );

  bool get isProduct {
    return [
      "food",
      "grocery",
      "commerce",
      "e-commerce",
    ].contains(slug.toLowerCase());
  }

  bool get isService => [
    "service",
    "services",
    "tour",
    "tattoo",
    "booking",
    "bookings",
  ].contains(slug.toLowerCase());
  bool get isBooking =>
      ["booking", "bookings", "tour", "tattoo"].contains(slug.toLowerCase());

  bool get isGrocery => slug == "grocery";

  bool get isFood => slug == "food";

  bool get isCommerce =>
      ["commerce", "e-commerce"].contains(slug.toLowerCase());

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "slug": slug,
    "is_active": isActive,
    "logo": logo,
    "website_header": website_header,
    "has_banners": hasBanners ? 1 : 0,
  };

  //
  bool get authRequired {
    return ["taxi", "parcel", "package"].contains(slug);
  }
}
