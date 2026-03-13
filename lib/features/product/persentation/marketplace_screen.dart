import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:i_vatan_app/core/network/app_urls.dart';
import 'controller/marketplace_controller.dart';
import 'product_detail_screen.dart';
import '../data/model/marketplace_product_model.dart';
import 'controller/product_Controller.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final MarketplaceController controller = Get.put(MarketplaceController());
  final ProductController productController = Get.isRegistered<ProductController>()
      ? Get.find<ProductController>()
      : Get.put(ProductController());
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        controller.loadMoreProducts();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Marketplace',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.products.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.black),
          );
        }

        if (controller.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag_outlined,
                    size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No products available',
                  style: TextStyle(
                      fontSize: 18, color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: controller.products.length + 1,
          itemBuilder: (context, index) {
            if (index == controller.products.length) {
              return Obx(() {
                if (controller.currentPage.value < controller.lastPage.value) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.black),
                    ),
                  );
                }
                return const SizedBox();
              });
            }

            final product = controller.products[index];
            return _buildProductCard(product);
          },
        );
      }),
    );
  }

  Widget _buildProductCard(MarketplaceProduct product) {
    final imageUrl = product.coverImage.isNotEmpty
        ? AppUrls.getFullImageUrl(product.coverImage)
        : 'https://via.placeholder.com/200';

    return GestureDetector(
      onTap: () {
        Get.to(() => ProductDetailScreen(product: product));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12)),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported,
                        color: Colors.grey),
                  );
                },
              ),
            ),

            // Product Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Price Row
                  Row(
                    children: [
                      Text(
                        '₹${product.discountPrice ?? product.price}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      if (product.discountPrice != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '₹${product.price}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Quantity and Add to Cart Section
                  Obx(() {
                    final String productId = product.id.toString();
                    final cartQty = productController.getCartQuantity(productId);
                    final displayQty = cartQty == 0 ? 1 : cartQty;
                    final isLoading = productController.loadingIds.contains(productId);

                    return Column(
                      children: [
                        // Circular Quantity Controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => productController.decreaseCartQuantity(productId),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.remove, size: 20, color: Colors.black87),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                '$displayQty',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => productController.increaseCartQuantity(productId),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.add, size: 20, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // ADD TO CART Button
                        InkWell(
                          onTap: () {
                            if (isLoading) return;
                            if (cartQty == 0) {
                              productController.addToCart(productId);
                            }
                            productController.addToCartApi(productId);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: isLoading
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
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
                                        fontSize: 14,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 16),

                  // Seller Info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: product.seller.profilePhotoPath != null
                            ? NetworkImage(AppUrls.getFullImageUrl(
                                product.seller.profilePhotoPath!))
                            : null,
                        child: product.seller.profilePhotoPath == null
                            ? const Icon(Icons.person, size: 16)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    product.seller.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                if (product.seller.isVerified)
                                  const Icon(Icons.verified,
                                      size: 14, color: Colors.blue),
                              ],
                            ),
                            Text(
                              '${product.seller.followersCount} followers',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Stock Status
                  Text(
                    product.stock > 0
                        ? 'Stock: ${product.stock}'
                        : 'Out of Stock',
                    style: TextStyle(
                      fontSize: 12,
                      color: product.stock > 0
                          ? Colors.grey.shade600
                          : Colors.red,
                      fontWeight: product.stock == 0
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
