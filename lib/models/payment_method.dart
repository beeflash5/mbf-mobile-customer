import 'dart:convert';

PaymentMethod paymentMethodFromJson(String str) =>
    PaymentMethod.fromJson(json.decode(str));

String paymentMethodToJson(PaymentMethod data) => json.encode(data.toJson());

class PaymentMethod {
  PaymentMethod({
    required this.id,
    required this.name,
    required this.slug,
    required this.instruction,
    required this.isActive,
    required this.isCash,
    required this.createdAt,
    required this.updatedAt,
    required this.formattedDate,
    required this.photo,
    required this.useExternalBrowser,
    required this.useWallet,
  });

  int id;
  String name;
  String slug;
  String? instruction;
  int isActive;
  int isCash;
  DateTime createdAt;
  DateTime updatedAt;
  String formattedDate;
  String photo;
  bool useExternalBrowser;
  int useWallet;

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    int parseBoolOrInt(dynamic val, int defaultValue) {
      if (val == null) return defaultValue;
      if (val is bool) return val ? 1 : 0;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? defaultValue;
    }

    bool parseBool(dynamic val, bool defaultValue) {
      if (val == null) return defaultValue;
      if (val is bool) return val;
      if (val is int) return val == 1;
      return val.toString().toLowerCase() == 'true' || val.toString() == '1';
    }

    return PaymentMethod(
      id: json["id"] == null ? 0 : int.parse(json["id"].toString()),
      name: json["name"] ?? "",
      slug: json["slug"] ?? "",
      instruction: json["instruction"],
      isActive: parseBoolOrInt(json["is_active"], 0),
      isCash: parseBoolOrInt(json["is_cash"], 0),
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
      photo: json["photo"] ?? "",
      useExternalBrowser: parseBool(json["use_external_browser"], false),
      useWallet: parseBoolOrInt(json["use_wallet"], 0),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "instruction": instruction,
    "is_active": isActive,
    "is_cash": isCash,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "formatted_date": formattedDate,
    "photo": photo,
    "use_external_browser": useExternalBrowser,
    "use_wallet": useWallet,
  };
}
