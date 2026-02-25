import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class ProductController extends GetxController {
  var quantity = 1.obs;
  final int price = 140;
  
  // Cart items map: productId -> quantity
  var cartItems = <String, int>{}.obs;

  int get totalAmount => quantity.value * price;

  void increment() {
    quantity.value++;
  }

  void decrement() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }
  
  // Add to cart
  void addToCart(String productId) {
    cartItems[productId] = 1;
  }
  
  // Remove from cart
  void removeFromCart(String productId) {
    cartItems.remove(productId);
  }
  
  // Increase cart quantity
  void increaseCartQuantity(String productId) {
    if (cartItems.containsKey(productId)) {
      cartItems[productId] = cartItems[productId]! + 1;
      cartItems.refresh();
    }
  }
  
  // Decrease cart quantity
  void decreaseCartQuantity(String productId) {
    if (cartItems.containsKey(productId)) {
      if (cartItems[productId]! > 1) {
        cartItems[productId] = cartItems[productId]! - 1;
        cartItems.refresh();
      } else {
        removeFromCart(productId);
      }
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
