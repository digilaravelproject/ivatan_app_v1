import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/network/api_services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_dialog.dart';
import '../../../payment/presentation/controller/payment_controller.dart';
import '../../data/model/cart_model.dart';
import '../../repository/cart_repository.dart';

class CartController extends GetxController {
  final CartRepository cartRepository = Get.put(CartRepositoryImpl());
  final ApiServices apiServices = Get.find<ApiServices>();
  final PaymentController paymentController = Get.put(PaymentController());

  var cartItems = <CartItemModel>[].obs;
  var totalPrice = 0.0.obs;
  var totalItems = 0.obs;
  var isLoading = false.obs;

  var selectedAddress = Rx<Address?>(null);
  var addresses = <Address>[].obs;
  var isLoadingAddresses = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCartData();
    fetchAddresses();
  }

  Future<void> fetchCartData({bool showLoader = true}) async {
    if (showLoader) isLoading.value = true;
    try {
      final response = await cartRepository.getCart();
      debugPrint("🛒 CART API RESPONSE: $response");
      
      if (response != null) {
        if (response.containsKey('cart') || response['success'] == true) {
          final cartRes = CartResponse.fromJson(response);
          cartItems.value = cartRes.cart?.items ?? [];
          totalPrice.value = cartRes.totalPrice;
          totalItems.value = cartRes.totalItems;
          debugPrint("🛒 CART ITEMS LOADED: ${cartItems.length}");
        } else {
          debugPrint("🛒 CART API RESPONSE MISSING EXPECTED DATA: $response");
        }
      } else {
        debugPrint("🛒 CART API ERROR: Response is null");
      }
    } catch (e, stackTrace) {
      debugPrint('🛒 Error parsing/fetching cart: $e');
      debugPrint('🛒 StackTrace: $stackTrace');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAddresses() async {
    isLoadingAddresses.value = true;
    try {
      final response = await apiServices.callGet('api/v1/addresses');
      
      if (response != null && response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        addresses.value = data.map((item) => Address.fromJson(item)).toList();
        
        if (addresses.isNotEmpty) {
          selectedAddress.value = addresses.first;
        }
      }
    } catch (e) {
      print('Error fetching addresses: $e');
    } finally {
      isLoadingAddresses.value = false;
    }
  }

  double get itemPriceValue => cartItems.fold(0.0, (sum, item) =>
  sum + (double.tryParse(item.price) ?? 0.0) * item.quantity);

  int get itemPrice => itemPriceValue.toInt();
  int get discountedPrice => totalPrice.value.toInt();
  int get totalDiscount => (itemPriceValue - totalPrice.value).toInt();
  int get addonsPrice => 0;
  int get subtotal => totalPrice.value.toInt();

  void incrementQuantity(int index) {
    _updateQuantity(index, cartItems[index].quantity + 1);
  }

  void decrementQuantity(int index) {
    if (cartItems[index].quantity > 1) {
      _updateQuantity(index, cartItems[index].quantity - 1);
    } else {
      removeItem(index);
    }
  }

  Future<void> _updateQuantity(int index, int newQuantity) async {
    final item = cartItems[index];
    final oldQuantity = item.quantity;
    cartItems[index] = item.copyWith(quantity: newQuantity);
    cartItems.refresh();

    try {
      final response = await cartRepository.updateCartQuantity(
        cartItemId: item.id,
        quantity: newQuantity,
        showErrorToast: true,
      );

      if (response != null && response['success'] == true) {
        fetchCartData(showLoader: false); 
      } else {
        cartItems[index] = item.copyWith(quantity: oldQuantity);
        cartItems.refresh();
      }
    } catch (e) {
      cartItems[index] = item.copyWith(quantity: oldQuantity);
      cartItems.refresh();
      print('Error updating quantity: $e');
    }
  }

  Future<void> confirmRemove(int index) async {
    final item = cartItems[index];
    CustomDialog.showConfirmation(
      title: "Remove Item",
      message: "Are you sure you want to remove ${item.name} from your cart?",
      confirmText: "Remove",
      cancelText: "Cancel",
      confirmColor: AppColors.error,
      icon: Icons.delete_outline,
      onConfirm: () => removeItem(index),
    );
  }

  Future<void> removeItem(int index) async {
    final item = cartItems[index];
    final itemName = item.name;
    try {
      final response = await cartRepository.deleteCartItem(
        cartItemId: item.id,
        showErrorToast: true,
      );

      if (response != null && response['success'] == true) {
        Get.snackbar(
          'Item Removed',
          '$itemName has been removed from cart',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        fetchCartData(showLoader: false);
      }
    } catch (e) {
      print('Error removing item: $e');
    }
  }

  Future<void> confirmClear() async {
    if (cartItems.isEmpty) return;
    CustomDialog.showConfirmation(
      title: "Clear Cart",
      message: "Are you sure you want to remove all items from your cart?",
      confirmText: "Clear All",
      cancelText: "Cancel",
      confirmColor: AppColors.error,
      icon: Icons.delete_sweep_outlined,
      onConfirm: () => clearCart(),
    );
  }

  Future<void> clearCart() async {
    final oldItems = List<CartItemModel>.from(cartItems);
    cartItems.clear();
    
    try {
      final response = await cartRepository.clearAllCart(
        showErrorToast: true,
      );

      if (response != null && response['success'] == true) {
        Get.snackbar(
          'Cart Cleared',
          'All items have been removed from your cart',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        fetchCartData(showLoader: false);
      } else {
        cartItems.value = oldItems;
      }
    } catch (e) {
      cartItems.value = oldItems;
      print('Error clearing cart: $e');
    }
  }

  void selectAddress(Address address) {
    selectedAddress.value = address;
    Get.back();
  }

  void addNewAddress(Address address) {
    addresses.add(address);
    selectedAddress.value = address;
  }

  Future<void> checkout() async {
    if (selectedAddress.value == null) {
      Get.snackbar(
        "Address Required",
        "Please select a delivery address first",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (cartItems.isEmpty) {
      Get.snackbar(
        "Cart Empty",
        "Your cart is empty",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      final address = selectedAddress.value!;
      final Map<String, dynamic> checkoutData = {
        "payment_method": "razorpay",
        "shipping_address": {
          "name": address.fullName,
          "phone": address.phone,
          "address_line1": address.addressLine,
          "address_line2": "", 
          "city": address.city,
          "state": address.state,
          "country": "IN",
          "postal_code": address.pincode,
        },
        "notes": "Delivered from Ivatan App"
      };

      final response = await cartRepository.checkout(checkoutData: checkoutData);
      
      if (response != null && response['success'] == true) {
        final orderId = response['order']?['id'];
        cartItems.clear();
        totalPrice.value = 0.0;
        totalItems.value = 0;

        if (orderId != null) {
          await paymentController.initiatePayment(orderId is int ? orderId : int.parse(orderId.toString()));
        }
      } else {
        Get.snackbar(
          "Checkout Failed",
          response?['message'] ?? "Something went wrong during checkout",
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Checkout error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

class Address {
  String id;
  String type;
  String fullName;
  String addressLine;
  String city;
  String state;
  String pincode;
  String phone;

  Address({
    required this.id,
    required this.type,
    required this.fullName,
    required this.addressLine,
    required this.city,
    required this.state,
    required this.pincode,
    required this.phone,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'].toString(),
      type: json['type'] ?? 'Home',
      fullName: json['name'] ?? '',
      addressLine: '${json['address_line1'] ?? ''}${json['address_line2'] != null ? ', ${json['address_line2']}' : ''}',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['postal_code'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  String get fullAddress => '$addressLine, $city, $state - $pincode';
}
