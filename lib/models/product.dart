import 'package:dartx/dartx.dart';
import 'package:fuodz/models/digital_file.dart';
import 'package:fuodz/models/option.dart';
import 'package:fuodz/models/tag.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/models/option_group.dart';

class Product {
  Product({
    required this.id,
    required this.name,
    this.barcode,
    required this.description,
    required this.price,
    required this.discountPrice,
    this.capacity,
    this.unit,
    this.packageCount,
    required this.featured,
    required this.plusOption,
    required this.isFavourite,
    required this.deliverable,
    required this.digital,
    required this.digitalFiles,
    required this.isActive,
    required this.vendorId,
    this.categoryId,
    required this.photo,
    required this.vendor,
    required this.optionGroups,
    required this.availableQty,
    this.selectedQty = 1,
    required this.photos,
    //
    required this.rating,
    required this.reviewsCount,
    this.ageRestricted = false,
    this.tags,
    this.token,
    required this.description_url,
    this.shareable_link,
    this.deep_link,
    this.expires_at,
    this.vendor_type_id,
  }) {
    this.heroTag = 'product-$id-${DateTime.now().microsecondsSinceEpoch}';
  }

  int id;
  String? heroTag;
  String name;
  String? barcode;
  String description;
  double price;
  double discountPrice;
  String? capacity;
  String? unit;
  String? packageCount;
  int featured;
  int plusOption;
  bool isFavourite;
  int deliverable;
  int digital;
  int isActive;
  int vendorId;
  int? categoryId;
  String photo;
  Vendor vendor;
  List<OptionGroup> optionGroups = [];
  List<String> photos;
  List<Option>? selectedOptions = [];
  List<DigitalFile>? digitalFiles = [];
  List<Tag>? tags = [];

  //
  int? availableQty;
  int selectedQty = 0;
  //
  double? rating;
  int reviewsCount;
  bool ageRestricted;
  String? token;
  String description_url;
  String? shareable_link;
  String? deep_link;
  String? expires_at;
  int? vendor_type_id;

