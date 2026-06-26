import 'package:fuodz/constants/api.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/models/cart.dart';
import 'package:fuodz/services/api_service.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/cart.service.dart';

class CartBackendService extends ApiService {
  static Future<void> syncToBackend() async {
    if (!AuthServices.authenticated()) return;
    
    try {
      final items = CartServices.productsInCart.map((cart) {
        return {
          "product_id": cart.product?.id,
          "quantity": cart.selectedQty,
          "options_ids": cart.optionsIds ?? [],
        };
      }).toList();

      await ApiService().post(
        "/cart/sync",
        {"items": items}, // But our Spring accepts List<CartRequest> directly!
      );
    } catch (e) {
      print("Failed to sync cart to backend: $e");
    }
  }

  static Future<void> syncCartItems() async {
    if (!AuthServices.authenticated()) return;
    
    try {
      final items = CartServices.productsInCart.map((cart) {
        return {
          "product_id": cart.product?.id,
          "quantity": cart.selectedQty,
          "options_ids": cart.optionsIds ?? [],
        };
      }).toList();

      await ApiService().post(
        "/cart/sync", 
        items, 
      );
    } catch (e) {
      print("Failed to sync cart to backend: $e");
    }
  }

  static Future<void> loadFromBackend() async {
    if (!AuthServices.authenticated()) return;
    
    try {
      final response = await ApiService().get("/cart");
      final apiResponse = ApiResponse.fromResponse(response);
      
      if (apiResponse.allGood && apiResponse.body != null && apiResponse.body['items'] != null) {
        // Hydrate logic goes here if we want to replace local cart on login
      }
    } catch (e) {
      print("Failed to load cart from backend: $e");
    }
  }
}
