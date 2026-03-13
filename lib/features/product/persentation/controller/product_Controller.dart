import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../repository/cart_repository.dart';
import '../../../../core/theme/app_colors.dart';

class ProductController extends GetxController {
  final CartRepository cartRepository = Get.put(CartRepositoryImpl());
  
  var quantity = 1.obs;
  final int price = 140;
  
  // Cart items map: productId -> quantity
  var cartItems = <String, int>{}.obs;
  var loadingIds = <String>{}.obs;

  int get totalAmount => quantity.value * price;

  void increment() {
    quantity.value++;
  }

  void decrement() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }
  
  // Add to cart local (and initialize with 1)
  void addToCart(String productId) {
    if (!cartItems.containsKey(productId)) {
      cartItems[productId] = 1;
    }
  }

  // Add to cart API
  Future<void> addToCartApi(String productId) async {
    loadingIds.add(productId);
    try {
      final int qty = getCartQuantity(productId);
      final int finalQty = qty > 0 ? qty : 1;
      
      final response = await cartRepository.addToCart(
        itemType: "user_products",
        itemId: int.tryParse(productId) ?? 0,
        quantity: finalQty,
        showErrorToast: false,
      );

      if (response != null) {
        if (response['success'] == true) {
          if (!cartItems.containsKey(productId)) {
            cartItems[productId] = finalQty;
          }
          
          // Reset local display quantity back to 1 (by setting storage to 0)
          cartItems[productId] = 0;
          cartItems.refresh();
          
          Get.snackbar(
            'Success',
            response['message'] ?? 'Added to cart',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.success,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        } else {
          // Display the specific message from the API response
          String errorMsg = response['message'] ?? 'Failed to add to cart';
          
          // If there are validation errors, try to get the first one
          if (response['errors'] != null && response['errors'] is Map) {
            Map errors = response['errors'];
            if (errors.isNotEmpty) {
              var firstError = errors.values.first;
              if (firstError is List && firstError.isNotEmpty) {
                errorMsg = firstError.first.toString();
              }
            }
          }

          Get.snackbar(
            'Cannot Add',
            errorMsg,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.error,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      debugPrint("Add to Cart Error: $e");
    } finally {
      loadingIds.remove(productId);
    }
  }
  
  // Remove from cart
  void removeFromCart(String productId) {
    cartItems.remove(productId);
  }
  
  // Increase cart quantity
  void increaseCartQuantity(String productId) {
    if (cartItems.containsKey(productId)) {
      cartItems[productId] = cartItems[productId]! + 1;
    } else {
      cartItems[productId] = 2; // Starts at 1 effectively, so +1 makes it 2
    }
    cartItems.refresh();
  }
  
  // Decrease cart quantity
  void decreaseCartQuantity(String productId) {
    if (cartItems.containsKey(productId)) {
      if (cartItems[productId]! > 1) {
        cartItems[productId] = cartItems[productId]! - 1;
        cartItems.refresh();
      }
    } else {
      // If it was effectively 1, and we decrease, it stays 1 as per "min 1" rule
      cartItems[productId] = 1; 
      cartItems.refresh();
    }
  }
  
  // Get cart quantity for a product
  int getCartQuantity(String productId) {
    return cartItems[productId] ?? 0;
  }
  
  // Check if product is in cart
  bool isInCart(String productId) {
    return cartItems.containsKey(productId);
  }
}
