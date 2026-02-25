import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:i_vatan_app/core/utils/custom_buttons.dart';
import 'package:i_vatan_app/core/widgets/custom_dialog.dart';
import 'package:i_vatan_app/route/app_pages.dart';

import 'add_address_screen.dart';




class CartController extends GetxController {
  var cartItems = <CartItem>[].obs;
  var selectedAddress = Rx<Address?>(null);
  var addresses = <Address>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Sample data with proper product images
    cartItems.addAll([
      CartItem(
        name: 'Wireless Headphones',
        originalPrice: 2999,
        discountedPrice: 2499,
        quantity: 1,
        image: 'https://m.media-amazon.com/images/I/610ub5kytVL.jpg',
      ),
      CartItem(
        name: 'Smart Watch',
        originalPrice: 4999,
        discountedPrice: 3999,
        quantity: 1,
        image: 'https://m.media-amazon.com/images/I/61ZjlBOp+rL._AC_UL320_.jpg',
      ),
      CartItem(
        name: 'Phone Case',
        originalPrice: 499,
        discountedPrice: 399,
        quantity: 2,
        image: 'https://m.media-amazon.com/images/I/71e+R8mQcvL._AC_UL320_.jpg',
      ),
    ]);

    addresses.addAll([
      Address(
        id: '1',
        type: 'Home',
        fullName: 'Rahul Sharma',
        addressLine: '123, Green Park Extension',
        city: 'New Delhi',
        state: 'Delhi',
        pincode: '110016',
        phone: '+91 9876543210',
      ),
      Address(
        id: '2',
        type: 'Office',
        fullName: 'Rahul Sharma',
        addressLine: 'Cyber City, Tower B, 5th Floor',
        city: 'Gurugram',
        state: 'Haryana',
        pincode: '122002',
        phone: '+91 9876543210',
      ),
    ]);

    selectedAddress.value = addresses.first;
  }

  int get itemPrice => cartItems.fold(0, (sum, item) =>
  sum + (item.originalPrice * item.quantity));

  int get discountedPrice => cartItems.fold(0, (sum, item) =>
  sum + (item.discountedPrice * item.quantity));

  int get totalDiscount => itemPrice - discountedPrice;

  int get addonsPrice => 0; // Can be modified based on addons

  int get subtotal => discountedPrice + addonsPrice;

  void incrementQuantity(int index) {
    cartItems[index].quantity++;
    cartItems.refresh();
  }

  void decrementQuantity(int index) {
    if (cartItems[index].quantity > 1) {
      cartItems[index].quantity--;
      cartItems.refresh();
    } else {
      removeItem(index);
    }
  }

  void removeItem(int index) {
    final itemName = cartItems[index].name;
    cartItems.removeAt(index);
    Get.snackbar(
      'Item Removed',
      '$itemName has been removed from cart',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void selectAddress(Address address) {
    selectedAddress.value = address;
    Get.back();
  }

  void addNewAddress(Address address) {
    addresses.add(address);
    selectedAddress.value = address;
  }
}


class CartItem {
  String name;
  int originalPrice;
  int discountedPrice;
  int quantity;
  String image;

  CartItem({
    required this.name,
    required this.originalPrice,
    required this.discountedPrice,
    required this.quantity,
    required this.image,
  });
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
      ),
      body: Obx(() => controller.cartItems.isEmpty
          ? _buildEmptyCart()
          : _buildCartContent(context)),
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
              // Navigate to home screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Browse Menu'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(BuildContext context) {
    return Column(
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
    );
  }

  Widget _buildCartItemCard(int index, CartItem item) {
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
              item.image,
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
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '₹${item.discountedPrice}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.green.shade700,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '₹${item.originalPrice}',
                      style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.black38,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Quantity Controls
          // Quantity Controls

          Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                // decoration: BoxDecoration(
                //   color: Colors.grey.shade100,
                //   borderRadius: BorderRadius.circular(30),
                // ),
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
                '₹${item.discountedPrice * item.quantity}',
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
        child: ElevatedButton(
          onPressed: () {
            // Show order confirmation
            CustomDialog.showConfirmation(
              title: "Confirm Order",
              message: "Total Amount: ₹${controller.subtotal}\n\nProceed with this order?",
              confirmText: "Place Order",
              cancelText: "Cancel",
              confirmColor: AppColors.black,
              icon: Icons.shopping_bag_outlined,
              onConfirm: () {
                Get.snackbar(
                  "Order Placed",
                  "Your order has been placed successfully!",
                  backgroundColor: AppColors.success,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 3),
                );
                // Clear cart after order
                controller.cartItems.clear();
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: Size(double.infinity, 50),
          ),
          child: Text(
            'Confirm Delivery Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
              child: Obx(() => ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.addresses.length,
                itemBuilder: (context, index) {
                  final address = controller.addresses[index];
                  final isSelected = controller.selectedAddress.value?.id == address.id;
                  return _buildAddressCard(address, isSelected);
                },
              )),
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





