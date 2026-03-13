import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:i_vatan_app/core/network/app_urls.dart';
import 'package:i_vatan_app/core/network/api_services.dart';

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
    // if (isOwnProfile) {
    //   return _MyProductsTabView();
    // }

    // Otherwise show products with Add to Cart buttons
    return _BrowseProductsView();
  }
}

class ProductCard extends GetWidget<ProductController> {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.put(ProductController());
    final imageUrl =
        product.coverImage != null
            ? AppUrls.getFullImageUrl(product.coverImage!)
            : 'https://via.placeholder.com/200';

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image - Clickable
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () {
                Get.to(() => ProductDetailScreen(product: product));
              },
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.shopping_bag,
                        size: 50,
                        color: Colors.grey.shade600,
                      ),
                    );
                  },
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
                      const SizedBox(height: 8),

                      // Quantity and Add to Cart Section
                      Obx(() {
                        final String productId = product.id;
                        final cartQty = controller.getCartQuantity(productId);
                        final displayQty = cartQty == 0 ? 1 : cartQty;
                        final isLoading = controller.loadingIds.contains(
                          productId,
                        );

                        return Column(
                          children: [
                            // Circular Quantity Controls
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap:
                                      () => controller.decreaseCartQuantity(
                                        productId,
                                      ),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.remove,
                                      size: 18,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    '$displayQty',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap:
                                      () => controller.increaseCartQuantity(
                                        productId,
                                      ),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // ADD TO CART Button
                            InkWell(
                              onTap: () {
                                if (isLoading) return;

                                // If not in cartItems, it needs to be initialized
                                if (cartQty == 0) {
                                  controller.addToCart(productId);
                                }
                                controller.addToCartApi(productId);
                              },
                              child: Container(
                                width: double.infinity,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child:
                                      isLoading
                                          ? const SizedBox(
                                            height: 16,
                                            width: 16,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                          : const Text(
                                            'ADD TO CART',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                            ),
                                          ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
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
  final String? coverImage;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.originalPrice,
    this.coverImage,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      originalPrice:
          json['discount_price'] != null
              ? double.tryParse(json['discount_price'].toString())
              : null,
      coverImage: json['cover_image'],
    );
  }
}

// Browse Products View - Fetches from Marketplace API
class _BrowseProductsView extends StatefulWidget {
  @override
  State<_BrowseProductsView> createState() => _BrowseProductsViewState();
}

class _BrowseProductsViewState extends State<_BrowseProductsView> {
  late Future<List<Product>> _productsFuture;
  final ApiServices apiServices = Get.find<ApiServices>();

  @override
  void initState() {
    super.initState();
    _productsFuture = _fetchProducts();
  }

  Future<List<Product>> _fetchProducts() async {
    try {
      final response = await apiServices.callGet('api/v1/marketplace/products');

      if (response != null && response['success'] == true) {
        final data = response['data'];

        // Handle paginated response
        List<dynamic> productsList = [];
        if (data is Map && data['data'] != null) {
          productsList = data['data'] as List<dynamic>;
        } else if (data is List) {
          productsList = data;
        }

        return productsList.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception(response?['message'] ?? "Failed to fetch products");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.black),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load products',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        final products = snapshot.data ?? [];

        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 80,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'No products available',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductCard(product: products[index]);
            },
          ),
        );
      },
    );
  }
}

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
              Icon(
                Icons.shopping_bag_outlined,
                size: 80,
                color: Colors.grey.shade300,
              ),
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

  Widget _buildProductCard(
    ProductModel product,
    MyProductsController controller,
  ) {
    final imageUrl =
        product.coverImage != null
            ? AppUrls.getFullImageUrl(product.coverImage!)
            : 'https://via.placeholder.com/200';

    return GestureDetector(
      onTap: () {
        Get.to(() => ProductDetailScreen(product: product));
      },
      child: Container(
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
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey.shade400,
                            ),
                          ),
                      /*Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.shopping_bag, size: 40, color: Colors.grey),
                      ),*/
                    ),
                  ),
                  // Status Badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color:
                            product.status.toLowerCase() == 'active'
                                ? Colors.green
                                : Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.status.toString().toUpperCase(),
                        //? 'Active' : 'Inactive',
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
                      product.title,
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
      ),
    );
  }
}
