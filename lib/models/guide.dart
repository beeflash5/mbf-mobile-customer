// To parse this JSON data, do
//
//     final Guide = GuideFromJson(jsonString);

import 'dart:convert';


Guide GuideFromJson(String str) => Guide.fromJson(json.decode(str));

String GuideToJson(Guide data) => json.encode(data.toJson());

class Guide {
  final int id;
  final String lang;

  Guide({required this.id, required this.lang});

  factory Guide.fromJson(Map<String, dynamic> json) =>
      Guide(id: json["id"], lang: json["lang"]);

  Map<String, dynamic> toJson() => {"id": id, "lang": lang};
}
