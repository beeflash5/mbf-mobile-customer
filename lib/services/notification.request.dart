import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/models/notification.dart';
import 'package:fuodz/services/api_service.dart';

class NotificationRequest extends ApiService {
  Future<List<NotificationModel>> getNotifications() async {
    final apiResult = await get("/notifications");
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      if (apiResponse.body["data"] != null) {
        return (apiResponse.body["data"] as List).asMap().entries.map((entry) {
          final val = entry.value;
          return NotificationModel(
            index: entry.key,
            title: val["title"],
            body: val["body"],
            image: val["image"],
            read: val["read"] is bool ? val["read"] : false,
            timeStamp: val["timeStamp"],
          );
        }).toList();
      }
    }
    return [];
  }
}
