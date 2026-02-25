import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_dialog.dart';
import 'create_product_screen.dart';
import 'edit_product_screen.dart';

class MyProductsController extends GetxController {
  var products = <ProductModel>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  void fetchProducts() {
    isLoading.value = true;
    
    // TODO: API call to fetch user's products
    Future.delayed(const Duration(seconds: 1), () {
      products.value = [
        ProductModel(
          id: "1",
          name: "Wireless Headphones",
          image: "https://m.media-amazon.com/images/I/610ub5kytVL.jpg",
          price: 2999,
          discountPrice: 2499,
          stock: 50,
          isActive: true,
        ),
        ProductModel(
          id: "2",
          name: "Smart Watch",
          image: "https://m.media-amazon.com/images/I/61ZjlBOp+rL._AC_UL320_.jpg",
          price: 4999,
          discountPrice: 3999,
          stock: 0,
          isActive: true,
        ),
        ProductModel(
          id: "3",
          name: "Phone Case",
          image: "https://m.media-amazon.com/images/I/71GLMJ7TQiL._AC_UL320_.jpg",
          price: 499,
          stock: 100,
          isActive: false,
        ),
      ];
      isLoading.value = false;
    });
  }

  void toggleProductStatus(String productId) {
    final index = products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      products[index].isActive = !products[index].isActive;
      products.refresh();
      
      Get.snackbar(
        "Success",
        products[index].isActive ? "Product activated" : "Product deactivated",
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void increaseStock(String productId) {
    final index = products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      products[index].stock++;
      products.refresh();
    }
  }

  void decreaseStock(String productId) {
    final index = products.indexWhere((p) => p.id == productId);
    if (index != -1 && products[index].stock > 0) {
      products[index].stock--;
      products.refresh();
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
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }
}

class ProductModel {
  final String id;
  final String name;
  final String image;
  final double price;
  final double? discountPrice;
  int stock;
  bool isActive;

  ProductModel({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    this.discountPrice,
    required this.stock,
    this.isActive = true,
  });
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Your Products",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
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
                Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  "No products yet",
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.to(() => CreateProductScreen());
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text("Add Product", style: TextStyle(color: Colors.white)),
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

  Widget _buildProductCard(ProductModel product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                  product.image,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
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
                            product.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Active/Inactive Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: product.isActive
                                ? AppColors.success.withOpacity(0.1)
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            product.isActive ? "Active" : "Inactive",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: product.isActive ? AppColors.success : Colors.grey.shade700,
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
                              color: Colors.grey.shade600,
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
                          color: product.stock > 0 ? Colors.grey.shade600 : AppColors.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          product.stock > 0 ? "Stock: ${product.stock}" : "Out of Stock",
                          style: TextStyle(
                            fontSize: 13,
                            color: product.stock > 0 ? Colors.grey.shade600 : AppColors.error,
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

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              // Stock Controls
              Expanded(
                child: Row(
                  children: [
                    Text(
                      "Qty:",
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                    const SizedBox(width: 8),
                    _buildStockButton(
                      icon: Icons.remove,
                      onTap: () => controller.decreaseStock(product.id),
                      enabled: product.stock > 0,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${product.stock}",
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    _buildStockButton(
                      icon: Icons.add,
                      onTap: () => controller.increaseStock(product.id),
                    ),
                  ],
                ),
              ),

              // Edit Button
              _buildActionButton(
                icon: Icons.edit_outlined,
                color: Colors.blue,
                onTap: () {
                  Get.to(() => EditProductScreen(product: product));
                },
              ),
              const SizedBox(width: 8),

              // Toggle Active/Inactive
              _buildActionButton(
                icon: product.isActive ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: product.isActive ? Colors.orange : AppColors.success,
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
          ),
        ],
      ),
    );
  }

  Widget _buildStockButton({
    required IconData icon,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: enabled ? AppColors.lightBackground : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: enabled ? AppColors.lightBorder : Colors.grey.shade300,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppColors.black : Colors.grey.shade400,
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
