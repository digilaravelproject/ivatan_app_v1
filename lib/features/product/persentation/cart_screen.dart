import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/core/network/app_urls.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:i_vatan_app/core/utils/custom_buttons.dart';
import 'package:i_vatan_app/core/widgets/custom_dialog.dart';
import 'package:i_vatan_app/core/network/api_services.dart';
import 'package:i_vatan_app/route/app_pages.dart';

import '../data/model/cart_model.dart';
import '../repository/cart_repository.dart';
import 'add_address_screen.dart';




import '../../payment/presentation/controller/payment_controller.dart';


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
        // Check if the response contains cart data directly or within a success wrapper
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
      } else {
        // Fallback to sample data for addresses if needed, or keep empty
      }
    } catch (e) {
      print('Error fetching addresses: $e');
    } finally {
      isLoadingAddresses.value = false;
    }
  }

  // Price calculation based on API data
  double get itemPriceValue => cartItems.fold(0.0, (sum, item) =>
  sum + (double.tryParse(item.price) ?? 0.0) * item.quantity);

  // For UI compatibility, keeping existing getters with same naming if possible
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
    
    // Optimistic local update for immediate UI feedback
    final oldQuantity = item.quantity;
    cartItems[index] = item.copyWith(quantity: newQuantity);
    cartItems.refresh();

    try {
      // Use specific cart update API
      final response = await cartRepository.updateCartQuantity(
        cartItemId: item.id,
        quantity: newQuantity,
        showErrorToast: true,
      );

      if (response != null && response['success'] == true) {
        // Refresh cart data in background to update totals without global loader
        fetchCartData(showLoader: false); 
      } else {
        // Revert local update on failure
        cartItems[index] = item.copyWith(quantity: oldQuantity);
        cartItems.refresh();
      }
    } catch (e) {
      // Revert local update on error
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
    // Optimistic local update
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
        // Revert on failure
        cartItems.value = oldItems;
      }
    } catch (e) {
      // Revert on error
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
      
      // Prepare checkout data as per the user's provided sample
      final Map<String, dynamic> checkoutData = {
        "payment_method": "razorpay",
        "shipping_address": {
          "name": address.fullName,
          "phone": address.phone,
          "address_line1": address.addressLine, // Note: We might need to split this if the API is strict, but using existing fields for now
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
        
        // Clear cart after successful order creation
        cartItems.clear();
        totalPrice.value = 0.0;
        totalItems.value = 0;

        if (orderId != null) {
          // 3. Initiate Razorpay Payment
          await paymentController.initiatePayment(orderId is int ? orderId : int.parse(orderId.toString()));
        } else {
           Get.snackbar(
            "Order Partial Success",
            "Order created but payment could not be initiated.",
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
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
      Get.snackbar(
        "Error",
        "An unexpected error occurred: $e",
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
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

// Main Cart Screen
class CartScreen extends StatelessWidget {
  final CartController controller = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'My Cart',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          Obx(() => controller.cartItems.isNotEmpty
              ? IconButton(
                  onPressed: () => controller.confirmClear(),
                  icon: Icon(Icons.delete_sweep_outlined, color: AppColors.error),
                  tooltip: 'Clear Cart',
                )
              : SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: Colors.black));
        }
        return controller.cartItems.isEmpty
            ? _buildEmptyCart()
            : _buildCartContent(context);
      }),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.black12,
          ),
          SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add items to get started',
            style: TextStyle(
              color: Colors.black45,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Browse Marketplace'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => controller.fetchCartData(),
      color: Colors.black,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Cart Items
                  ...List.generate(controller.cartItems.length, (index) {
                    final item = controller.cartItems[index];
                    return _buildCartItemCard(index, item);
                  }),
  
                  SizedBox(height: 12),
  
                  // Address Section
                  _buildAddressSection(context),
  
                  SizedBox(height: 16),
  
                  // Price Details
                  _buildPriceDetails(),
  
                  SizedBox(height: 16),
  
                ],
              ),
            ),
          ),
  
          // Confirm Delivery Button
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(int index, CartItemModel item) {
    final String fullImageUrl = "${AppUrls.imageurl}${item.coverImage}";
    final double originalPrice = double.tryParse(item.product?.price ?? item.price) ?? 0.0;
    final double discountedPrice = double.tryParse(item.product?.discountPrice ?? item.price) ?? 0.0;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              fullImageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.image_not_supported, color: Colors.grey),
                );
              },
            ),
          ),
          SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => controller.confirmRemove(index),
                      icon: Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '₹${discountedPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.green.shade700,
                      ),
                    ),
                    if (originalPrice > discountedPrice) ...[
                      SizedBox(width: 4),
                      Text(
                        '₹${originalPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.black38,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Quantity Controls
          Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => controller.decrementQuantity(index),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 3,
                            )
                          ],
                        ),
                        child: Icon(
                          Icons.remove,
                          size: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    SizedBox(width: 12),

                    Text(
                      '${item.quantity}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),

                    SizedBox(width: 12),

                    GestureDetector(
                      onTap: () => controller.incrementQuantity(index),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              // Item Total
              Text(
                '₹${(discountedPrice * item.quantity).toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          )

        ],
      ),
    );
  }

  Widget _buildAddressSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.black54, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Delivery Address',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  _showAddressBottomSheet(context);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.black),
                child: Text(
                  'Change',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Obx(() {
            final address = controller.selectedAddress.value;
            if (address == null) return SizedBox();
            return Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          address.type,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          address.fullName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    address.fullAddress,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Phone: ${address.phone}',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPriceDetails() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          _buildPriceRow('Item Price', '₹${controller.itemPrice}'),
          SizedBox(height: 12),
          _buildPriceRow('Discount', '(-) ₹${controller.totalDiscount}',
              valueColor: Colors.green.shade700),
          SizedBox(height: 12),
          _buildPriceRow('Addons', '(+) ₹${controller.addonsPrice}'),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.black12),
          ),
          _buildPriceRow('Subtotal', '₹${controller.subtotal}',
              isBold: true, fontSize: 18, valueColor: Colors.black87),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value,
      {Color valueColor = Colors.black54, bool isBold = false, double fontSize = 14}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.black54,
            fontSize: fontSize - 2,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(() => ElevatedButton(
          onPressed: controller.isLoading.value 
            ? null 
            : () => controller.checkout(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: Size(double.infinity, 50),
          ),
          child: controller.isLoading.value
            ? CircularProgressIndicator(color: Colors.white)
            : Text(
                'Checkout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
        )),
      ),
    );
  }

  void _showAddressBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Delivery Address',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back();
                      Get.toNamed(AppRoutes.addAddressScreen);
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.black),
                    child: Text(
                      '+ Add New',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoadingAddresses.value) {
                  return Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  );
                }
                
                if (controller.addresses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_off, size: 50, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No addresses found'),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.addresses.length,
                  itemBuilder: (context, index) {
                    final address = controller.addresses[index];
                    final isSelected = controller.selectedAddress.value?.id == address.id;
                    return _buildAddressCard(address, isSelected);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(Address address, bool isSelected) {
    return GestureDetector(
      onTap: () {
        controller.selectAddress(address);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.black54 : Colors.black12,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.black : Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          address.type,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black54,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          address.fullName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    address.fullAddress,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Phone: ${address.phone}',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Radio(
              value: address.id,
              groupValue: controller.selectedAddress.value?.id,
              onChanged: (value) {
                controller.selectAddress(address);
              },
              activeColor: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}





