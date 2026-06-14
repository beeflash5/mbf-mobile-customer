import 'dart:convert';
import 'package:fuodz/models/age_base_price.dart';
import 'package:fuodz/models/category.dart';
import 'package:fuodz/models/guide.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/utils/extensions/string.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import 'service_option.dart';
import 'service_option_group.dart';

Service ServiceFromJson(String str) => Service.fromJson(json.decode(str));

String ServiceToJson(Service data) => json.encode(data.toJson());

class Service {
  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.discountPrice,
    required this.duration,
    required this.isActive,
    required this.vendorId,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    required this.formattedDate,
    required this.vendor,
    required this.category,
    required this.subcategory,
    required this.photos,
    this.selectedQty,
    required this.location,
    this.optionGroups,
    this.agebasePrice,
    this.guide,
    this.token,
    this.ageRestricted = false,
    required this.description_url,
    this.shareable_link,
    this.deep_link,
    this.video,
    this.vendor_type_id,
    this.type,
  }) {
    this.heroTag = 'service-$id-${DateTime.now().microsecondsSinceEpoch}';
  }

  int id;
  String? heroTag;
  String name;
  String description;
  double price;
  double discountPrice;
  String duration;
  int isActive;
  int vendorId;
  int? categoryId;
  DateTime createdAt;
  DateTime updatedAt;
  String formattedDate;
  Vendor vendor;
  Category? category;
  Category? subcategory;
  List<String> photos = const [];
  int? selectedQty;
  bool location;
  List<ServiceOptionGroup>? optionGroups;
  List<AgeBasePrices>? agebasePrice;
  List<Guide>? guide;
  String? token;
  bool ageRestricted;
  String? description_url;
  String? shareable_link;
  String? deep_link;
  String? video;
  int? vendor_type_id;
  VendorType? type;

  //add varibale to hold the selected options
  List<ServiceOption> selectedOptions = [];

  factory Service.fromJson(
    Map<String, dynamic> json, {
    bool rawDescription = true,
  }) {
    return Service(
      id: json["id"] == null ? 0 : int.parse(json["id"].toString()),
      name: (json["name"] ?? "").toString().parseLocalized(),
      description:
          json["description"] == null
              ? ""
              : !rawDescription
              ? json["description"].toString().parseLocalized()
              : json["description"].toString().parseLocalized().replaceAll(
                RegExp(r'<[^>]*>'),
                '',
              ),
      price:
          json["price"] == null ? 0.0 : double.parse(json["price"].toString()),
      discountPrice:
          json["discount_price"] == null
              ? 0.0
              : double.parse(json["discount_price"].toString()),
      duration: json["duration"] ?? "fixed",
      isActive:
          json["is_active"] == null
              ? 0
              : int.parse(json["is_active"].toString()),
      vendorId:
          json["vendor_id"] == null
              ? 0
              : int.parse(json["vendor_id"].toString()),
      categoryId:
          json["category_id"] == null
              ? null
              : int.tryParse(json["category_id"].toString()),
      createdAt:
          json["created_at"] == null
              ? DateTime.now()
              : DateTime.tryParse(json["created_at"].toString()) ??
                  DateTime.now(),
      updatedAt:
          json["updated_at"] == null
              ? DateTime.now()
              : DateTime.tryParse(json["updated_at"].toString()) ??
                  DateTime.now(),
      formattedDate: json["formatted_date"] ?? "",
      vendor:
          json["vendor"] == null
              ? Vendor.fromJson({"id": json["vendor_id"] ?? 0})
              : Vendor.fromJson(json["vendor"]),
      category:
          json["category"] == null ? null : Category.fromJson(json["category"]),
      subcategory:
          json["subcategory"] == null
              ? null
              : Category.fromJson(json["subcategory"]),

      // photos
      photos:
          json["photos"] == null
              ? []
              : List<String>.from(json["photos"].map((x) => x.toString())),
      location: json["location"] ?? true,

      //
      optionGroups:
          json["option_groups"] == null
              ? []
              : List<ServiceOptionGroup>.from(
                json["option_groups"].map(
                  (x) => ServiceOptionGroup.fromJson(x),
                ),
              ),
      agebasePrice:
          json["age_base_prices"] == null
              ? []
              : List<AgeBasePrices>.from(
                json["age_base_prices"].map((x) => AgeBasePrices.fromJson(x)),
              ),
      guide:
          json["guides"] == null
              ? []
              : List<Guide>.from(json["guides"].map((x) => Guide.fromJson(x))),

      //
      token: json["token"],
      ageRestricted:
          json["age_restricted"] == 1 || json["age_restricted"] == true,
      description_url: json["description_url"] ?? "",
      shareable_link: json["shareable_link"],
      deep_link: json["deep_link"],
      video: json["video"],
      vendor_type_id: json["vendor_type_id"],
      type: json["type"] == null ? null : VendorType.fromJson(json["type"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "price": price,
    "discount_price": discountPrice,
    "duration": duration,
    "location": location,
    "is_active": isActive,
    "vendor_id": vendorId,
    "category_id": categoryId == null ? null : categoryId,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "formatted_date": formattedDate,
    "vendor": vendor.toJson(),
    "category": category?.toJson(),
    "option_groups":
        optionGroups == null
            ? null
            : List<dynamic>.from((optionGroups ?? []).map((x) => x.toJson())),

    "agebasePrice":
        agebasePrice == null
            ? null
            : List<dynamic>.from((agebasePrice ?? []).map((x) => x.toJson())),
    "guide":
        guide == null
            ? null
            : List<dynamic>.from((guide ?? []).map((x) => x.toJson())),

    "token": token,
    "age_restricted": ageRestricted,
    "description_url": description_url,
    "shareable_link": shareable_link,
    "deep_link": deep_link,
    "video": video,
    "vendor_type_id": vendor_type_id,
    "type": type?.toJson(),
  };

  //getters
  bool get showDiscount => discountPrice > 0.00 && discountPrice < price;
  bool get isPerHour => duration == "hour";
  bool get isFixed => duration == "fixed";
  double get sellPrice {
    try {
      return showDiscount ? discountPrice : price;
    } catch (e) {
      return price;
    }
  }

  int get discountPercentage {
    if (discountPrice < price) {
      // return 100 - (100 * ((price - discountPrice) / price) ?? 0).floor();
      return 100 - (100 * (discountPrice / price)).floor();
    } else {
      return 0;
    }
  }

  String get durationText {
    return "${isFixed ? '' : '/${duration.tr()}'}";
  }

  //
  bool get hasOptions {
    return optionGroups != null && (optionGroups?.length ?? 0) > 0;
  }
}
