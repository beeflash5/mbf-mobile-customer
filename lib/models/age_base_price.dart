// To parse this JSON data, do
//
//     final AgeBasePrices = AgeBasePricesFromJson(jsonString);

import 'dart:convert';

import 'service_option.dart';

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
    id: json["id"],
    name: json["name"],
    description: json["description"],
    price: double.parse(json["price"].toString()),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "price": price,
  };
}
