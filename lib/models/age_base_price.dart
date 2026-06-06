// To parse this JSON data, do
//
//     final AgeBasePrices = AgeBasePricesFromJson(jsonString);

import 'dart:convert';


AgeBasePrices AgeBasePricesFromJson(String str) =>
    AgeBasePrices.fromJson(json.decode(str));

String AgeBasePricesToJson(AgeBasePrices data) => json.encode(data.toJson());

class AgeBasePrices {
  final int id;
  final String name;
  final String description;
  final double price;

  AgeBasePrices({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
  });

  factory AgeBasePrices.fromJson(Map<String, dynamic> json) => AgeBasePrices(
    id: json["id"] ?? 0,
    name: json["name"] ?? "",
    description: json["description"] ?? "",
    price: json["price"] == null ? 0.0 : (double.tryParse(json["price"].toString()) ?? 0.0),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "price": price,
  };
}
