import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:i_vatan_app/core/network/app_urls.dart';
import 'package:i_vatan_app/core/network/api_services.dart';
import '../../../core/widgets/custom_dialog.dart';
import 'create_product_screen.dart';
import 'image_viewer_screen.dart';
import 'my_products_screen.dart';
import '../data/model/marketplace_product_model.dart';
import 'controller/product_Controller.dart';

class ProductDetailScreen extends StatefulWidget {
  final dynamic product; // Can be Product, ProductModel, or MarketplaceProduct

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<dynamic> _productFuture;
  final ApiServices apiServices = Get.find<ApiServices>();
  final ProductController productController = Get.isRegistered<ProductController>() 
      ? Get.find<ProductController>() 
      : Get.put(ProductController());

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      // Check if it's a marketplace product OR a seller product and fetch full details
      final productType = widget.product.runtimeType.toString();
      if (productType.contains('MarketplaceProduct') || productType.contains('ProductModel')) {
        final String productId = (widget.product is Map ? widget.product['id'] : widget.product.id).toString();
        _productFuture = _fetchProductDetails(productId);
      } else {
        _productFuture = Future.value(widget.product);
      }
    });
  }

  Future<dynamic> _fetchProductDetails(String productId) async {
    try {
      // Use marketplace endpoint as it usually works for all products
      final response = await apiServices.callGet(AppUrls.marketplaceProductDetailItem(productId));
      
      if (response != null && response['success'] == true) {
        final data = response['data'] ?? {};
        // If it was a ProductModel, try to map it or return raw map
        if (widget.product.runtimeType.toString().contains('ProductModel')) {
          return ProductModel.fromJson(data);
        }
        return MarketplaceProduct.fromJson(data);
      } else {
        // Fallback to widget.product if fetch fails
        return widget.product;
      }
    } catch (e) {
      debugPrint("Error fetching product details: $e");
      return widget.product;
    }
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      CustomDialog.showLoading(message: "Deleting product...");
      final response = await apiServices.callDelete("${AppUrls.sellerProducts}/$productId");
      CustomDialog.hideLoading();

      if (response != null && response['success'] == true) {
        // Refresh the products list if the controller exists
        try {
          if (Get.isRegistered<MyProductsController>()) {
            Get.find<MyProductsController>().fetchProducts();
          }
        } catch (e) {
          debugPrint("Error refreshing products: $e");
        }

        Get.back(); // Go back to previous screen
        Get.snackbar(
          "Success",
          response['message'] ?? "Product deleted successfully",
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        // Error is already handled by ApiServices but it's good to have a backup
      }
    } catch (e) {
      CustomDialog.hideLoading();
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: _productFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Get.back(),
              ),
            ),
            body: const Center(
              child: CircularProgressIndicator(color: AppColors.black),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Get.back(),
              ),
            ),
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        final product = snapshot.data ?? widget.product;
        return _buildProductDetail(product);
      },
    );
  }

  Widget _buildProductDetail(dynamic initialProduct) {
      dynamic product = initialProduct;

      // Reactively retrieve the freshest version from MyProductsController if it exists
      final isSellersProduct = initialProduct.runtimeType.toString().contains('ProductModel');
      if (isSellersProduct && Get.isRegistered<MyProductsController>()) {
        final myProductsController = Get.find<MyProductsController>();
        final productId = (initialProduct is Map ? initialProduct['id'] : initialProduct.id).toString();
        try {
          final updatedProduct = myProductsController.products.firstWhere((p) => p.id == productId);
          product = updatedProduct; // Override with fresh reactive data
        } catch (e) {
          // ignore, keep initial
        }
      }

      final isMarketplaceProduct = product.runtimeType.toString().contains('MarketplaceProduct');
    
    final dynamic rawPrice = product is Map ? product['price'] : product.price;
    final double price = double.tryParse(rawPrice?.toString() ?? '0') ?? 0.0;
    
    final dynamic rawDiscountPrice = (product is Map)
        ? (product['discount_price'] ?? product['original_price'])
        : ((isSellersProduct || isMarketplaceProduct) ? product.discountPrice : product.originalPrice);
    
    final double? discountPrice = rawDiscountPrice != null ? double.tryParse(rawDiscountPrice.toString()) : null;
    final String title = (product is Map ? product['title'] : product.title) ?? '';
    final String description = (product is Map ? product['description'] : product.description) ?? '';
    final String? coverImage = (product is Map ? product['cover_image'] : product.coverImage);
    
    List images = [];
    if (product is Map) {
      images = product['images'] ?? [];
    } else {
      try {
        images = product.images ?? [];
      } catch (e) {
        // Fallback for types that might not have images property
        images = [];
      }
    }

    final imageUrl = coverImage != null
        ? AppUrls.getFullImageUrl(coverImage)
        : 'https://via.placeholder.com/300';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          if (isSellersProduct)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blue),
              onPressed: () async {
                await Get.to(() => CreateProductScreen(product: product));
                _refreshData();
              },
            ),
          if (isSellersProduct)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () {
                CustomDialog.showConfirmation(
                  title: "Delete Product",
                  message: "Are you sure you want to delete this product?",
                  confirmText: "Delete",
                  cancelText: "Cancel",
                  confirmColor: AppColors.error,
                  icon: Icons.delete_outline,
                  onConfirm: () {
                    final String productId = (product is Map ? product['id'] : product.id).toString();
                    _deleteProduct(productId);
                  },
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                    ),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                        );
                      },
                    ),
                  ),

                  // Product Details
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Price
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (discountPrice != null && discountPrice > 0)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '₹${price.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          decoration: TextDecoration.lineThrough,
                                          color: Colors.grey.shade600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        '₹${discountPrice.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 26,
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Text(
                                    '₹${price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 26,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Stock Info
                        if (isSellersProduct)
                          Text(
                            'Stock: ${product.stock} units',
                            style: TextStyle(
                              color: product.stock > 0 ? Colors.grey.shade600 : AppColors.error,
                              fontSize: 14,
                              fontWeight: product.stock == 0 ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),

                        const SizedBox(height: 20),

                        // Discount Badge
                        if (discountPrice != null && discountPrice > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${(((price - discountPrice) / price) * 100).toStringAsFixed(0)}% OFF',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),

                        const SizedBox(height: 24),

                        // Description
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          description,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            height: 1.6,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Additional Images Grid
                        if (images.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'More Images',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                itemCount: images.length,
                                itemBuilder: (context, index) {
                                  final img = images[index];
                                  final imagePath = img is Map ? img['image_path'] : img.imagePath;
                                  final imageUrl = AppUrls.getFullImageUrl(imagePath);
                                  return GestureDetector(
                                    onTap: () {
                                      final List<String> galleryImages = images.map((img) {
                                        return (img is Map ? img['image_path'] : img.imagePath).toString();
                                      }).toList();
                                      Get.to(() => ImageViewerScreen(
                                        images: galleryImages,
                                        initialIndex: index,
                                      ));
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey.shade200,
                                            child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),

                        const SizedBox(height: 100), // Space for bottom buttons
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Buttons - Only show for non-seller products
          if (!isSellersProduct)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Obx(() {
                  final String productId = (product is Map ? product['id'] : product.id).toString();
                  final isInCart = productController.isInCart(productId);
                  final cartQty = productController.getCartQuantity(productId);
                  final displayQty = cartQty == 0 ? 1 : cartQty;
                  final isLoading = productController.loadingIds.contains(productId);

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Circular Quantity Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => productController.decreaseCartQuantity(productId),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.remove, size: 24, color: Colors.black87),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              '$displayQty',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => productController.increaseCartQuantity(productId),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.black,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add, size: 24, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Bottom Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                if (isLoading) return;
                                if (cartQty == 0) {
                                  productController.addToCart(productId);
                                }
                                productController.addToCartApi(productId);
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.black, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        color: AppColors.black,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'ADD TO CART',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.black,
                                      ),
                                    ),
                            ),
                          ),
                          // const SizedBox(width: 12),
                          // Expanded(
                          //   child: ElevatedButton(
                          //     onPressed: () {
                          //       // Implement Buy Now logic or navigation to cart
                          //     },
                          //     style: ElevatedButton.styleFrom(
                          //       backgroundColor: AppColors.black,
                          //       foregroundColor: Colors.white,
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(12),
                          //       ),
                          //       padding: const EdgeInsets.symmetric(vertical: 14),
                          //     ),
                          //     child: const Text(
                          //       'BUY NOW',
                          //       style: TextStyle(
                          //         fontSize: 14,
                          //         fontWeight: FontWeight.bold,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
