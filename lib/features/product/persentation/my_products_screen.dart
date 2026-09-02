import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/features/product/persentation/product_detail_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_dialog.dart';
import '../../../core/network/app_urls.dart';
import '../../../core/network/api_services.dart';
import 'create_product_screen.dart';

class MyProductsController extends GetxController {
  var products = <ProductModel>[].obs;
  var isLoading = true.obs;
  final ApiServices apiServices = Get.find<ApiServices>();

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  void fetchProducts() async {
    isLoading.value = true;
    try {
      final response = await apiServices.callGet(AppUrls.sellerProducts);
      
      if (response != null && response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        products.value = data.map((item) => ProductModel.fromJson(item)).toList();
      } else {
        Get.snackbar(
          "Error",
          response?['message'] ?? "Failed to fetch products",
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void deleteProduct(String productId) {
    CustomDialog.showConfirmation(
      title: "Delete Product",
      message: "Are you sure you want to delete this product? This action cannot be undone.",
      confirmText: "Delete",
      cancelText: "Cancel",
      confirmColor: AppColors.error,
      icon: Icons.delete_outline,
      onConfirm: () {
        products.removeWhere((p) => p.id == productId);
        Get.snackbar(
          "Success",
          "Product deleted successfully",
          backgroundColor: AppColors.success,
          colorText: AppColors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  void toggleProductStatus(String productId) async {
    try {
      final index = products.indexWhere((p) => p.id == productId);
      if (index == -1) return;

      final product = products[index];
      final newStatus = product.status.contains("active") ? "inactive" : "active";

      final response = await apiServices.callPost(
        "${AppUrls.sellerProducts}/$productId",
        data: {"status": newStatus},
      );

      if (response != null && response['success'] == true) {
        final updatedData = response['data'];
        products[index] = ProductModel.fromJson(updatedData);
        products.refresh();

        Get.snackbar(
          "Success",
          "Product ${newStatus == 'active' ? 'activated' : 'deactivated'} successfully",
          backgroundColor: AppColors.success,
          colorText: AppColors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          "Error",
          response?['message'] ?? "Failed to update product status",
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

class ProductModel {
  final String id;
  final String uuid;
  final String title;
  final String description;
  final double price;
  final double? discountPrice;
  final int stock;
  final String? coverImage;
  final String status;
  final List<ProductImage> images;
  bool isActive;

  ProductModel({
    required this.id,
    required this.uuid,
    required this.title,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.stock,
    this.coverImage,
    required this.status,
    required this.images,
    this.isActive = true,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'].toString(),
      uuid: json['uuid'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      discountPrice: json['discount_price'] != null 
          ? double.tryParse(json['discount_price'].toString()) 
          : null,
      stock: json['stock'] ?? 0,
      coverImage: json['cover_image'],
      status: json['status'] ?? 'pending',
      images: (json['images'] as List<dynamic>?)
          ?.map((img) => ProductImage.fromJson(img))
          .toList() ?? [],
      isActive: json['status'] != 'inactive',
    );
  }
}

class ProductImage {
  final String id;
  final String imagePath;

  ProductImage({
    required this.id,
    required this.imagePath,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'].toString(),
      imagePath: json['image_path'] ?? '',
    );
  }
}

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  final MyProductsController controller = Get.put(MyProductsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparent,
      appBar: AppBar(
        title: const Text(
          "Your Products",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.transparent,
        foregroundColor: AppColors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Get.to(() => CreateProductScreen());
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.black),
          );
        }

        if (controller.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 80, color: AppColors.premiumGold),
                const SizedBox(height: 16),
                Text(
                  "No products yet",
                  style: TextStyle(fontSize: 18, color: AppColors.premiumGold),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.to(() => CreateProductScreen());
                  },
                  icon: const Icon(Icons.add, color: AppColors.white),
                  label: const Text("Add Product", style: TextStyle(color: AppColors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.products.length,
          itemBuilder: (context, index) {
            final product = controller.products[index];
            return _buildProductCard(product);
          },
        );
      }),
    );
  }

  /// Returns true if status should be shown as green (active or approved)
  bool _isPositiveStatus(String status) {
    final s = status.toLowerCase();
    return s == 'active' || s == 'approved';
  }

  Widget _buildProductCard(ProductModel product) {
    final imageUrl = product.coverImage != null 
        ? AppUrls.getFullImageUrl(product.coverImage!)
        : 'https://via.placeholder.com/80';

    return GestureDetector(
      onTap: () {
        Get.to(() => ProductDetailScreen(product: product));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.white.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: AppColors.premiumGold,
                        child: const Icon(Icons.image_not_supported, color: AppColors.premiumGold),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Active/Inactive/Approved Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _isPositiveStatus(product.status)
                                  ? AppColors.success.withOpacity(0.1)
                                  : AppColors.premiumGold,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              product.status.toString().toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _isPositiveStatus(product.status) ? AppColors.success : AppColors.premiumGold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (product.discountPrice != null) ...[
                            Text(
                              "₹${product.discountPrice!.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "₹${product.price.toStringAsFixed(0)}",
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.premiumGold,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ] else
                            Text(
                              "₹${product.price.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 16,
                            color: product.stock > 0 ? AppColors.premiumGold : AppColors.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            product.stock > 0 ? "Stock: ${product.stock}" : "Out of Stock",
                            style: TextStyle(
                              fontSize: 13,
                              color: product.stock > 0 ? AppColors.premiumGold : AppColors.error,
                              fontWeight: product.stock == 0 ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            //
            // const SizedBox(height: 16),
            // const Divider(height: 1),
            // const SizedBox(height: 12),

            // Action Buttons
            /*Row(
              children: [
                // Edit Button
                _buildActionButton(
                  icon: Icons.edit_outlined,
                  color: Colors.blue,
                  onTap: () {
                    Get.to(() => CreateProductScreen(product: product));
                  },
                ),
                const SizedBox(width: 8),

                // Toggle Active/Inactive
                _buildActionButton(
                  icon: product.status.contains("active") ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: product.status.contains("active") ? Colors.orange : AppColors.success,
                  onTap: () => controller.toggleProductStatus(product.id),
                ),
                const SizedBox(width: 8),

                // Delete Button
                _buildActionButton(
                  icon: Icons.delete_outline,
                  color: AppColors.error,
                  onTap: () => controller.deleteProduct(product.id),
                ),
              ],
            ),*/
          ],
        ),
      ),
    );
    }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}
