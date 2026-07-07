import 'dart:convert';
import 'package:fuodz/constants/api.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/models/cart.dart';
import 'package:fuodz/models/option.dart';
import 'package:fuodz/models/product.dart';
import 'package:fuodz/services/api_service.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/cart.service.dart';
import 'package:fuodz/services/local_storage.service.dart';

class CartBackendService extends ApiService {
  static Future<void> syncToBackend() async {
    if (!AuthServices.authenticated()) return;

    try {
      final items =
          CartServices.productsInCart.map((cart) {
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
      final items =
          CartServices.productsInCart.map((cart) {
            return {
              "product_id": cart.product?.id,
              "quantity": cart.selectedQty,
              "options_ids": cart.optionsIds ?? [],
            };
          }).toList();

      await ApiService().post("/cart/sync", items);
    } catch (e) {
      print("Failed to sync cart to backend: $e");
    }
  }

  static Future<void> loadFromBackend() async {
    if (!AuthServices.authenticated()) return;

    try {
      final response = await ApiService().get("/cart");
      final apiResponse = ApiResponse.fromResponse(response);

      if (apiResponse.allGood &&
          apiResponse.body != null &&
          apiResponse.body['items'] != null) {
        final List<dynamic> itemsList = apiResponse.body['items'];
        final List<Cart> parsedCarts =
            itemsList.map((item) {
              final productJson = item['product'];
              // Convert price to string if needed by double.parse
              productJson['price'] = productJson['price']?.toString() ?? "0";
              productJson['sell_price'] =
                  productJson['sell_price']?.toString() ?? "0";
              productJson['discount_price'] =
                  productJson['discount_price']?.toString() ?? "0";

              final product = Product.fromJson(productJson);
              final optionsIds =
                  item['options_ids'] != null
                      ? List<int>.from(item['options_ids'])
                      : <int>[];
              List<Option> selectedOptions = [];

              if (optionsIds.isNotEmpty) {
                for (var group in product.optionGroups) {
                  for (var opt in group.options) {
                    if (optionsIds.contains(opt.id)) {
                      selectedOptions.add(opt);
                    }
                  }
                }
              }

              // Fallback if the API returns options directly
              if (selectedOptions.isEmpty && item['options'] != null) {
                selectedOptions = List<Option>.from(
                  item['options'].map((x) => Option.fromJson(x)),
                );
              }

              // Fallback: if we still couldn't resolve options, try to rescue them from the current local cart
              if (selectedOptions.isEmpty && optionsIds.isNotEmpty) {
                final existingCartItem = CartServices.productsInCart.firstWhere(
                  (c) =>
                      c.product?.id == product.id &&
                      c.optionsIds?.join(',') == optionsIds.join(','),
                  orElse: () => Cart(),
                );
                if (existingCartItem.options != null &&
                    existingCartItem.options!.isNotEmpty) {
                  selectedOptions = List<Option>.from(
                    existingCartItem.options!,
                  );
                }
              }

              return Cart(
                selectedQty: item['quantity'],
                price: double.tryParse(item['price'].toString()) ?? 0.0,
                product: product,
                optionsIds: optionsIds.isNotEmpty ? optionsIds : null,
                options: selectedOptions.isNotEmpty ? selectedOptions : null,
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
      await ApiService().post("/cart", {
        "product_id": cart.product?.id,
        "quantity": cart.selectedQty ?? 1,
        "options_ids": cart.optionsIds ?? [],
      });
      await loadFromBackend();
    } catch (e) {
      print("Failed to add cart to backend: $e");
    }
  }
}
