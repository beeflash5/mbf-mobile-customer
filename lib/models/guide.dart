// To parse this JSON data, do
//
//     final Guide = GuideFromJson(jsonString);

import 'dart:convert';
import 'package:flutter/foundation.dart';

Guide GuideFromJson(String str) => Guide.fromJson(json.decode(str));

String GuideToJson(Guide data) => json.encode(data.toJson());

class Guide {
  final int id;
  final String lang;

  Guide({required this.id, required this.lang});

  factory Guide.fromJson(Map<String, dynamic> json) {
    final langData = json["lang"];
    String langStr = "";

    if (langData is Map) {
      if (langData.containsKey("lang")) {
        langStr = langData["lang"].toString();
      } else {
        langStr =
            (langData["en"] ?? langData["id"] ?? langData.values.first)
                .toString();
      }
    } else if (langData is String) {
      if (langData.startsWith('{')) {
        try {
          final Map map = jsonDecode(langData);
          if (map.containsKey("lang")) {
            langStr = map["lang"].toString();
          } else {
            langStr = (map["en"] ?? map["id"] ?? map.values.first).toString();
          }
        } catch (e) {
          final match = RegExp(r'lang:\s*([^,}]+)').firstMatch(langData);
          if (match != null) {
            langStr = match.group(1)?.trim() ?? langData;
          } else {
            langStr = langData;
          }
        }
      } else {
        langStr = langData;
      }
    } else {
      langStr = (langData ?? "").toString();
    }

    debugPrint('[Guide.fromJson] raw=$json → lang=$langStr');
    return Guide(id: json["id"] ?? 0, lang: langStr);
  }

  Map<String, dynamic> toJson() => {"id": id, "lang": lang};
}