  factory Product.fromJson(
    Map<String, dynamic> json, {
    bool rawDescription = true,
  }) {
    List<OptionGroup> productOptions =
        json["option_groups"] == null
            ? []
            : List<OptionGroup>.from(
              json["option_groups"].map((x) => OptionGroup.fromJson(x)),
            );

    // Inject variants as an OptionGroup for food & beverage
    if (json["variants"] != null) {
      final variantsList = List<dynamic>.from(json["variants"]);
      if (variantsList.isNotEmpty) {
        // Collect existing option IDs to prevent duplication (matching Next.js behavior)
        final existingOptionIds = <int>{};
        for (final group in productOptions) {
          for (final option in group.options) {
            existingOptionIds.add(option.id);
          }
        }

        // Deduplicate variants by ID and filter out those already present in optionGroups
        final uniqueVariantsMap = <int, dynamic>{};
        for (final v in variantsList) {
          final int vId = v["id"] ?? 0;
          if (vId != 0 && !existingOptionIds.contains(vId)) {
            uniqueVariantsMap[vId] = v;
          }
        }

        final variantOptions =
            uniqueVariantsMap.values.map((v) {
              return Option(
                id: v["id"] ?? 0,
                name: v["name"] ?? "",
                price:
                    v["price"] != null
                        ? double.parse(v["price"].toString())
                        : 0.0,
                photo: "",
                optionGroupId: -1,
                description: "",
              );
            }).toList();

        if (variantOptions.isNotEmpty) {
          productOptions.insert(
            0,
            OptionGroup(
              id: -1,
              name: "Variant",
              multiple: 0,
              required: 0, // "None" is allowed by default
              isActive: 1,
              photo: "",
              options: variantOptions,
            ),
          );
        }
      }
    }
    return Product(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      barcode: json["barcode"],
      description:
          json["description"] == null
              ? ""
              : !rawDescription
              ? json["description"]
              : json["description"].toString().replaceAll(
                RegExp(r'<[^>]*>'),
                '',
              ),
      price: double.parse(json["price"].toString()),
      discountPrice:
          json["discount_price"] == null
              ? 0.00
              : double.parse(json["discount_price"].toString()),
      capacity: json["capacity"] == null ? null : json["capacity"].toString(),
      unit: json["unit"] == null ? null : json["unit"],
      packageCount:
          json["package_count"] == null
              ? null
              : json["package_count"].toString(),
      featured:
          json["featured"] == null ? 0 : int.parse(json["featured"].toString()),
      plusOption:
          json["plus_option"] == null
              ? 1
              : int.parse(json["plus_option"].toString()) == 1
              ? 1
              : (productOptions.isEmpty ? 1 : 0),
      isFavourite: json["is_favourite"] ?? false,
      deliverable:
          json["deliverable"] == null
              ? 0
              : int.parse(json["deliverable"].toString()),
      digital:
          json["digital"] == null ? 0 : int.parse(json["digital"].toString()),
      isActive:
          json["is_active"] == null
              ? 0
              : int.parse(json["is_active"].toString()),
      vendorId: int.parse(json["vendor_id"].toString()),
      categoryId: json["category_id"],
      photo: json["photo"] ?? "",
      vendor:
          json["vendor"] == null
              ? Vendor.fromJson({
                "id": json["vendor_id"] ?? 0,
                "vendor_type_id": json["vendor_type_id"] ?? 0,
              })
              : Vendor.fromJson({
                ...json["vendor"],
                if (json["vendor"]["vendor_type_id"] == null &&
                    json["vendor_type_id"] != null)
                  "vendor_type_id": json["vendor_type_id"],
              }),
      optionGroups: productOptions,
      digitalFiles:
          json["digital_files"] == null
              ? null
              : List<DigitalFile>.from(
                json["digital_files"].map((x) => DigitalFile.fromJson(x)),
              ),

      // photos
      photos:
          json["photos"] == null
              ? []
              : List<String>.from(json["photos"].map((x) => x)),
      //
      availableQty:
          json["available_qty"] == null
              ? null
              : int.parse(json["available_qty"].toString()),
      selectedQty:
          json["selected_qty"] == null
              ? 0
              : int.parse(json["selected_qty"].toString()),
      //
      rating:
          json["rating"] == null
              ? null
              : double.parse(json["rating"].toString()),
      reviewsCount:
          json["reviews_count"] == null
              ? 0
              : int.parse(json["reviews_count"].toString()),
      ageRestricted:
          json["age_restricted"] == null ? false : json["age_restricted"],
      tags:
          json["tags"] == null
              ? []
              : List<Tag>.from(json["tags"].map((x) => Tag.fromJson(x))),
      //
      token: json["token"],
      description_url: json["description_url"] ?? "",
      shareable_link: json["shareable_link"],
      deep_link: json["deep_link"],
      expires_at: json["expires_at"],
      vendor_type_id: json["vendor_type_id"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "barcode": barcode,
    "description": description,
    "price": price,
    "discount_price": discountPrice,
    "capacity": capacity,
    "unit": unit,
    "package_count": packageCount,
    "featured": featured,
    "is_favourite": isFavourite,
    "deliverable": deliverable,
    "digital": digital,
    "is_active": isActive,
    "vendor_id": vendorId,
    "category_id": categoryId,
    "photo": photo,
    "vendor": vendor.toJson(),
    "option_groups": List<dynamic>.from(optionGroups.map((x) => x.toJson())),
    "digital_files":
        digitalFiles == null
            ? null
            : List<dynamic>.from((digitalFiles ?? []).map((x) => x.toJson())),

    //
    "available_qty": availableQty,
    "selected_qty": selectedQty,
    //
    "rating": rating,
    "reviews_count": reviewsCount,
    "age_restricted": ageRestricted,
    "tags":
        tags == null
            ? null
            : List<dynamic>.from((tags ?? []).map((x) => x.toJson())),
    "token": token,
    "description_url": description_url,
    "shareable_link": shareable_link,
    "deep_link": deep_link,
    "expires_at": expires_at,
    "vendor_type_id": vendor_type_id,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toCheckout() => {
    "id": id,
    "name": name,
    "barcode": barcode,
    "price": price,
    "discount_price": discountPrice,
    "vendor_id": vendorId,
    "selected_qty": selectedQty,
    "token": token,
  };

  //getters
  get showDiscount => (discountPrice > 0.00) && (discountPrice < price);
  get canBeDelivered => deliverable == 1;
  bool get hasStock => availableQty == null || (availableQty ?? 0) > 0;
  double get sellPrice {
    return showDiscount ? discountPrice : price;
  }

  double get totalPrice {
    return sellPrice * (selectedQty);
  }

  bool get isDigital {
    return digital == 1;
  }

  int get discountPercentage {
    if (discountPrice < price) {
      // return 100 - (100 * ((price - discountPrice) / price) ?? 0).floor();
      try {
        return 100 - (100 * (discountPrice / price)).floor();
      } catch (e) {
        return 0;
      }
    } else {
      return 0;
    }
  }

  //
  bool optionGroupRequirementCheck() {
    if (this.optionGroups.isEmpty) {
      return false;
    }
    //check if the option groups with required setting has an option selected
    OptionGroup? optionGroupRequired = this.optionGroups.firstOrNullWhere(
      (e) => e.required == 1,
    );

    if (optionGroupRequired == null || (this.optionGroups.length <= 1)) {
      return false;
    } else {
      return true;
    }
  }
}
