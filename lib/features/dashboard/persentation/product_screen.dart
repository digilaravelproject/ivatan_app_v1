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




class ProductGridScreen extends StatelessWidget {
  const ProductGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
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
    return GestureDetector(
      onTap: (){
        showProductBottomSheet(context, controller);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Placeholder
            Expanded(
              flex: 2,
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
            // Product Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Price Row
                    Row(
                      children: [
                        Text(
                          '₹${product.price.toStringAsFixed(2)}',
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
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Buy Now Button
                    InkWell(
                      onTap: (){
                        showProductBottomSheet(context, controller);
                      },
                      child: Container(
                        width: double.infinity,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Center(
                          child: Text(
                            'BUY NOW',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void showProductBottomSheet(BuildContext context, ProductController controller) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

           // SizedBox(height: 10,),

            // Product Image in Bottom Sheet
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20),bottom: Radius.circular(20)),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20),bottom: Radius.circular(20)),
                    image: DecorationImage(
                      image: NetworkImage('https://m.media-amazon.com/images/I/610ub5kytVL.jpg'), // replace with your image URL
                      fit: BoxFit.cover, // cover the whole container
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Optional overlay to darken image for better text visibility
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20),bottom: Radius.circular(20)),
                          color: Colors.black.withOpacity(0.2), // adjust opacity
                        ),
                      ),

                      // Rating Positioned
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              Text('4.0', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(' (0)', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'HeadPhone',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹160',
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '₹140',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Mobile Shop',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Experience crystal-clear sound and deep bass with these premium headphones. Designed for comfort, long listening sessions, and immersive audio, they feature noise-cancellation, a sleek ergonomic design, and a durable build.',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 24),

                  // Quantity Selector and Total
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Quantity',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Obx(() => Row(
                              children: [
                                IconButton(
                                  onPressed: () => controller.decrement(),
                                  icon: Icon(Icons.remove_circle_outline),
                                  color: AppColors.primary,
                                ),
                                Container(
                                  width: 15,
                                  child: Text(
                                    '${controller.quantity}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => controller.increment(),
                                  icon: Icon(Icons.add_circle_outline),
                                  color: AppColors.primary,
                                ),
                              ],
                            )),
                          ],
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Amount',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Obx(() => Text(
                              '₹${controller.totalAmount}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            )),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.snackbar(
                          'Success',
                          'Added to cart',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'ADD TO CART',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

}

class Product {
  final String title;
  final String description;
  final double price;
  final double? originalPrice;
  final IconData icon;

  Product({
    required this.title,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.icon,
  });
}

final List<Product> productList = [
  Product(
    title: 'Wireless Headphone',
    description: 'Bass is the heartbeat of the music, setting the rhythm.',
    price: 125.00,
    originalPrice: 200.00,
    icon: Icons.headphones,
  ),
  Product(
    title: 'iPhone 15',
    description: 'Bass is the heartbeat of the music, setting the rhythm.',
    price: 125.00,
    originalPrice: 200.00,
    icon: Icons.phone_android,
  ),
  Product(
    title: 'Wireless Headphone Pro',
    description: 'Premium sound quality with noise cancellation.',
    price: 199.00,
    originalPrice: 250.00,
    icon: Icons.headset,
  ),
  Product(
    title: 'iPhone 15 Pro',
    description: 'Latest model with advanced features.',
    price: 299.00,
    originalPrice: 350.00,
    icon: Icons.phone_iphone,
  ),
];