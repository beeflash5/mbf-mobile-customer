import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuodz/models/vendor_type.dart';
import 'package:fuodz/models/service.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/models/vendor.dart';
import 'package:fuodz/models/order.dart';

void main() {
  test('Test API deserialization', () async {
    final client = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;

    // Helper to get JSON from URL
    Future<dynamic> getJson(String url) async {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      return jsonDecode(body);
    }

    print("--- TESTING VENDOR TYPES ---");
    try {
      final vendorTypesJson = await getJson("https://api.mybalifriendz.co/api/vendor/types");
      print("Raw vendor types length: ${vendorTypesJson.length}");
      for (final item in vendorTypesJson) {
        try {
          final vt = VendorType.fromJson(item);
          print("Successfully parsed vendor type: ${vt.name} (id: ${vt.id})");
        } catch (e, stack) {
          print("FAIL to parse vendor type: $item");
          print("Error: $e\n$stack");
        }
      }
    } catch (e) {
      print("Request to vendor types failed: $e");
    }

    print("\n--- TESTING TOP SERVICES ---");
    try {
      final topServicesJson = await getJson("https://api.mybalifriendz.co/api/topService");
      final dataList = topServicesJson["data"] as List;
      print("Raw services length: ${dataList.length}");
      for (final item in dataList) {
        try {
          final service = Service.fromJson(item);
          print("Successfully parsed service: ${service.name} (id: ${service.id})");
        } catch (e, stack) {
          print("FAIL to parse service: $item");
          print("Error: $e\n$stack");
        }
      }
    } catch (e) {
      print("Request to top services failed: $e");
    }

    print("\n--- TESTING SERVICE SEARCH ---");
    try {
      final searchJson = await getJson("https://api.mybalifriendz.co/api/search?keyword=Bali&merge=1&type=service");
      final dataList = searchJson["data"] as List;
      print("Raw search services length: ${dataList.length}");
      for (final item in dataList) {
        try {
          final service = Service.fromJson(item);
          print("Successfully parsed searched service: ${service.name} (id: ${service.id})");
        } catch (e, stack) {
          print("FAIL to parse searched service: $item");
          print("Error: $e\n$stack");
        }
      }
    } catch (e) {
      print("Request to search services failed: $e");
    }

    print("\n--- TESTING VENDOR SEARCH ---");
    try {
      final searchJson = await getJson("https://api.mybalifriendz.co/api/search?keyword=Bali&merge=1&type=vendor");
      final dataList = searchJson["data"] as List;
      print("Raw search vendors length: ${dataList.length}");
      for (final item in dataList) {
        try {
          final vendor = Vendor.fromJson(item);
          print("Successfully parsed searched vendor: ${vendor.name} (id: ${vendor.id})");
        } catch (e, stack) {
          print("FAIL to parse searched vendor: $item");
          print("Error: $e\n$stack");
        }
      }
    } catch (e) {
      print("Request to search vendors failed: $e");
    }

    print("\n--- TESTING PRODUCT SEARCH ---");
    try {
      final searchJson = await getJson("https://api.mybalifriendz.co/api/search?keyword=CHICKEN&merge=1&type=product");
      final dataList = searchJson["data"] as List;
      print("Raw search products length: ${dataList.length}");
      for (final item in dataList) {
        try {
          final product = Product.fromJson(item);
          print("Successfully parsed searched product: ${product.name} (id: ${product.id})");
        } catch (e, stack) {
          print("FAIL to parse searched product: $item");
          print("Error: $e\n$stack");
        }
      }
    } catch (e) {
      print("Request to search products failed: $e");
    }

    print("\n--- TESTING ORDER PARSING ---");
    try {
      final mockOrderJson = {
        "id": 541,
        "code": "swPnyijA7g",
        "note": "test note",
        "payment_status": "pending",
        "created_at": "2026-06-04 09:30:51",
        "updated_at": "2026-06-04 09:30:51",
        "formatted_date": "2026-06-04",
        "user_id": 1,
        "user": {
          "id": 1,
          "name": "Admin Account",
          "email": "admin@demo.com",
          "phone": "1234567890",
          "country_code": "ID",
          "role_name": "client"
        },
        "products": [
          {
            "id": 12,
            "quantity": 2,
            "price": 10000.0,
            "order_id": 541,
            "product_id": 27,
            "product": {
              "id": 27,
              "name": "CHICKEN SCHNITZEL",
              "price": 95000.0,
              "vendor_id": 64
            }
          }
        ]
      };
      final parsedOrder = Order.fromJson(mockOrderJson);
      print("Successfully parsed mock order with nested product (no vendor): ${parsedOrder.code} (id: ${parsedOrder.id})");
    } catch (e, stack) {
      print("FAIL to parse mock order: $e\n$stack");
    }

    final liveOrdersFile = File("C:\\Users\\CMM-IT\\.gemini\\antigravity-ide\\brain\\2a985bb6-0865-4c73-bc05-f73e84fc0986\\scratch\\live_orders.json");
    if (liveOrdersFile.existsSync()) {
      print("\n--- TESTING LIVE ORDERS ---");
      try {
        final content = liveOrdersFile.readAsStringSync();
        final jsonMap = jsonDecode(content);
        final dataList = jsonMap["data"] as List;
        print("Found ${dataList.length} orders in live_orders.json");
        int successCount = 0;
        for (var i = 0; i < dataList.length; i++) {
          final item = dataList[i];
          try {
            final order = Order.fromJson(item);
            print("Successfully parsed live order index $i, ID: ${order.id}, code: ${order.code}");
            successCount++;
          } catch (e, stack) {
            print("FAIL to parse live order index $i: ${item['code']} (id: ${item['id']})");
            print("Error: $e\n$stack");
          }
        }
        expect(successCount, equals(dataList.length), reason: "All live orders should parse successfully without error");
      } catch (e, stack) {
        print("Error reading/parsing live orders: $e\n$stack");
      }
    }
  });
}
