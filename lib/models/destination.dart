import 'dart:convert';

import 'package:fuodz/models/service.dart';

Destination destinationFromJson(String str) =>
    Destination.fromJson(json.decode(str));

String destinationToJson(Destination data) => json.encode(data.toJson());

class Destination {
  Destination({
    required this.id,
    required this.province,
    required this.type,
    required this.name,
    required this.services,
  });

  int id;
  String province;
  String type;
  String name;
  List<Service> services;

  factory Destination.fromJson(Map<String, dynamic> json) => Destination(
    id: json["id"],
    province: json["province"] ?? "",
    type: json["type"] ?? "",
    name: json["name"] ?? "",
    services:
        json["services"] == null
            ? []
            : List<Service>.from(
              json["services"].map((x) => Service.fromJson(x)),
            ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "province": province,
    "type": type,
    "name": name,
    "services": List<dynamic>.from(services.map((x) => x.toJson())),
  };
}
