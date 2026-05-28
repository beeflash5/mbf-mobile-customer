// To parse this JSON data, do
//
//     final review = reviewFromJson(jsonString);

import 'dart:convert';

import 'package:fuodz/models/user.dart';
import 'package:fuodz/models/vendor.dart';

Review reviewFromJson(String str) => Review.fromJson(json.decode(str));

String reviewToJson(Review data) => json.encode(data.toJson());

class Review {
  Review({
    required this.id,
    required this.rating,
    required this.review,
    required this.userId,
    required this.vendorId,
    required this.driverId,
    required this.orderId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.formattedDate,
    required this.formattedUpdatedDate,
    required this.photo,
    required this.vendor,
    required this.user,
  });

  int id;
  int rating;
  String review;
  int? userId;
  int? vendorId;
  int? driverId;
  int? orderId;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;
  String formattedDate;
  String formattedUpdatedDate;
  String photo;
  Vendor? vendor;
  User? user;

factory Review.fromJson(Map<String, dynamic> json) {
  try {
    return Review(
      id: json["id"] ?? 0,
      rating: json["rating"] ?? 0,

      review: json["review"] ?? '',

      userId: json["user_id"],
      vendorId: json["vendor_id"],
      driverId: json["driver_id"],
      orderId: json["order_id"],

      createdAt: json["created_at"] != null
          ? DateTime.parse(json["created_at"])
          : DateTime.now(),

      updatedAt: json["updated_at"] != null
          ? DateTime.parse(json["updated_at"])
          : DateTime.now(),

      deletedAt: json["deleted_at"],

      formattedDate: json["formatted_date"] ?? '',

      formattedUpdatedDate:
          json["formatted_updated_date"] ?? '',

      photo: json["photo"] ?? '',

      vendor:null,//
      //  json["vendor"] != null
      //     ? Vendor.fromJson(json["vendor"])
      //     : null,

      user: json["user"] != null
          ? User.fromJson(json["user"])
          : null,
    );
  } catch (e, s) {
    print("Review Parse Error ==> $e");
    print("Stack ==> $s");
    print("JSON ==> $json");

    rethrow;
  }
}

  Map<String, dynamic> toJson() => {
        "id": id,
        "rating": rating,
        "review": review,
        "user_id": userId,
        "vendor_id": vendorId,
        "driver_id": driverId,
        "order_id": orderId,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
        "formatted_date": formattedDate,
        "formatted_updated_date": formattedUpdatedDate,
        "photo": photo,
        "vendor": vendor?.toJson(),
        "user": user?.toJson(),
      };
}
