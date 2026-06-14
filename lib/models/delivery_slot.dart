// To parse this JSON data, do
//
//     final deliverySlot = deliverySlotFromJson(jsonString);

import 'dart:convert';

DeliverySlot deliverySlotFromJson(String str) =>
    DeliverySlot.fromJson(json.decode(str));

String deliverySlotToJson(DeliverySlot data) => json.encode(data.toJson());

class DeliverySlot {
  DeliverySlot({required this.date, required this.times});

  DateTime date;
  List<String> times;

  factory DeliverySlot.fromJson(dynamic json) {
    if (json is String) {
      return DeliverySlot(date: DateTime.parse(json), times: []);
    }
    return DeliverySlot(
      date: DateTime.parse(json["date"]),
      times:
          json["times"] == null
              ? []
              : List<String>.from((json["times"] as List).map((x) => x.toString())),
    );
  }

  Map<String, dynamic> toJson() => {
    "date": date.toIso8601String(),
    "times": List<dynamic>.from(times.map((x) => x)),
  };
}
