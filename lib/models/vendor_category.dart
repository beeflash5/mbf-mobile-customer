import 'dart:convert';

VendorCategory vendorCategoryFromJson(String str) =>
    VendorCategory.fromJson(json.decode(str));

String vendorCategoryToJson(VendorCategory data) => json.encode(data.toJson());

class VendorCategory {
  VendorCategory({
    required this.id,
    required this.vendorId,
    required this.vendorTypeId,
  });

  int id;
  int vendorId;
  int vendorTypeId;

  factory VendorCategory.fromJson(Map<String, dynamic> json) => VendorCategory(
    id: json["id"],
    vendorId: json["vendor_id"],
    vendorTypeId: json["vendor_type_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "vendor_id": vendorId,
    "vendor_type_id": vendorTypeId,
  };
}
