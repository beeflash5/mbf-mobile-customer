import 'dart:convert';
import 'package:fuodz/constants/api.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/models/cart.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/services/api_service.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/cart.service.dart';
import 'package:fuodz/services/local_storage.service.dart';

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
        final List<dynamic> itemsList = apiResponse.body['items'];
        final List<Cart> parsedCarts = itemsList.map((item) {
          final productJson = item['product'];
          // Convert price to string if needed by double.parse
          productJson['price'] = productJson['price']?.toString() ?? "0";
          productJson['sell_price'] = productJson['sell_price']?.toString() ?? "0";
          productJson['discount_price'] = productJson['discount_price']?.toString() ?? "0";

          return Cart(
            selectedQty: item['quantity'],
            price: double.tryParse(item['price'].toString()) ?? 0.0,
            product: Product.fromJson(productJson),
            optionsIds: item['options_ids'] != null ? List<int>.from(item['options_ids']) : null,
          );
        }).toList();

        CartServices.productsInCart = parsedCarts;
        await CartServices.updateTotalCartItemCount(parsedCarts.length);
        
        await LocalStorageService.prefs!.setString(
          CartServices.cartItemsKey,
          jsonEncode(parsedCarts),
        );
        CartServices.cartItemsCountStream.add(parsedCarts.length);
      }
    } catch (e) {
      print("Failed to load cart from backend: $e");
    }
  }

  static Future<void> addToBackend(Cart cart) async {
    if (!AuthServices.authenticated()) return;
    try {
      await ApiService().post(
        "/cart",
        {
          "product_id": cart.product?.id,
          "quantity": cart.selectedQty ?? 1,
          "options_ids": cart.optionsIds ?? [],
        },
      );
      await loadFromBackend();
    } catch (e) {
      print("Failed to add cart to backend: $e");
    }
  }
}
