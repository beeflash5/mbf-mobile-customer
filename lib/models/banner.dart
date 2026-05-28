import 'package:fuodz/models/category.dart';
import 'package:fuodz/models/vendor.dart';

class Banner {
  int? id;
  String? name;
  String? link;
  String? imageUrl;

  // campaign
  String? campaignTitle;
  String? campaignDesc;

  Category? category;
  Vendor? vendor;

  Banner();

  factory Banner.fromJSON(dynamic json) {
    final banner = Banner();

    banner.id = json["id"];
    banner.name = json["name"];
    banner.link = json["link"];
    banner.imageUrl = json["photo"];

    // campaign
    banner.campaignTitle = json["campaign_title"];
    banner.campaignDesc = json["campaign_desc"];

    // load category if included
    if (json["category"] != null) {
      banner.category = Category.fromJson(json["category"]);
    }

    // load vendor if included
    if (json["vendor"] != null) {
      banner.vendor = Vendor.fromJson(json["vendor"]);
    }

    return banner;
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "link": link,
      "photo": imageUrl,

      // campaign
      "campaign_title": campaignTitle,
      "campaign_desc": campaignDesc,

      "category": category?.toJson(),
      "vendor": vendor?.toJson(),
    };
  }
}
