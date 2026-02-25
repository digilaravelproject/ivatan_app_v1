import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';

import '../../auth/persentation/google_login_page.dart';
import '../../product/persentation/controller/product_Controller.dart';
import '../../product/persentation/cart_screen.dart';
import '../../product/persentation/product_detail_screen.dart';
import '../../product/persentation/my_products_screen.dart';




class ProductGridScreen extends StatelessWidget {
  final bool isOwnProfile;
  
  const ProductGridScreen({super.key, this.isOwnProfile = false});

  @override
  Widget build(BuildContext context) {
    // If it's own profile, show management view (without AppBar)
    if (isOwnProfile) {
      return _MyProductsTabView();
    }
    
    // Otherwise show products with Add to Cart buttons
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.68,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: productList.length,
        itemBuilder: (context, index) {
          return ProductCard(product: productList[index]);
        },
      ),
    );
  }
}

class ProductCard extends GetWidget<ProductController>  {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.put(ProductController());
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image Placeholder - Clickable
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () {
                Get.to(() => ProductDetailScreen(product: product));
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Icon(
                    product.icon,
                    size: 50,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ),
          // Product Details
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.to(() => ProductDetailScreen(product: product));
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.description,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Price Row
                      Row(
                        children: [
                          Text(
                            '₹${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          if (product.originalPrice != null) ...[
                            const SizedBox(width: 4),
                            Text(
                              '₹${product.originalPrice!.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                // Add to Cart Button with +/- controls
                Obx(() {
                  final isInCart = controller.isInCart(product.id);
                  final cartQty = controller.getCartQuantity(product.id);

                  return isInCart
                      ? Container(
                          width: double.infinity,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary, width: 2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkWell(
                                onTap: () => controller.decreaseCartQuantity(product.id),
                                child: Icon(
                                  Icons.remove,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                              ),
                              Text(
                                '$cartQty',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              InkWell(
                                onTap: () => controller.increaseCartQuantity(product.id),
                                child: Icon(
                                  Icons.add,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        )
                      : InkWell(
                          onTap: () {
                            controller.addToCart(product.id);
                            Get.snackbar(
                              'Success',
                              'Added to cart',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 1),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Center(
                              child: Text(
                                'ADD TO CART',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }




}

class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final double? originalPrice;
  final IconData icon;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.icon,
  });
}

final List<Product> productList = [
  Product(
    id: '1',
    title: 'Wireless Headphone',
    description: 'Bass is the heartbeat of the music, setting the rhythm.',
    price: 125.00,
    originalPrice: 200.00,
    icon: Icons.headphones,
  ),
  Product(
    id: '2',
    title: 'iPhone 15',
    description: 'Bass is the heartbeat of the music, setting the rhythm.',
    price: 125.00,
    originalPrice: 200.00,
    icon: Icons.phone_android,
  ),
  Product(
    id: '3',
    title: 'Wireless Headphone Pro',
    description: 'Premium sound quality with noise cancellation.',
    price: 199.00,
    originalPrice: 250.00,
    icon: Icons.headset,
  ),
  Product(
    id: '4',
    title: 'iPhone 15 Pro',
    description: 'Latest model with advanced features.',
    price: 299.00,
    originalPrice: 350.00,
    icon: Icons.phone_iphone,
  ),
];


// Wrapper widget for tab view (without AppBar)
class _MyProductsTabView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyProductsController());
    
    return Obx(() {
      if (controller.products.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'No products yet',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }

      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: controller.products.length,
        itemBuilder: (context, index) {
          final product = controller.products[index];
          return _buildProductCard(product, controller);
        },
      );
    });
  }

  Widget _buildProductCard(ProductModel product, MyProductsController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    product.image,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.shopping_bag, size: 40, color: Colors.grey),
                    ),
                  ),
                ),
                // Status Badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: product.isActive ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      product.isActive ? 'Active' : 'Inactive',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Product Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        'Stock: ${product.stock}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
