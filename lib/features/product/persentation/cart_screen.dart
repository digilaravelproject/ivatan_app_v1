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
import 'add_address_screen.dart';import 'controller/cart_controller.dart';

// Main Cart Screen
class CartScreen extends StatelessWidget {
  final CartController controller = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparent,
      appBar: AppBar(
        title: Text(
          'My Cart',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.transparent,
        elevation: 1,
        iconTheme: IconThemeData(color: AppColors.white),
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
          return Center(child: CircularProgressIndicator(color: AppColors.white));
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
            color: AppColors.white,
          ),
          SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add items to get started',
            style: TextStyle(
              color: AppColors.white,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.transparent,
              foregroundColor: AppColors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Browse Products'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => controller.fetchCartData(),
      color: AppColors.white,
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.white),
        boxShadow: [
          BoxShadow(
            color: AppColors.white.withOpacity(0.02),
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
                    color: AppColors.premiumGold,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.image_not_supported, color: AppColors.premiumGold),
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
                          color: AppColors.white,
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
                          color: AppColors.white,
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
                          color: AppColors.premiumGold,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.white,
                              blurRadius: 3,
                            )
                          ],
                        ),
                        child: Icon(
                          Icons.remove,
                          size: 16,
                          color: AppColors.white,
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
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add,
                          size: 16,
                          color: AppColors.white,
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
        color: AppColors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, color: AppColors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Delivery Address',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  _showAddressBottomSheet(context);
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.white),
                child: Text(
                  'Change',
                  style: TextStyle(
                    color: AppColors.white,
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
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.white),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          address.type,
                          style: TextStyle(
                            color: AppColors.white,
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
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    address.fullAddress,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Phone: ${address.phone}',
                    style: TextStyle(
                      color: AppColors.white,
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
        color: AppColors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.white),
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
            child: Divider(color: AppColors.white),
          ),
          _buildPriceRow('Subtotal', '₹${controller.subtotal}',
              isBold: true, fontSize: 18, valueColor: AppColors.white),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value,
      {Color valueColor = AppColors.white, bool isBold = false, double fontSize = 14}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.white,
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
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.white.withOpacity(0.05),
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
            backgroundColor: AppColors.transparent,
            foregroundColor: AppColors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: Size(double.infinity, 50),
          ),
          child: controller.isLoading.value
            ? CircularProgressIndicator(color: AppColors.white)
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.white,
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
                      color: AppColors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back();
                      Get.toNamed(AppRoutes.addAddressScreen);
                    },
                    style: TextButton.styleFrom(foregroundColor: AppColors.white),
                    child: Text(
                      '+ Add New',
                      style: TextStyle(
                        color: AppColors.white,
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
                    child: CircularProgressIndicator(color: AppColors.white),
                  );
                }
                
                if (controller.addresses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_off, size: 50, color: AppColors.premiumGold),
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
          color: isSelected ? AppColors.white.withOpacity(0.05) : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.white : AppColors.white,
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
                          color: isSelected ? AppColors.white : AppColors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          address.type,
                          style: TextStyle(
                            color: isSelected ? AppColors.white : AppColors.white,
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
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    address.fullAddress,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Phone: ${address.phone}',
                    style: TextStyle(
                      color: AppColors.white,
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
              activeColor: AppColors.white,
            ),
          ],
        ),
      ),
    );
  }
}





